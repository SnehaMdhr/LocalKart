import mongoose from "mongoose";
import {
  AcceptOrderDTO,
  CreateOrderDTO,
  UpdateOrderStatusDTO,
} from "../dtos/order.dtos";
import { HttpError } from "../errors/https-error";
import { IOrder } from "../model/order.model";
import { OrderRepository } from "../repositories/order.repository";
import { CartRepository } from "../repositories/cart.repository";
import { ShopModel } from "../model/shop.model";
import { calculateDistance, estimateDeliveryTime } from "../utils/distance.util";
import { NotificationService } from "./notification.service";
import { UserModel } from "../model/user.model";

/**
 * Safely extract a MongoDB ObjectId string from a field that may be:
 * - Already a string (raw ID)
 * - A Mongoose ObjectId
 * - A populated document (object with _id)
 */
function extractId(value: any): string {
  if (!value) {
    throw new Error(`Cannot extract ID from null/undefined value`);
  }
  if (typeof value === "string" && /^[a-fA-F0-9]{24}$/.test(value)) {
    return value;
  }
  if (typeof value === "object" && value._id) {
    return value._id.toString();
  }
  return value.toString();
}

const orderRepository = new OrderRepository();
const cartRepository = new CartRepository();
const notificationService = new NotificationService();

export class OrderService {
  private generateOrderNumber() {
    return `LK${Date.now()}`;
  }

  async createOrder(
    customerId: string,
    data: CreateOrderDTO
  ): Promise<IOrder> {
    const cart = await cartRepository.getCartByUserId(customerId);

    if (!cart || cart.items.length === 0) {
      throw new HttpError(400, "Cart is empty");
    }

    // Merge duplicate cart items by productId to prevent duplicate entries
    const mergedMap = new Map<string, { product: any; quantity: number }>();
    for (const item of cart.items) {
      const product: any = item.productId;
      const key = product._id.toString();
      if (mergedMap.has(key)) {
        mergedMap.get(key)!.quantity += item.quantity;
      } else {
        mergedMap.set(key, { product, quantity: item.quantity });
      }
    }

    let totalAmount = 0;
    const items = Array.from(mergedMap.values()).map(({ product, quantity }) => {
      totalAmount += product.price * quantity;
      return {
        productId: product._id,
        productName: product.productName,
        price: product.price,
        quantity,
      };
    });

    const order = await orderRepository.createOrder({
      customerId: new mongoose.Types.ObjectId(customerId),

      orderNumber: this.generateOrderNumber(),

      items,

      deliveryAddress: data.deliveryAddress,

      totalAmount,

      paymentMethod: data.paymentMethod,

      paymentStatus: "Pending",

      status: "Pending",

      rejectedBy: [],

      customerNote: data.customerNote,
    });

    await cartRepository.clearCart(cart._id.toString());

    // ── Send ORDER_PLACED to customer ──
    const customer = await UserModel.findById(customerId);
    const customerName = customer?.name || "Customer";

    try {
      await notificationService.sendNotification({
        receiverId: customerId,
        receiverRole: "Customer",
        title: "Order Placed Successfully",
        message: `Your order #${order.orderNumber} has been placed successfully! We are looking for a nearby shop to fulfill it.`,
        type: "ORDER_PLACED",
        orderId: order._id.toString(),
        orderNumber: order.orderNumber,
      });
    } catch (error) {
      console.error("Failed to send ORDER_PLACED notification:", error);
    }

    // ── Send "New Order Received" to all approved shopkeepers ──
    try {
      const approvedShops = await ShopModel.find({ status: "approved" }).populate("userId");

      for (const shop of approvedShops) {
        const shopkeeperId = (shop.userId as any)?._id?.toString();
        if (!shopkeeperId) continue;

        const shopDoc = await ShopModel.findById(shop._id);
        const shopName = shopDoc?.shopName || '';

        await notificationService.sendNotification({
          receiverId: shopkeeperId,
          receiverRole: "Vendor",
          title: "New Order Received",
          message: `Order #${order.orderNumber} | Customer: ${customerName} | Items: ${items.length} | Amount: Rs. ${totalAmount}`,
          type: "ORDER_PLACED",
          orderId: order._id.toString(),
          orderNumber: order.orderNumber,
          shopName: shopName,
        });
      }
    } catch (error) {
      console.error("Failed to notify vendors about new order:", error);
    }

    return order;
  }

