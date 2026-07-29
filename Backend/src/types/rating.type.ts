import mongoose from "mongoose";
import z from "zod";

export const ratingSchema = z.object({
  orderId: z.instanceof(mongoose.Types.ObjectId),
  customerId: z.instanceof(mongoose.Types.ObjectId),
  vendorId: z.instanceof(mongoose.Types.ObjectId),
  shopId: z.instanceof(mongoose.Types.ObjectId),
  rating: z.number().int().min(1).max(5),
  comment: z.string().max(300).optional().default(""),
});

export type RatingType = z.infer<typeof ratingSchema>;
