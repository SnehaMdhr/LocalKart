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
