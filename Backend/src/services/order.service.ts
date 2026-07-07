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

    let totalAmount = 0;

    const items = cart.items.map((item: any) => {
      const product = item.productId;

      totalAmount += product.price * item.quantity;

      return {
        productId: product._id,
        productName: product.productName,
        price: product.price,
        quantity: item.quantity,
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
}