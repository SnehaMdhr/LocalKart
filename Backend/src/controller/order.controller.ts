import { Request, Response } from "express";
import {
  CreateOrderDto,
  UpdateOrderStatusDto,
} from "../dtos/order.dtos";
import { OrderService } from "../services/order.service";

const orderService = new OrderService();

export class OrderController {
  async createOrder(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();

      const validatedData = CreateOrderDto.parse(req.body);

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

  async getMyOrders(req: Request, res: Response) {
    try {
      const orders = await orderService.getMyOrders(
        req.user!._id.toString()
      );

      return res.status(200).json({
        success: true,
        data: orders,
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
      const order = await orderService.getOrderById(
        req.params.id as string,
        req.user!._id.toString(),
        req.user!.role
      );

      return res.status(200).json({
        success: true,
        data: order,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async updateOrderStatus(req: Request, res: Response) {
    try {
      const validatedData = UpdateOrderStatusDto.parse(req.body);

      const order = await orderService.updateStatus(
        req.params.id as string,
        validatedData,
        req.user!._id.toString()
      );

      return res.status(200).json({
        success: true,
        message: "Order status updated successfully",
        data: order,
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
      const order = await orderService.acceptOrder(
        req.params.id as string,
        req.user!._id.toString()
      );

      return res.status(200).json({
        success: true,
        message: "Order accepted successfully",
        data: order,
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
        req.params.id as string,
        req.user!._id.toString()
      );

      return res.status(200).json({
        success: true,
        message: "Order rejected successfully",
        data: order,
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

      return res.status(200).json({
        success: true,
        data: orders,
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
      await orderService.deleteOrder(req.params.id as string);

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