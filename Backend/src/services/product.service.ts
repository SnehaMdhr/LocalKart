import { CreateProductDto, UpdateProductDto } from "../dtos/product.dtos";
import { HttpError } from "../errors/https-error";
import { IProduct } from "../model/product.model";
import { ProductRepository } from "../repositories/product.repository";
import { deleteUploadIfExists } from "../middlewares/upload.middleware";

const productRepository = new ProductRepository();

export class ProductService {

  async getProductsByIdAdmin(id: string): Promise<IProduct | null> {
     const product =
      await productRepository.getProductsByIdAdmin(id);

    if (!product) {
      throw new HttpError(
        404,
        "Product not found"
      );
    }

    return product;
  }

  async getAllProductsForAdmin(): Promise<IProduct[]> {
    return await productRepository.getAllProductsForAdmin();
  }

  async getAllPaginatedForAdmin(
    page: number,
    size: number,
    search?: string
  ) {
    return await productRepository.getAllPaginatedForAdmin(
      page,
      size,
      search
    );
  }
  async createProduct(
    data: CreateProductDto
  ): Promise<IProduct> {

    const product =
      await productRepository.createProduct(data);

    return product;
  }

  async getProductById(
    id: string
  ): Promise<IProduct> {

    const product =
      await productRepository.getProductById(id);

    if (!product) {
      throw new HttpError(
        404,
        "Product not found"
      );
    }

    return product;
  }

  async getAllProducts(): Promise<IProduct[]> {
    return await productRepository.getAllProducts();
  }

  async getPaginatedProducts(
    page: number,
    size: number,
    search?: string
  ) {
    return await productRepository.getAllPaginated(
      page,
      size,
      search
    );
  }

  async updateProduct(
    id: string,
    updateData: UpdateProductDto
  ): Promise<IProduct> {

    const product =
      await productRepository.getProductById(id);

    if (!product) {
      throw new HttpError(
        404,
        "Product not found"
      );
    }

    if (
      updateData.imageUrl &&
      product.imageUrl &&
      updateData.imageUrl !== product.imageUrl
    ) {
      try {
        deleteUploadIfExists(product.imageUrl);
      } catch (error) {
        console.error(
          "Error deleting old image:",
          error
        );
      }
    }

    const updatedProduct =
      await productRepository.updateProduct(
        id,
        updateData as Partial<IProduct>
      );

    if (!updatedProduct) {
      throw new HttpError(
        404,
        "Product not found"
      );
    }

    return updatedProduct;
  }

  async deleteProduct(
    id: string
  ): Promise<boolean> {

    const product =
      await productRepository.getProductById(id);

    if (!product) {
      throw new HttpError(
        404,
        "Product not found"
      );
    }

    if (product.imageUrl) {
      deleteUploadIfExists(
        product.imageUrl
      );
    }

    await productRepository.deleteProduct(id);

    return true;
  }

  async activateProduct(
    id: string
  ): Promise<IProduct> {

    const product =
      await productRepository.updateProduct(
        id,
        {
          isActive: true,
        }
      );

    if (!product) {
      throw new HttpError(
        404,
        "Product not found"
      );
    }

    return product;
  }

  async deactivateProduct(
    id: string
  ): Promise<IProduct> {

    const product =
      await productRepository.updateProduct(
        id,
        {
          isActive: false,
        }
      );

    if (!product) {
      throw new HttpError(
        404,
        "Product not found"
      );
    }

    return product;
  }
}