  async getCustomerOrders(
    customerId: string
  ): Promise<IOrder[]> {
    return orderRepository.getOrdersByCustomer(customerId);
  }

  async getShopOrders(shopId: string): Promise<IOrder[]> {
    return orderRepository.getOrdersByShop(shopId);
  }

  async getPendingOrders(shopId: string): Promise<IOrder[]> {
    return orderRepository.getPendingOrders(shopId);
  }

  async getOrderById(orderId: string): Promise<IOrder> {
    const order = await orderRepository.getOrderById(orderId);

    if (!order) {
      throw new HttpError(404, "Order not found");
    }

    return order;
  }

  async acceptOrder(
    shopId: string,
    orderId: string,
    data: AcceptOrderDTO
  ): Promise<IOrder> {
    const updated = await orderRepository.acceptOrder(
      orderId,
      shopId,
      data.estimatedDeliveryTime
    );

    if (!updated) {
      throw new HttpError(
        400,
        "Order already accepted or unavailable"
      );
    }

    // ── Send ORDER_ACCEPTED to customer ──
    try {
      const shop = await ShopModel.findOne({ userId: new mongoose.Types.ObjectId(shopId) });
      const shopName = shop?.shopName || "Shop";

      await notificationService.sendNotification({
        receiverId: extractId(updated.customerId),
        receiverRole: "Customer",
        title: "Order Accepted",
        message: `Great news! Your order #${updated.orderNumber} from ${shopName} has been accepted and is being prepared.`,
        type: "ORDER_ACCEPTED",
        orderId: updated._id.toString(),
        shopId: shopId,
        orderNumber: updated.orderNumber,
        shopName: shopName,
      });
    } catch (error) {
      console.error("Failed to send ORDER_ACCEPTED notification:", error);
    }

    return updated;
  }

  async rejectOrder(
    shopId: string,
    orderId: string
  ): Promise<IOrder> {
    const updated = await orderRepository.rejectOrder(
      orderId,
      shopId
    );

    if (!updated) {
      throw new HttpError(404, "Order not found");
    }

    // ── Send ORDER_REJECTED to customer ──
    try {
      const shop = await ShopModel.findOne({ userId: new mongoose.Types.ObjectId(shopId) });
      const shopName = shop?.shopName || "A shop";

      await notificationService.sendNotification({
        receiverId: extractId(updated.customerId),
        receiverRole: "Customer",
        title: "Order Rejected",
        message: `Unfortunately, ${shopName} has declined your order #${updated.orderNumber}. Don't worry — other shops may still accept it.`,
        type: "ORDER_REJECTED",
        orderId: updated._id.toString(),
        shopId: shopId,
        orderNumber: updated.orderNumber,
        shopName: shopName,
      });
    } catch (error) {
      console.error("Failed to send ORDER_REJECTED notification:", error);
    }

    return updated;
  }

  async updateStatus(
    orderId: string,
    data: UpdateOrderStatusDTO
  ): Promise<IOrder> {
    const updated = await orderRepository.updateOrder(orderId, {
      status: data.status,
    });

    if (!updated) {
      throw new HttpError(404, "Order not found");
    }

    const customerId = extractId(updated.customerId);
    const orderNumber = updated.orderNumber;

    // ── Send status-specific notifications to customer ──
    switch (data.status) {
      case "Preparing":
        try {
          await notificationService.sendNotification({
            receiverId: customerId,
            receiverRole: "Customer",
            title: "Preparing Your Order",
            message: `Your order #${orderNumber} is now being prepared. We'll let you know when it's on the way!`,
            type: "ORDER_PREPARING",
            orderId: orderId,
            orderNumber: orderNumber,
          });
        } catch (error) {
          console.error("Failed to send ORDER_PREPARING notification:", error);
        }
        break;

      case "Out for Delivery":
        try {
          const etdText = updated.estimatedDeliveryTime
            ? ` Est. delivery: ~${updated.estimatedDeliveryTime} min.`
            : "";
          await notificationService.sendNotification({
            receiverId: customerId,
            receiverRole: "Customer",
            title: "Out for Delivery",
            message: `Your order #${orderNumber} is on the way!${etdText}`,
            type: "OUT_FOR_DELIVERY",
            orderId: orderId,
            orderNumber: orderNumber,
          });
        } catch (error) {
          console.error("Failed to send OUT_FOR_DELIVERY notification:", error);
        }
        break;

      case "Delivered":
        try {
          await notificationService.sendNotification({
            receiverId: customerId,
            receiverRole: "Customer",
            title: "Order Delivered",
            message: `Your order #${orderNumber} has been delivered. Enjoy your groceries!`,
            type: "DELIVERED",
            orderId: orderId,
            orderNumber: orderNumber,
          });
        } catch (error) {
          console.error("Failed to send DELIVERED notification:", error);
        }
        break;

      case "Cancelled":
        try {
          // Notify customer
          await notificationService.sendNotification({
            receiverId: customerId,
            receiverRole: "Customer",
            title: "Order Cancelled",
            message: `Your order #${orderNumber} has been cancelled.`,
            type: "ORDER_CANCELLED",
            orderId: orderId,
            orderNumber: orderNumber,
          });

          // Notify vendor if a shop had accepted the order
          if (updated.shopId) {
            await notificationService.sendNotification({
              receiverId: extractId(updated.shopId),
              receiverRole: "Vendor",
              title: "Customer Cancelled Order",
              message: `Customer has cancelled order #${orderNumber}.`,
              type: "ORDER_CANCELLED",
              orderId: orderId,
              orderNumber: orderNumber,
            });
          }
        } catch (error) {
          console.error("Failed to send ORDER_CANCELLED notification:", error);
        }
        break;
    }

    return updated;
  }

