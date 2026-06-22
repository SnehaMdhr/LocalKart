import mongoose from "mongoose";
import { AddToCartDto, UpdateQuantityDto } from "../dtos/cart.dtos";
import { HttpError } from "../errors/https-error";
import { ICart } from "../model/cart.model";
import { ProductModel } from "../model/product.model";
import { CartRepository } from "../repositories/cart.repository";

const cartRepository = new CartRepository();

export class CartService {
  async addToCart(
    userId: string,
    data: AddToCartDto
  ): Promise<ICart> {
    const product = await ProductModel.findById(data.productId);

    if (!product) {
      throw new HttpError(404, "Product not found");
    }

    let cart = await cartRepository.getCartByUserId(userId);

    if (!cart) {
      cart = await cartRepository.createCart({
        userId: new mongoose.Types.ObjectId(userId),
        items: [],
      });
    }

    const existingItem = cart.items.find(
      (item) => item.productId.toString() === data.productId.toString()
    );

    if (existingItem) {
      return (await cartRepository.updateQuantity(
        cart._id.toString(),
        new mongoose.Types.ObjectId(data.productId),
        existingItem.quantity + data.quantity
      )) as ICart;
    }

    const updated = await cartRepository.addProduct(
      cart._id.toString(),
      new mongoose.Types.ObjectId(data.productId),
      data.quantity
    );

    if (!updated) {
      throw new HttpError(404, "Cart not found");
    }

    return updated;
  }

  async getCart(userId: string): Promise<ICart> {
    const cart = await cartRepository.getCartByUserId(userId);

    if (!cart) {
      throw new HttpError(404, "Cart not found");
    }

    return cart;
  }

  async updateQuantity(
    userId: string,
    data: UpdateQuantityDto
  ): Promise<ICart> {
    const cart = await cartRepository.getCartByUserId(userId);

    if (!cart) {
      throw new HttpError(404, "Cart not found");
    }

    const updated = await cartRepository.updateQuantity(
      cart._id.toString(),
      new mongoose.Types.ObjectId(data.productId),
      data.quantity
    );

    if (!updated) {
      throw new HttpError(404, "Product not found in cart");
    }

    return updated;
  }

  async removeFromCart(
    userId: string,
    productId: string
  ): Promise<ICart> {
    const cart = await cartRepository.getCartByUserId(userId);

    if (!cart) {
      throw new HttpError(404, "Cart not found");
    }

    const updated = await cartRepository.removeProduct(
      cart._id.toString(),
      new mongoose.Types.ObjectId(productId)
    );

    if (!updated) {
      throw new HttpError(404, "Cart not found");
    }

    return updated;
  }

  async clearCart(userId: string): Promise<ICart> {
    const cart = await cartRepository.getCartByUserId(userId);

    if (!cart) {
      throw new HttpError(404, "Cart not found");
    }

    const updated = await cartRepository.clearCart(cart._id.toString());

    if (!updated) {
      throw new HttpError(404, "Cart not found");
    }

    return updated;
  }
}