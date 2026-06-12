import { Request, Response } from "express";
import { ShopService } from "../services/shop.service";
import { CreateShopDto, UpdateShopDto } from "../dtos/shop.dtos";

const shopService = new ShopService();

export class ShopController {

  async createShop(req: Request, res: Response) {
    try {
      const validatedData = CreateShopDto.parse({
        ...req.body,
        imageUrl: req.file
          ? `/uploads/${req.file.filename}`
          : undefined,
      });

      const shop = await shopService.createShop(
        req.user!._id.toString(),
        validatedData
      );

      return res.status(201).json({
        success: true,
        message: "Shop registration submitted successfully",
        data: shop,
      });

    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getMyShop(req: Request, res: Response) {
    try {
      const shop = await shopService.getMyShop(
        req.user!._id.toString()
      );

      return res.status(200).json({
        success: true,
        data: shop,
      });

    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getShopById(req: Request, res: Response) {
    try {
      const shop = await shopService.getShopById(
        req.params.id as string
      );

      return res.status(200).json({
        success: true,
        data: shop,
      });

    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getAllShops(req: Request, res: Response) {
    try {
      const shops = await shopService.getAllShops();

      return res.status(200).json({
        success: true,
        data: shops,
      });

    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getPaginatedShops(req: Request, res: Response) {
    try {
      const page = Number(req.query.page) || 1;
      const size = Number(req.query.size) || 10;
      const search = req.query.search as string;

      const result =
        await shopService.getPaginatedShops(
          page,
          size,
          search
        );

      return res.status(200).json({
        success: true,
        ...result,
      });

    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async updateShop(req: Request, res: Response) {
    try {
      const validatedData = UpdateShopDto.parse({
        ...req.body,
        ...(req.file && {
          imageUrl: `/uploads/${req.file.filename}`,
        }),
      });

      const shop = await shopService.updateShop(
        req.user!._id.toString(),
        validatedData
      );

      return res.status(200).json({
        success: true,
        message: "Shop updated successfully",
        data: shop,
      });

    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async deleteShop(req: Request, res: Response) {
    try {
      await shopService.deleteShop(
        req.params.id as string
      );

      return res.status(200).json({
        success: true,
        message: "Shop deleted successfully",
      });

    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async approveShop(req: Request, res: Response) {
    try {
      const shop = await shopService.approveShop(
        req.params.id as string
      );

      return res.status(200).json({
        success: true,
        message: "Shop approved successfully",
        data: shop,
      });

    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async rejectShop(req: Request, res: Response) {
    try {
      const shop = await shopService.rejectShop(
        req.params.id as string
      );

      return res.status(200).json({
        success: true,
        message: "Shop rejected successfully",
        data: shop,
      });

    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async suspendShop(req: Request, res: Response) {
    try {
      const shop = await shopService.suspendShop(
        req.params.id as string
      );

      return res.status(200).json({
        success: true,
        message: "Shop suspended successfully",
        data: shop,
      });

    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }
}