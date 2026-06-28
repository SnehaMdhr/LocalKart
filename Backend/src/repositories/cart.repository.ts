import mongoose, { Types } from "mongoose";
import { CartModel, ICart } from "../model/cart.model";

export interface ICartRepository {
  createCart(cartData: Partial<ICart>): Promise<ICart>;

  getCartById(id: string): Promise<ICart | null>;

  getCartByUserId(userId: string): Promise<ICart | null>;

  updateCart(
    id: string,
    updateData: Partial<ICart>,
  ): Promise<ICart | null>;

  deleteCart(id: string): Promise<boolean>;

  addProduct(
    cartId: string,
    productId: mongoose.Types.ObjectId,
    quantity: number,
  ): Promise<ICart | null>;

  updateQuantity(
    cartId: string,
    productId: mongoose.Types.ObjectId,
    quantity: number,
  ): Promise<ICart | null>;

  removeProduct(
    cartId: string,
    productId: mongoose.Types.ObjectId,
  ): Promise<ICart | null>;

  clearCart(cartId: string): Promise<ICart | null>;
}

export class CartRepository implements ICartRepository {
  async createCart(cartData: Partial<ICart>): Promise<ICart> {
    const cart = new CartModel(cartData);
    return await cart.save();
  }

  async getCartById(id: string): Promise<ICart | null> {
    return CartModel.findById(id)
      .populate("userId")
      .populate("items.productId");
  }

  async getCartByUserId(userId: string): Promise<ICart | null> {
    return CartModel.findOne({
      userId: new Types.ObjectId(userId),
    })
      .populate("userId")
      .populate("items.productId");
  }

  async updateCart(
    id: string,
    updateData: Partial<ICart>,
  ): Promise<ICart | null> {
    return CartModel.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true,
    });
  }

  async deleteCart(id: string): Promise<boolean> {
    const result = await CartModel.findByIdAndDelete(id);
    return result ? true : false;
  }

  async addProduct(
    cartId: string,
    productId: mongoose.Types.ObjectId,
    quantity: number,
  ): Promise<ICart | null> {
    return CartModel.findByIdAndUpdate(
      cartId,
      {
        $push: {
          items: {
            productId,
            quantity,
          },
        },
      },
      {
        new: true,
      },
    )
      .populate("userId")
      .populate("items.productId");
  }

  async updateQuantity(
    cartId: string,
    productId: mongoose.Types.ObjectId,
    quantity: number,
  ): Promise<ICart | null> {
    return CartModel.findOneAndUpdate(
      {
        _id: cartId,
        "items.productId": productId,
      },
      {
        $set: {
          "items.$.quantity": quantity,
        },
      },
      {
        new: true,
      },
    )
      .populate("userId")
      .populate("items.productId");
  }

  async removeProduct(
    cartId: string,
    productId: mongoose.Types.ObjectId,
  ): Promise<ICart | null> {
    return CartModel.findByIdAndUpdate(
      cartId,
      {
        $pull: {
          items: {
            productId,
          },
        },
      },
      {
        new: true,
      },
    )
      .populate("userId")
      .populate("items.productId");
  }

  async clearCart(cartId: string): Promise<ICart | null> {
    return CartModel.findByIdAndUpdate(
      cartId,
      {
        $set: {
          items: [],
        },
      },
      {
        new: true,
      },
    )
      .populate("userId")
      .populate("items.productId");
  }
}