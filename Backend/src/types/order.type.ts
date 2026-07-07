import mongoose from "mongoose";
import z from "zod";

export const orderSchema = z.object({
  customerId: z.instanceof(mongoose.Types.ObjectId),

  shopId: z.instanceof(mongoose.Types.ObjectId).nullable().default(null),

  orderNumber: z.string(),

  items: z.array(
    z.object({
      productId: z.instanceof(mongoose.Types.ObjectId),

      productName: z.string(),

      price: z.number().nonnegative(),

      quantity: z.number().int().positive(),
    })
  ),

  deliveryAddress: z.object({
    fullAddress: z.string(),

    latitude: z.number(),

    longitude: z.number(),
  }),

  totalAmount: z.number().nonnegative(),

  paymentMethod: z.enum(["Cash on Delivery", "eSewa"]),

  paymentStatus: z.enum([
    "Pending",
    "Paid",
    "Failed",
  ]).default("Pending"),

  status: z.enum([
    "Pending",
    "Accepted",
    "Preparing",
    "Out for Delivery",
    "Delivered",
    "Cancelled",
    "Rejected",
  ]).default("Pending"),

  rejectedBy: z.array(
    z.instanceof(mongoose.Types.ObjectId)
  ).default([]),

  customerNote: z.string().optional(),

  estimatedDeliveryTime: z.number().optional(),
});

export type OrderType = z.infer<typeof orderSchema>;