import { Request, Response } from "express";
import {
  CreateProductDto,
  UpdateProductDto,
} from "../dtos/product.dtos";
import { ProductService } from "../services/product.service";

const productService = new ProductService();

export class ProductController {

  async getProductsByIdAdmin(
    req: Request,
    res: Response
  ) {
    try {

      const product =
        await productService.getProductsByIdAdmin(
          req.params.id as string
        );

      return res.status(200).json({
        success: true,
        data: product,
      });

    } catch (error: any) {

      return res.status(
        error.statusCode ?? 500
      ).json({
        success: false,
        message: error.message,
      });

    }
  }

  async getAllProductsForAdmin(
    req: Request,
    res: Response
  ) {
    try {

      const page =
        Number(req.query.page) || 1;

      const size =
        Number(req.query.size) || 10;

      const search =
        req.query.search as string;

      const result =
        await productService.getAllPaginatedForAdmin(
          page,
          size,
          search
        );

      return res.status(200).json({
        success: true,
        ...result,
      });

    } catch (error: any) {

      return res.status(
        error.statusCode ?? 500
      ).json({
        success: false,
        message: error.message,
      });

    }
  }
  async getAllPaginatedForAdmin(
    req: Request,
    res: Response  ) {
    try {
      const page =    Number(req.query.page) || 1;
      const size =    Number(req.query.size) || 10;
      const search =  req.query.search as string;

      const result = await productService.getAllPaginatedForAdmin(
        page,
        size,
        search
      );

      return res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error: any) {
      return res.status(
        error.statusCode ?? 500
      ).json({
        success: false,
        message: error.message,
      });
    }
  }

  async createProduct(
    req: Request,
    res: Response
  ) {
    try {

      const validatedData =
        CreateProductDto.parse({
          ...req.body,
          imageUrl: req.file
            ? `/uploads/${req.file.filename}`
            : undefined,
        });

      const product =
        await productService.createProduct(
          validatedData
        );

      return res.status(201).json({
        success: true,
        message: "Product created successfully",
        data: product,
      });

    } catch (error: any) {

      return res.status(
        error.statusCode ?? 500
      ).json({
        success: false,
        message: error.message,
      });

    }
  }

  async getProductById(
    req: Request,
    res: Response
  ) {
    try {

      const product =
        await productService.getProductById(
          req.params.id as string
        );

      return res.status(200).json({
        success: true,
        data: product,
      });

    } catch (error: any) {

      return res.status(
        error.statusCode ?? 500
      ).json({
        success: false,
        message: error.message,
      });

    }
  }

  async getAllProducts(
    req: Request,
    res: Response
  ) {
    try {

      const products =
        await productService.getAllProducts();

      return res.status(200).json({
        success: true,
        data: products,
      });

    } catch (error: any) {

      return res.status(
        error.statusCode ?? 500
      ).json({
        success: false,
        message: error.message,
      });

    }
  }

  async getPaginatedProducts(
    req: Request,
    res: Response
  ) {
    try {

      const page =
        Number(req.query.page) || 1;

      const size =
        Number(req.query.size) || 10;

      const search =
        req.query.search as string;

      const result =
        await productService.getPaginatedProducts(
          page,
          size,
          search
        );

      return res.status(200).json({
        success: true,
        ...result,
      });

    } catch (error: any) {

      return res.status(
        error.statusCode ?? 500
      ).json({
        success: false,
        message: error.message,
      });

    }
  }

  async updateProduct(
    req: Request,
    res: Response
  ) {
    try {

      const validatedData =
        UpdateProductDto.parse({
          ...req.body,
          ...(req.file && {
            imageUrl:
              `/uploads/${req.file.filename}`,
          }),
        });

      const product =
        await productService.updateProduct(
          req.params.id as string,
          validatedData
        );

      return res.status(200).json({
        success: true,
        message:
          "Product updated successfully",
        data: product,
      });

    } catch (error: any) {

      return res.status(
        error.statusCode ?? 500
      ).json({
        success: false,
        message: error.message,
      });

    }
  }

  async deleteProduct(
    req: Request,
    res: Response
  ) {
    try {

      await productService.deleteProduct(
        req.params.id as string
      );

      return res.status(200).json({
        success: true,
        message:
          "Product deleted successfully",
      });

    } catch (error: any) {

      return res.status(
        error.statusCode ?? 500
      ).json({
        success: false,
        message: error.message,
      });

    }
  }

  async activateProduct(
    req: Request,
    res: Response
  ) {
    try {

      const product =
        await productService.activateProduct(
          req.params.id as string
        );

      return res.status(200).json({
        success: true,
        message:
          "Product activated successfully",
        data: product,
      });

    } catch (error: any) {

      return res.status(
        error.statusCode ?? 500
      ).json({
        success: false,
        message: error.message,
      });

    }
  }

  async deactivateProduct(
    req: Request,
    res: Response
  ) {
    try {

      const product =
        await productService.deactivateProduct(
          req.params.id as string
        );

      return res.status(200).json({
        success: true,
        message:
          "Product deactivated successfully",
        data: product,
      });

    } catch (error: any) {

      return res.status(
        error.statusCode ?? 500
      ).json({
        success: false,
        message: error.message,
      });

    }
  }
}