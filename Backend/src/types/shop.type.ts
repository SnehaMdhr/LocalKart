import mongoose from "mongoose";
import z from "zod";

export const shopSchema = z.object({
  userId: z.instanceof(mongoose.Types.ObjectId).optional(),
  shopName: z.string().min(3),
  address: z.string().min(3),
  description: z.string().min(10),
  imageUrl: z.string().optional(),

  category: z.enum([
    "Grocery",
    "Electronics",
    "Clothing",
    "Restaurant",
    "Pharmacy",
    "Stationery",
    "Hardware",
    "Other"
  ]),

  status: z.enum([
    "pending",
    "approved",
    "rejected",
    "suspended"
  ]).default("pending"),
});

export type ShopType = z.infer<typeof shopSchema>;