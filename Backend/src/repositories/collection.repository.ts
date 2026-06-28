import mongoose, { Types } from "mongoose";
import { ICollection, CollectionModel } from "../model/collection.model";
import { cp } from "node:fs";

export interface ICollectionRepository {
  createCollection(collectionData: Partial<ICollection>): Promise<ICollection>;
  getCollectionById(id: string): Promise<ICollection | null>;
  getAllCollection(): Promise<ICollection[]>;
  getCollectionByUserAndName(
    userId: string,
    collectionName: string,
  ): Promise<ICollection | null>;
  getAllCollectionsByUserId(userId: string): Promise<ICollection[]>;
  updateCollection(
    id: string,
    updateData: Partial<ICollection>,
  ): Promise<ICollection | null>;
  deleteCollection(id: string): Promise<boolean>;
  addProduct(
    collectionId: string,
    productId: mongoose.Types.ObjectId,
  ): Promise<ICollection | null>;
  removeProduct(
    collectionId: string,
    productId: mongoose.Types.ObjectId,
  ): Promise<ICollection | null>;
}

export class CollectionRepository implements ICollectionRepository {
  async removeProduct(
    collectionId: string,
    productId: mongoose.Types.ObjectId,
  ): Promise<ICollection | null> {
    return CollectionModel.findByIdAndUpdate(
      collectionId,
      {
        $pull: {
          productIds: productId,
        },
      },
      {
        new: true,
      },
    )
      .populate("userId")
      .populate("productIds");
  }
  async addProduct(
    collectionId: string,
    productId: mongoose.Types.ObjectId,
  ): Promise<ICollection | null> {
    return CollectionModel.findByIdAndUpdate(
      collectionId,
      {
        $addToSet: {
          productIds: productId,
        },
      },
      {
        new: true,
      },
    )
      .populate("userId")
      .populate("productIds");
  }
  async getCollectionByUserAndName(
    userId: string,
    collectionName: string,
  ): Promise<ICollection | null> {
    const collection = await CollectionModel.findOne({
      userId,
      collectionName,
    });
    return collection;
  }
  async getAllCollection(): Promise<ICollection[]> {
    return CollectionModel.find().populate("userId").populate("productIds");
  }
  async getAllCollectionsByUserId(userId: string): Promise<ICollection[]> {
    return CollectionModel.find({
      userId: new Types.ObjectId(userId),
    })
      .populate("userId")
      .populate("productIds");
  }
  async createCollection(
    collectionData: Partial<ICollection>,
  ): Promise<ICollection> {
    const collection = new CollectionModel(collectionData);
    return await collection.save();
  }
  async getCollectionById(id: string): Promise<ICollection | null> {
    return CollectionModel.findById(id)
      .populate("productIds");
  }

  async updateCollection(
    id: string,
    updateData: Partial<ICollection>,
  ): Promise<ICollection | null> {
    return CollectionModel.findByIdAndUpdate(id, updateData, {
      new: true,
      runValidators: true,
    });
  }
  async deleteCollection(id: string): Promise<boolean> {
    const result = await CollectionModel.findByIdAndDelete(id);
    return result ? true : false;
  }
}
