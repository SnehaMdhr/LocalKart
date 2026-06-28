import mongoose from "mongoose";
import z from "zod";

export const cartSchema = z.object({
  userId: z.instanceof(mongoose.Types.ObjectId),

  items: z.array(
    z.object({
      productId: z.instanceof(mongoose.Types.ObjectId),
      quantity: z.number().int().positive().default(1),
    })
  ),
});

export type CartType = z.infer<typeof cartSchema>;