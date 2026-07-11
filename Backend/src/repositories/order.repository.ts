import { Types } from "mongoose";
import { IOrder, OrderModel } from "../model/order.model";

export interface IOrderRepository {
  createOrder(orderData: Partial<IOrder>): Promise<IOrder>;

  getOrderById(id: string): Promise<IOrder | null>;

  getOrdersByCustomer(customerId: string): Promise<IOrder[]>;

  getOrdersByShop(shopId: string): Promise<IOrder[]>;

  getPendingOrders(shopId: string): Promise<IOrder[]>;

  getAllOrders(page: number, size: number, status?: string, paymentStatus?: string): Promise<{ orders: IOrder[]; total: number }>;

  updateOrder(
    id: string,
    updateData: Partial<IOrder>
  ): Promise<IOrder | null>;

  deleteOrder(id: string): Promise<boolean>;

  acceptOrder(
    orderId: string,
    shopId: string,
    estimatedDeliveryTime?: number
  ): Promise<IOrder | null>;

  rejectOrder(
    orderId: string,
    shopId: string
  ): Promise<IOrder | null>;
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

  async getOrdersByCustomer(customerId: string): Promise<IOrder[]> {
    return OrderModel.find({
      customerId: new Types.ObjectId(customerId),
    })
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId")
      .sort({ createdAt: -1 });
  }

  async getOrdersByShop(shopId: string): Promise<IOrder[]> {
    return OrderModel.find({
      shopId: new Types.ObjectId(shopId),
    })
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId")
      .sort({ createdAt: -1 });
  }

  async getPendingOrders(shopId: string): Promise<IOrder[]> {
    return OrderModel.find({
      shopId: null,
      status: "Pending",
      rejectedBy: {
        $ne: new Types.ObjectId(shopId),
      },
    })
      .populate("customerId")
      .populate("items.productId")
      .sort({ createdAt: -1 });
  }

  async getAllOrders(
    page: number,
    size: number,
    status?: string,
    paymentStatus?: string
  ): Promise<{ orders: IOrder[]; total: number }> {
    const query: any = {};

    if (status) {
      query.status = status;
    }

    if (paymentStatus) {
      query.paymentStatus = paymentStatus;
    }

    const total = await OrderModel.countDocuments(query);
    const orders = await OrderModel.find(query)
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId")
      .sort({ createdAt: -1 })
      .skip((page - 1) * size)
      .limit(size);

    return { orders, total };
  }

  async updateOrder(
    id: string,
    updateData: Partial<IOrder>
  ): Promise<IOrder | null> {
    return OrderModel.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true,
    })
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId");
  }

  async deleteOrder(id: string): Promise<boolean> {
    const result = await OrderModel.findByIdAndDelete(id);
    return result ? true : false;
  }

  async acceptOrder(
    orderId: string,
    shopId: string,
    estimatedDeliveryTime?: number
  ): Promise<IOrder | null> {
    return OrderModel.findOneAndUpdate(
      {
        _id: orderId,
        shopId: null,
        status: "Pending",
      },
      {
        shopId: new Types.ObjectId(shopId),
        status: "Accepted",
        estimatedDeliveryTime,
      },
      {
        new: true,
      }
    )
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId");
  }

  async rejectOrder(
    orderId: string,
    shopId: string
  ): Promise<IOrder | null> {
    return OrderModel.findByIdAndUpdate(
      orderId,
      {
        $addToSet: {
          rejectedBy: new Types.ObjectId(shopId),
        },
      },
      {
        new: true,
      }
    )
      .populate("customerId")
      .populate("shopId")
      .populate("items.productId");
  }
}