import { Request, Response } from "express";
import {
  CreateCollectionDto,
  UpdateCollectionDto,
} from "../dtos/collection.dtos";
import { CollectionService } from "../services/collection.service";

const collectionService = new CollectionService();

export class CollectionController {
  async createCollection(req: Request, res: Response) {
    try {
      const userId = req.user?._id?.toString();

      const validatedData = CreateCollectionDto.parse(req.body);

      const collection = await collectionService.createCollection(
        userId,
        validatedData,
      );

      return res.status(201).json({
        success: true,
        message: "Collection created successfully",
        data: collection,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getMyCollections(req: Request, res: Response) {
    try {
      const collections = await collectionService.getMyCollections(
        req.user!._id.toString(),
      );

      return res.status(200).json({
        success: true,
        data: collections,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async getCollectionById(req: Request, res: Response) {
    try {
      const collection = await collectionService.getCollectionById(
        req.params.id as string,
      );

      return res.status(200).json({
        success: true,
        data: collection,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async updateCollection(req: Request, res: Response) {
    try {
      const collectionId = req.params.id as string;

      const validatedData = UpdateCollectionDto.parse(req.body);

      const collection = await collectionService.updateCollection(
        collectionId,
        req.user!._id.toString(),
        validatedData,
      );

      return res.status(200).json({
        success: true,
        message: "Collection updated successfully",
        data: collection,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async deleteCollection(req: Request, res: Response) {
    try {
      const collectionId = req.params.id as string;
      const userId = req.user!._id.toString();

      await collectionService.deleteCollection(collectionId, userId);

      return res.status(200).json({
        success: true,
        message: "Collection deleted successfully",
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async addProduct(req: Request, res: Response) {
    try {
      const collectionId = req.params.id as string;

      const productId = req.body.productId;

      const collection = await collectionService.addProductToCollection(
        collectionId,
        req.user!._id.toString(),
        productId,
      );

      return res.status(200).json({
        success: true,
        message: "Product added successfully",
        data: collection,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async removeProduct(req: Request, res: Response) {
    try {
      const collectionId = req.params.id as string;
      const productId = req.body.productId;

      const collection = await collectionService.removeProductFromCollection(
        collectionId,
        req.user!._id.toString(),
        productId,
      );

      return res.status(200).json({
        success: true,
        message: "Product removed successfully",
        data: collection,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }
}
