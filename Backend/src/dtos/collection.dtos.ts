import z from "zod";
import { collectionSchema } from "../types/collection.type";
import mongoose from "mongoose";

export const CreateCollectionDto = collectionSchema.pick({
  collectionName: true,
});

export type CreateCollectionDto = z.infer<typeof CreateCollectionDto>;

export const UpdateCollectionDto = collectionSchema.partial();
export type UpdateCollectionDto = z.infer<typeof UpdateCollectionDto>;

export const AddProductDto = z.object({
  productId: z.instanceof(mongoose.Types.ObjectId),
});

export type AddProductDto = z.infer<typeof AddProductDto>;
