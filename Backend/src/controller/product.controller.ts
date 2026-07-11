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

      console.log("🔍 createProduct req.body:", JSON.stringify(req.body));
      console.log("🔍 createProduct req.file:", req.file?.filename);

      const rawPrice = req.body.price;
      const body = {
        ...req.body,
        price: typeof rawPrice === "string" ? Number(rawPrice) : rawPrice,
        imageUrl: req.file
          ? `/uploads/${req.file.filename}`
          : req.body.imageUrl || undefined,
      };

      console.log("🔍 Parsed body price:", body.price, "type:", typeof body.price);

      const validatedData = CreateProductDto.parse(body);

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

      const body = {
        ...req.body,
        ...(req.file && {
          imageUrl:
            `/uploads/${req.file.filename}`,
        }),
      };

      if (typeof body.price === "string") {
        body.price = Number(body.price);
      }

      const validatedData =
        UpdateProductDto.parse(body);

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