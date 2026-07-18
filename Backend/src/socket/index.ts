import { Server as HTTPServer } from "http";
import { Server, Socket } from "socket.io";
import jwt from "jsonwebtoken";
import { JWT_SECRET } from "../config";

let io: Server | null = null;

/**
 * Get the Socket.IO server instance (used by NotificationService to emit events).
 */
export function getIO(): Server | null {
  return io;
}

// ────────────────────────────────────────────────────────────
// Real-Time Order Event Helpers
// ────────────────────────────────────────────────────────────

/**
 * Prepare a minimal order payload for socket emission.
 * Strips out heavy Mongoose internals and returns a plain JSON object.
 */
function buildOrderPayload(order: any) {
  return {
    _id: order._id?.toString(),
    customerId:
      typeof order.customerId === "object"
        ? {
            _id: order.customerId._id?.toString(),
            name: order.customerId.name,
            phone: order.customerId.phone,
            address: order.customerId.address,
          }
        : order.customerId?.toString(),
    orderNumber: order.orderNumber,
    items: (order.items || []).map((item: any) => ({
      productId:
        typeof item.productId === "object"
          ? {
              _id: item.productId._id?.toString(),
              productName: item.productId.productName,
              price: item.productId.price,
              imageUrl: item.productId.imageUrl,
            }
          : item.productId?.toString(),
      productName: item.productName,
      price: item.price,
      quantity: item.quantity,
    })),
    deliveryAddress: order.deliveryAddress,
    totalAmount: order.totalAmount,
    paymentMethod: order.paymentMethod,
    paymentStatus: order.paymentStatus,
    status: order.status,
    customerNote: order.customerNote,
    estimatedDeliveryTime: order.estimatedDeliveryTime,
    rejectedBy: (order.rejectedBy || []).map((id: any) => id?.toString()),
    createdAt: order.createdAt?.toISOString?.() || order.createdAt,
    updatedAt: order.updatedAt?.toISOString?.() || order.updatedAt,
  };
}

/**
 * Emit a `new_order` event to all eligible vendors.
 * Each vendor is connected via `vendor_<shopkeeperUserId>` room.
 */
export function emitNewOrder(order: any, shopkeeperIds: string[]): void {
  if (!io) {
    console.warn("[Socket] IO not initialized, skipping emitNewOrder");
    return;
  }
  const payload = buildOrderPayload(order);
  for (const shopkeeperId of shopkeeperIds) {
    const room = `vendor_${shopkeeperId}`;
    io.to(room).emit("new_order", payload);
    console.log(`[Socket] Emitted new_order to ${room}`);
  }
}

/**
 * Emit an `order_accepted` event so other vendors remove this order from their pending list.
 */
export function emitOrderAccepted(order: any, acceptedShopkeeperId: string, allShopkeeperIds: string[]): void {
  if (!io) return;
  const payload = {
    orderId: order._id?.toString(),
    orderNumber: order.orderNumber,
    acceptedBy: acceptedShopkeeperId,
    status: "Accepted",
    shopId: order.shopId?.toString(),
  };
  // Notify ALL vendors (including the accepting one, so they can update UI)
  for (const shopkeeperId of allShopkeeperIds) {
    const room = `vendor_${shopkeeperId}`;
    io.to(room).emit("order_accepted", payload);
  }
  console.log(`[Socket] Emitted order_accepted for order ${order.orderNumber}`);
}

/**
 * Emit an `order_rejected` event to keep dashboards in sync.
 */
export function emitOrderRejected(order: any, rejectedShopkeeperId: string, allShopkeeperIds: string[]): void {
  if (!io) return;
  const payload = {
    orderId: order._id?.toString(),
    orderNumber: order.orderNumber,
    rejectedBy: rejectedShopkeeperId,
    status: "Rejected",
  };
  for (const shopkeeperId of allShopkeeperIds) {
    io.to(`vendor_${shopkeeperId}`).emit("order_rejected", payload);
  }
  console.log(`[Socket] Emitted order_rejected for order ${order.orderNumber}`);
}

