import mongoose from "mongoose";
import z from "zod";

export const collectionSchema = z.object({
  userId: z.instanceof(mongoose.Types.ObjectId),
  collectionName: z.string().min(1).max(100),
  productIds: z.array(z.instanceof(mongoose.Types.ObjectId)).default([]),
});

export type CollectionType = z.infer<typeof collectionSchema>;
