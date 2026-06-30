import mongoose from "mongoose";
import { CreateOrderDto, UpdateOrderStatusDto } from "../dtos/order.dtos";
import { HttpError } from "../errors/https-error";
import { IOrder } from "../model/order.model";
import { CartRepository } from "../repositories/cart.repository";
import { OrderRepository } from "../repositories/order.repository";
import { ShopRepository } from "../repositories/shop.repository";

const orderRepository = new OrderRepository();
const cartRepository = new CartRepository();
const shopRepository = new ShopRepository();

export class OrderService {
  async createOrder(
    userId: string,
    data: CreateOrderDto
  ): Promise<IOrder> {
    const cart = await cartRepository.getCartByUserId(userId);

    if (!cart) {
      throw new HttpError(404, "Cart not found");
    }

    if (cart.items.length === 0) {
      throw new HttpError(400, "Cart is empty");
    }

    let totalAmount = 0;

    for (const item of cart.items) {
      // item.productId is populated by cart repository, so it's a full product document
      const product = item.productId as any;

      if (!product || !product._id) {
        throw new HttpError(404, "Product not found in cart");
      }

      const price = Number(product.price);
      if (isNaN(price) || price <= 0) {
        throw new HttpError(400, `Product "${product.productName || product._id}" has an invalid price`);
      }

      totalAmount += price * item.quantity;
    }

    // Map items to plain objects to avoid passing populated Mongoose documents
    const plainItems = cart.items.map((item) => ({
      productId: (item.productId as any)._id || item.productId,
      quantity: item.quantity,
    }));

    const order = await orderRepository.createOrder({
      customerId: new mongoose.Types.ObjectId(userId),
      shopId: null,
      items: plainItems,
      totalAmount,
      deliveryAddress: data.deliveryAddress,
      paymentMethod: data.paymentMethod,
      paymentStatus: "Pending",
      status: "Pending",
    });

    await cartRepository.clearCart(cart._id.toString());

    return order;
  }

  async getMyOrders(userId: string): Promise<IOrder[]> {
    return orderRepository.getOrdersByCustomerId(userId);
  }

  async getOrderById(orderId: string, userId: string, userRole: string): Promise<IOrder> {
    const order = await orderRepository.getOrderById(orderId);

    if (!order) {
      throw new HttpError(404, "Order not found");
    }

    // Customers can only view their own orders
    if (userRole === "Customer") {
      if (order.customerId._id.toString() !== userId && order.customerId.toString() !== userId) {
        throw new HttpError(403, "Forbidden: You can only view your own orders");
      }
    }

    // Shopkeepers can only view orders assigned to their shop
    if (userRole === "Shopkeeper") {
      const shop = await shopRepository.getShopByUserId(userId);
      if (!shop) {
        throw new HttpError(403, "Forbidden: No shop associated with your account");
      }
      if (!order.shopId || (order.shopId._id ? order.shopId._id.toString() !== shop._id.toString() : order.shopId.toString() !== shop._id.toString())) {
        throw new HttpError(403, "Forbidden: This order is not assigned to your shop");
      }
    }

    return order;
  }

  async updateStatus(
    orderId: string,
    data: UpdateOrderStatusDto,
    userId: string
  ): Promise<IOrder> {
    const order = await orderRepository.getOrderById(orderId);

    if (!order) {
      throw new HttpError(404, "Order not found");
    }

    // Verify the shopkeeper owns the shop assigned to this order
    const shop = await shopRepository.getShopByUserId(userId);
    if (!shop) {
      throw new HttpError(403, "Forbidden: No shop associated with your account");
    }

    const orderShopId = order.shopId
      ? (order.shopId._id ? order.shopId._id.toString() : order.shopId.toString())
      : null;

    if (!orderShopId || orderShopId !== shop._id.toString()) {
      throw new HttpError(403, "Forbidden: This order is not assigned to your shop");
    }

    const updatedOrder = await orderRepository.updateOrderStatus(
      orderId,
      data.status
    );

    if (!updatedOrder) {
      throw new HttpError(404, "Order not found");
    }

    return updatedOrder;
  }

  async acceptOrder(
    orderId: string,
    userId: string
  ): Promise<IOrder> {
    // Look up the shop belonging to this shopkeeper
    const shop = await shopRepository.getShopByUserId(userId);

    if (!shop) {
      throw new HttpError(403, "Forbidden: No shop associated with your account");
    }

    const order = await orderRepository.updateOrder(orderId, {
      shopId: shop._id,
      status: "Accepted",
    });

    if (!order) {
      throw new HttpError(404, "Order not found");
    }

    return order;
  }

  async rejectOrder(
    orderId: string,
    userId: string
  ): Promise<IOrder> {
    // Look up the shop belonging to this shopkeeper
    const shop = await shopRepository.getShopByUserId(userId);

    if (!shop) {
      throw new HttpError(403, "Forbidden: No shop associated with your account");
    }

    const order = await orderRepository.updateOrder(orderId, {
      shopId: shop._id,
      status: "Rejected",
    });

    if (!order) {
      throw new HttpError(404, "Order not found");
    }

    return order;
  }

  async deleteOrder(orderId: string): Promise<void> {
    const deleted = await orderRepository.deleteOrder(orderId);

    if (!deleted) {
      throw new HttpError(404, "Order not found");
    }
  }
}