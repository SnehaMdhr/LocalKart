import mongoose from "mongoose";
import {
  CreateCollectionDto,
  UpdateCollectionDto,
} from "../dtos/collection.dtos";
import { HttpError } from "../errors/https-error";
import { ICollection } from "../model/collection.model";

import { CollectionRepository } from "../repositories/collection.repository";
import { ProductModel } from "../model/product.model";

const collectionRepository = new CollectionRepository();

export class CollectionService {
  async createCollection(
    userId: string,
    data: CreateCollectionDto,
  ): Promise<ICollection> {
    const existingCollection =
      await collectionRepository.getCollectionByUserAndName(
        userId,
        data.collectionName,
      );

    if (existingCollection) {
      throw new HttpError(409, "Collection with this name already exists.");
    }
    return await collectionRepository.createCollection({
      ...data,
      userId: new mongoose.Types.ObjectId(userId),
    });
  }

  async getMyCollections(userId: string): Promise<ICollection[]> {
    return await collectionRepository.getAllCollectionsByUserId(userId);
  }

  async getCollectionById(id: string): Promise<ICollection> {
    const collection = await collectionRepository.getCollectionById(id);

    if (!collection) {
      throw new HttpError(404, "Collection not found");
    }
    ``;

    return collection;
  }

 async updateCollection(
  collectionId: string,
  userId: string,
  updateData: UpdateCollectionDto,
): Promise<ICollection> {
    const collection =
      await collectionRepository.getCollectionById(collectionId);

    if (!collection) {
      throw new HttpError(404, "Collection not found");
    }

    const collUserId = (collection.userId as any)._id || collection.userId;
    if (collUserId.toString() !== userId) {
    throw new HttpError(
      403,
      "You are not authorized to update this collection."
    );
  }

    const updatedCollection = await collectionRepository.updateCollection(
      collection._id.toString(),
      updateData,
    );

    if (!updatedCollection) {
      throw new HttpError(404, "Collection not found");
    }

    return updatedCollection;
  }

  async deleteCollection(
  id: string,
  userId: string
): Promise<boolean> {
  const collection = await collectionRepository.getCollectionById(id);

  if (!collection) {
    throw new HttpError(404, "Collection not found");
  }

   const collUserId = (collection.userId as any)._id || collection.userId;
   if (collUserId.toString() !== userId) {
    throw new HttpError(
      403,
      "You are not authorized to delete this collection."
    );
  }

  return collectionRepository.deleteCollection(id);
}

async addProductToCollection(
    collectionId: string,
    userId: string,
    productId: string
): Promise<ICollection> {

    const collection =
        await collectionRepository.getCollectionById(collectionId);

    if (!collection) {
        throw new HttpError(404, "Collection not found");
    }

    const collUserId = (collection.userId as any)._id || collection.userId;
    if (collUserId.toString() !== userId) {
        throw new HttpError(
            403,
            "Unauthorized"
        );
    }

    const product = await ProductModel.findById(productId);

    if (!product) {
        throw new HttpError(404, "Product not found");
    }

    const updated =
        await collectionRepository.addProduct(
            collectionId,
            new mongoose.Types.ObjectId(productId)
        );

    if (!updated) {
        throw new HttpError(404, "Collection not found");
    }

    return updated;
}

async removeProductFromCollection(
  collectionId: string,
  userId: string,
  productId: string
): Promise<ICollection> {

  const collection =
    await collectionRepository.getCollectionById(collectionId);

  if (!collection) {
    throw new HttpError(404, "Collection not found");
  }

  const collUserId = (collection.userId as any)._id || collection.userId;
  if (collUserId.toString() !== userId) {
    throw new HttpError(
      403,
      "You are not authorized to modify this collection."
    );
  }

  const product = await ProductModel.findById(productId);

  if (!product) {
    throw new HttpError(404, "Product not found");
  }

  const updatedCollection =
    await collectionRepository.removeProduct(
      collectionId,
      new mongoose.Types.ObjectId(productId)
    );

  if (!updatedCollection) {
    throw new HttpError(404, "Collection not found");
  }

  return updatedCollection;
}
}
