import { QueryFilter } from "mongoose";
import { IProduct, ProductModel } from "../model/product.model";

export interface IProductRepository {
  createProduct(productData: Partial<IProduct>): Promise<IProduct>;
  getProductById(id: string): Promise<IProduct | null>;
  getAllProducts(): Promise<IProduct[]>;
  updateProduct(
    id: string,
    updateData: Partial<IProduct>
  ): Promise<IProduct | null>;
  deleteProduct(id: string): Promise<boolean>;

  getAllPaginated(
    page: number,
    size: number,
    search?: string
  ): Promise<{ products: IProduct[]; total: number }>;
  getAllProductsForAdmin(): Promise<IProduct[]>;
  getAllPaginatedForAdmin(
    page: number,
    size: number,
    search?: string
  ): Promise<{ products: IProduct[]; total: number }>;
  getProductsByIdAdmin(id: string): Promise<IProduct | null>;
}

export class ProductRepository implements IProductRepository {
  async getProductsByIdAdmin(id: string): Promise<IProduct | null> {
    return ProductModel.findById(id);
  }
  async getAllProductsForAdmin(): Promise<IProduct[]> {
    return ProductModel.find();
  }
  async getAllPaginatedForAdmin(page: number, size: number, search?: string): Promise<{ products: IProduct[]; total: number; }> {
    const query: QueryFilter<IProduct> = {};

    if (search) {
      query.$or = [
        {
          productName: {
            $regex: search,
            $options: "i",
          },
        },
        {
          categoryName: {
            $regex: search,
            $options: "i",
          },
        },
      ];
    }
     const total = await ProductModel.countDocuments(query);

    const products = await ProductModel.find(query)
      .skip((page - 1) * size)
      .limit(size)
      .sort({ createdAt: -1 });

    return {
      products,
      total,
    };

  }
  async createProduct(
    productData: Partial<IProduct>
  ): Promise<IProduct> {
    const product = new ProductModel(productData);
    return await product.save();
  }

  async getProductById(
    id: string
  ): Promise<IProduct | null> {
     return ProductModel.findOne({
    _id: id,
    isActive: true,
  });
  }

  async getAllProducts(): Promise<IProduct[]> {
    return ProductModel.find({ isActive: true });
  }

  async updateProduct(
    id: string,
    updateData: Partial<IProduct>
  ): Promise<IProduct | null> {
    return ProductModel.findByIdAndUpdate(
      id,
      updateData,
      { new: true }
    );
  }

  async deleteProduct(id: string): Promise<boolean> {
    const result = await ProductModel.findByIdAndDelete(id);
    return result ? true : false;
  }

  async getAllPaginated(
    page: number,
    size: number,
    search?: string
  ): Promise<{ products: IProduct[]; total: number }> {
    const query: QueryFilter<IProduct> = {
  isActive: true,
};

    if (search) {
      query.$or = [
        {
          productName: {
            $regex: search,
            $options: "i",
          },
        },
        {
          categoryName: {
            $regex: search,
            $options: "i",
          },
        },
      ];
    }

    const total = await ProductModel.countDocuments(query);

    const products = await ProductModel.find(query)
      .skip((page - 1) * size)
      .limit(size)
      .sort({ createdAt: -1 });

    return {
      products,
      total,
    };
  }
}