/**
 * Emit an `order_updated` event when order status changes (Preparing, OutForDelivery, Delivered, Cancelled).
 */
export function emitOrderUpdated(order: any): void {
  if (!io) return;
  const payload = buildOrderPayload(order);

  // Notify the vendor who accepted the order
  if (order.shopId) {
    const vendorRoom = `vendor_${order.shopId.toString()}`;
    io.to(vendorRoom).emit("order_updated", payload);
  }

  // Notify the customer
  const customerId =
    typeof order.customerId === "object"
      ? order.customerId._id?.toString()
      : order.customerId?.toString();
  if (customerId) {
    io.to(`customer_${customerId}`).emit("order_updated", payload);
  }

  console.log(`[Socket] Emitted order_updated for order ${order.orderNumber}`);
}

/**
 * Emit an `order_cancelled` event to all vendors who had visibility of the order.
 */
export function emitOrderCancelled(order: any, allShopkeeperIds: string[]): void {
  if (!io) return;
  const payload = {
    orderId: order._id?.toString(),
    orderNumber: order.orderNumber,
    status: "Cancelled",
  };
  for (const shopkeeperId of allShopkeeperIds) {
    io.to(`vendor_${shopkeeperId}`).emit("order_cancelled", payload);
  }

  // Also notify customer
  const customerId =
    typeof order.customerId === "object"
      ? order.customerId._id?.toString()
      : order.customerId?.toString();
  if (customerId) {
    io.to(`customer_${customerId}`).emit("order_updated", payload);
  }

  console.log(`[Socket] Emitted order_cancelled for order ${order.orderNumber}`);
}

/**
 * Initialize Socket.IO server with JWT authentication.
 * After authentication, users join their role-specific room:
 * - Customer → customer_<userId>
 * - Vendor   → vendor_<vendorId>
 */
export function initializeSocket(httpServer: HTTPServer): Server {
  io = new Server(httpServer, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"],
      credentials: true,
    },
    pingInterval: 10000,
    pingTimeout: 5000,
  });

  // Authentication middleware for Socket.IO
  io.use(async (socket: Socket, next) => {
    try {
      const token =
        socket.handshake.auth?.token ||
        socket.handshake.query?.token;

      if (!token || typeof token !== "string") {
        return next(new Error("Authentication required"));
      }

      const decoded = jwt.verify(token, JWT_SECRET) as Record<string, any>;

      if (!decoded || !decoded.id) {
        return next(new Error("Invalid token"));
      }

      // Attach user info to the socket
      (socket as any).user = {
        id: decoded.id,
        email: decoded.email,
        name: decoded.name,
        role: decoded.role,
      };

      next();
    } catch (error) {
      return next(new Error("Authentication failed"));
    }
  });

  io.on("connection", (socket: Socket) => {
    const user = (socket as any).user as {
      id: string;
      email: string;
      name: string;
      role: string;
    };

    console.log(
      `[Socket] ${user.name} (${user.role}) connected - ${socket.id}`
    );

    // Join role-specific room
    if (user.role === "Customer") {
      socket.join(`customer_${user.id}`);
      console.log(`[Socket] Joined room: customer_${user.id}`);
    } else if (user.role === "Shopkeeper") {
      socket.join(`vendor_${user.id}`);
      console.log(`[Socket] Joined room: vendor_${user.id}`);
    }

    // Handle manual reconnect by re-joining the room
    socket.on("join_room", (data: { role?: string; userId?: string }) => {
      const roomRole = data.role || user.role;
      const roomUserId = data.userId || user.id;

      if (roomRole === "Customer") {
        socket.join(`customer_${roomUserId}`);
      } else if (roomRole === "Shopkeeper") {
        socket.join(`vendor_${roomUserId}`);
      }
    });

    socket.on("disconnect", (reason: string) => {
      console.log(
        `[Socket] ${user.name} disconnected - ${socket.id} (${reason})`
      );
    });

    socket.on("error", (error: Error) => {
      console.error(`[Socket] Error for ${user.name}:`, error.message);
    });
  });

  console.log("[Socket] Socket.IO initialized successfully");
  return io;
}
