import { Request, Response } from "express";
import {
  AddToCartDto,
  UpdateQuantityDto,
} from "../dtos/cart.dtos";
import { CartService } from "../services/cart.service";

const cartService = new CartService();

export class CartController {
  async addToCart(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();

      const validatedData = AddToCartDto.parse(req.body);

      const cart = await cartService.addToCart(userId, validatedData);

      return res.status(200).json({
        success: true,
        message: "Product added to cart successfully",
        data: cart,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getCart(req: Request, res: Response) {
    try {
      const cart = await cartService.getCart(req.user!._id.toString());

      return res.status(200).json({
        success: true,
        data: cart,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async updateQuantity(req: Request, res: Response) {
    try {
      const validatedData = UpdateQuantityDto.parse(req.body);

      const cart = await cartService.updateQuantity(
        req.user!._id.toString(),
        validatedData
      );

      return res.status(200).json({
        success: true,
        message: "Cart updated successfully",
        data: cart,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async removeFromCart(req: Request, res: Response) {
    try {
      const cart = await cartService.removeFromCart(
        req.user!._id.toString(),
        req.params.productId as string
      );

      return res.status(200).json({
        success: true,
        message: "Product removed from cart successfully",
        data: cart,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async clearCart(req: Request, res: Response) {
    try {
      const cart = await cartService.clearCart(req.user!._id.toString());

      return res.status(200).json({
        success: true,
        message: "Cart cleared successfully",
        data: cart,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }
}