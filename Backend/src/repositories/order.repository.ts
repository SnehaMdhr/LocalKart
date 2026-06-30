import mongoose, { Types } from "mongoose";
import { IOrder, OrderModel } from "../model/order.model";

export interface IOrderRepository {
  createOrder(orderData: Partial<IOrder>): Promise<IOrder>;

  getOrderById(id: string): Promise<IOrder | null>;

  getOrdersByCustomerId(customerId: string): Promise<IOrder[]>;

  getOrdersByShopId(shopId: string): Promise<IOrder[]>;

  getAllOrders(): Promise<IOrder[]>;

  updateOrder(
    id: string,
    updateData: Partial<IOrder>,
  ): Promise<IOrder | null>;

  updateOrderStatus(
    id: string,
    status: string,
  ): Promise<IOrder | null>;

  deleteOrder(id: string): Promise<boolean>;
}

export class OrderRepository implements IOrderRepository {
  async createOrder(orderData: Partial<IOrder>): Promise<IOrder> {
    const order = new OrderModel(orderData);
    return await order.save();
  }

  async getOrderById(id: string): Promise<IOrder | null> {
    return OrderModel.findById(id)
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId");
  }

  async getOrdersByCustomerId(customerId: string): Promise<IOrder[]> {
    return OrderModel.find({
      customerId: new Types.ObjectId(customerId),
    })
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId");
  }

  async getOrdersByShopId(shopId: string): Promise<IOrder[]> {
    return OrderModel.find({
      shopId: new Types.ObjectId(shopId),
    })
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId");
  }

  async getAllOrders(): Promise<IOrder[]> {
    return OrderModel.find()
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId");
  }

  async updateOrder(
    id: string,
    updateData: Partial<IOrder>,
  ): Promise<IOrder | null> {
    return OrderModel.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true,
    })
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId");
  }

  async updateOrderStatus(
    id: string,
    status: string,
  ): Promise<IOrder | null> {
    return OrderModel.findByIdAndUpdate(
      id,
      {
        $set: { status },
      },
      {
        new: true,
      },
    )
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId");
  }

  async deleteOrder(id: string): Promise<boolean> {
    const result = await OrderModel.findByIdAndDelete(id);
    return result ? true : false;
  }
}