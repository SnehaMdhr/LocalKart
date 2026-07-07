import { Request, Response } from "express";
import {
  AcceptOrderDTO,
  CreateOrderDTO,
  UpdateOrderStatusDTO,
} from "../dtos/order.dtos";
import { OrderService } from "../services/order.service";

const orderService = new OrderService();

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

  async getPendingOrders(req: Request, res: Response) {
    try {
      const orders = await orderService.getPendingOrders(
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
      const order = await orderService.getOrderById(String(req.params.id));

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

  async acceptOrder(req: Request, res: Response) {
    try {
      const validatedData = AcceptOrderDTO.parse(req.body);

      const order = await orderService.acceptOrder(
        req.user!._id.toString(),
        String(req.params.id),
        validatedData
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
        req.user!._id.toString(),
        String(req.params.id)
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

  async updateStatus(req: Request, res: Response) {
    try {
      const validatedData = UpdateOrderStatusDTO.parse(req.body);

      const order = await orderService.updateStatus(
        String(req.params.id),
        validatedData
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