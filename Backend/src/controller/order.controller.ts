import { Request, Response } from "express";
import {
  AcceptOrderDTO,
  CreateOrderDTO,
  UpdateOrderStatusDTO,
} from "../dtos/order.dtos";
import { OrderService } from "../services/order.service";
import { ShopModel } from "../model/shop.model";
import { IOrder } from "../model/order.model";

const orderService = new OrderService();

/**
 * Attach shop details (shopName, address) to an order's JSON response.
 * shopId references User, so we look up the Shop document by userId.
 */
async function attachShopDetails(order: IOrder) {
  const orderObj = order.toObject();
  const shopIdField = orderObj.shopId;
  if (shopIdField) {
    // shopId could be a populated User object or an ObjectId
    const shopUserId =
      typeof shopIdField === "object" && "_id" in shopIdField
        ? shopIdField._id
        : shopIdField;
    const shop = await ShopModel.findOne({ userId: shopUserId });
    if (shop) {
      (orderObj as any).shopDetails = {
        shopName: shop.shopName,
        address: shop.address,
      };
    }
  }
  return orderObj;
}

async function attachShopDetailsToOrders(orders: IOrder[]) {
  return Promise.all(orders.map(attachShopDetails));
}

export class OrderController {
  async createOrder(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();

      const validatedData = CreateOrderDTO.parse(req.body);

      const order = await orderService.createOrder(
        userId,
        validatedData
      );

      return res.status(201).json({
        success: true,
        message: "Order placed successfully",
        data: order,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getCustomerOrders(req: Request, res: Response) {
    try {
      const orders = await orderService.getCustomerOrders(
        req.user!._id.toString()
      );

      const enriched = await attachShopDetailsToOrders(orders);

      return res.status(200).json({
        success: true,
        data: enriched,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getShopOrders(req: Request, res: Response) {
    try {
      const orders = await orderService.getShopOrders(
        req.user!._id.toString()
      );

      const enriched = await attachShopDetailsToOrders(orders);

      return res.status(200).json({
        success: true,
        data: enriched,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getPendingOrders(req: Request, res: Response) {
    try {
      const orders = await orderService.getPendingOrders(
        req.user!._id.toString()
      );

      const enriched = await attachShopDetailsToOrders(orders);

      return res.status(200).json({
        success: true,
        data: enriched,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getOrderById(req: Request, res: Response) {
    try {
      const order = await orderService.getOrderById(String(req.params.id));

      const enriched = order.shopId ? await attachShopDetails(order) : order.toObject();

      return res.status(200).json({
        success: true,
        data: enriched,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async acceptOrder(req: Request, res: Response) {
    try {
      const validatedData = AcceptOrderDTO.parse(req.body);

      const order = await orderService.acceptOrder(
        req.user!._id.toString(),
        String(req.params.id),
        validatedData
      );

      const enriched = order.shopId ? await attachShopDetails(order) : order.toObject();

      return res.status(200).json({
        success: true,
        message: "Order accepted successfully",
        data: enriched,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async rejectOrder(req: Request, res: Response) {
    try {
      const order = await orderService.rejectOrder(
        req.user!._id.toString(),
        String(req.params.id)
      );

      const enriched = order.shopId ? await attachShopDetails(order) : order.toObject();

      return res.status(200).json({
        success: true,
        message: "Order rejected successfully",
        data: enriched,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async updateStatus(req: Request, res: Response) {
    try {
      const validatedData = UpdateOrderStatusDTO.parse(req.body);

      const order = await orderService.updateStatus(
        String(req.params.id),
        validatedData
      );

      const enriched = order.shopId ? await attachShopDetails(order) : order.toObject();

      return res.status(200).json({
        success: true,
        message: "Order status updated successfully",
        data: enriched,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async deleteOrder(req: Request, res: Response) {
    try {
      await orderService.deleteOrder(String(req.params.id));

      return res.status(200).json({
        success: true,
        message: "Order deleted successfully",
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }
}