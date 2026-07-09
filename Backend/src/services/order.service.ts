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

const orderRepository = new OrderRepository();
const cartRepository = new CartRepository();

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

    return updated;
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