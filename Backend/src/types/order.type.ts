import mongoose from "mongoose";
import z from "zod";
import { cartSchema } from "./cart.type";

export const orderSchema = z.object({
  customerId: z.instanceof(mongoose.Types.ObjectId),

  shopId: z.instanceof(mongoose.Types.ObjectId).nullable(),

  items: cartSchema.shape.items,

  totalAmount: z.number().nonnegative(),

  deliveryAddress: z.string(),

  paymentMethod: z.enum([
    "Cash on Delivery",
    "eSewa"
  ]),

  paymentStatus: z.enum([
    "Pending",
    "Paid",
  ]),

  status: z.enum([
    "Pending",
    "Accepted",
    "Rejected",
    "Preparing",
    "Out for Delivery",
    "Delivered",
    "Cancelled",
  ]),
});

export type OrderType = z.infer<typeof orderSchema>;