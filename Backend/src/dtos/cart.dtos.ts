import z from "zod";
import { cartSchema } from "../types/cart.type";
import mongoose from "mongoose";

const objectIdFromInput = z
  .union([
    z.string().refine(mongoose.isValidObjectId, {
      message: "Invalid input: expected ObjectId",
    }),
    z.instanceof(mongoose.Types.ObjectId),
  ])
  .transform((value) =>
    typeof value === "string" ? new mongoose.Types.ObjectId(value) : value
  );

export const UpdateCartDto = cartSchema.partial();

export type UpdateCartDto = z.infer<typeof UpdateCartDto>;

export const AddToCartDto = z.object({
  productId: objectIdFromInput,
  quantity: z.number().int().positive().default(1),
});

export type AddToCartDto = z.infer<typeof AddToCartDto>;
export const UpdateQuantityDto = z.object({
  productId: objectIdFromInput,
  quantity: z.number().int().positive(),
});

export type UpdateQuantityDto = z.infer<typeof UpdateQuantityDto>;