  async deleteOrder(orderId: string): Promise<void> {
    const deleted = await orderRepository.deleteOrder(orderId);

    if (!deleted) {
      throw new HttpError(404, "Order not found");
    }
  }

  async markOrderPaid(orderId: string): Promise<IOrder> {
    const updated = await orderRepository.updateOrder(orderId, {
      paymentStatus: "Paid",
    });

    if (!updated) {
      throw new HttpError(404, "Order not found");
    }

    // Notify customer about payment confirmation
    try {
      await notificationService.sendNotification({
        receiverId: extractId(updated.customerId),
        receiverRole: "Customer",
        title: "Payment Confirmed",
        message: `Payment for order #${updated.orderNumber} has been confirmed successfully.`,
        type: "SYSTEM",
        orderId: orderId,
        orderNumber: updated.orderNumber,
      });
    } catch (error) {
      console.error("Failed to send payment confirmation notification:", error);
    }

    return updated;
  }

  async getAllOrdersForAdmin(
    page: number,
    size: number,
    status?: string,
    paymentStatus?: string
  ) {
    const { orders, total } = await orderRepository.getAllOrders(
      page,
      size,
      status,
      paymentStatus
    );

    return {
      data: orders,
      pagination: {
        page,
        size,
        total,
        totalPages: Math.ceil(total / size),
      },
    };
  }

  async getEtd(orderId: string): Promise<{ distance: number | null; estimatedMinutes: number | null; available: boolean; reason?: string }> {
    const order = await orderRepository.getOrderById(orderId);

    if (!order) {
      throw new HttpError(404, "Order not found");
    }

    // Get customer delivery coordinates from the order
    const deliveryAddr = order.deliveryAddress as any;
    const custLat = deliveryAddr?.latitude;
    const custLng = deliveryAddr?.longitude;

    if (custLat == null || custLng == null) {
      return {
        distance: null,
        estimatedMinutes: null,
        available: false,
        reason: "Customer delivery location coordinates missing from this order"
      };
    }

    // Find the shop that accepted this order
    const shopUserId = order.shopId;
    if (!shopUserId) {
      return {
        distance: null,
        estimatedMinutes: null,
        available: false,
        reason: "Order not yet accepted by any shop"
      };
    }

    const shop = await ShopModel.findOne({ userId: shopUserId });
    if (!shop) {
      return {
        distance: null,
        estimatedMinutes: null,
        available: false,
        reason: "Shop profile not found for this vendor"
      };
    }

    const shopLat = shop.latitude;
    const shopLng = shop.longitude;

    if (shopLat == null || shopLng == null) {
      return {
        distance: null,
        estimatedMinutes: null,
        available: false,
        reason: "Shop location not set. Vendor needs to update their shop with a map location."
      };
    }

    const distance = calculateDistance(custLat, custLng, shopLat, shopLng);
    const estimatedMinutes = estimateDeliveryTime(distance);

    return { distance, estimatedMinutes, available: true };
  }
}