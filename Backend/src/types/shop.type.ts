import mongoose from "mongoose";
import z from "zod";

export const shopSchema = z.object({
  userId: z.instanceof(mongoose.Types.ObjectId).optional(),
  shopName: z.string().min(3),
  address: z.string().min(3),
  description: z.string().min(10),
  imageUrl: z.string().optional(),

  categories: z.array(z.enum([
    "Fruits & Vegetables",
    "Dairy & Eggs",
    "Meat & Seafood",
    "Bakery",
    "Beverages",
    "Snacks & Confectionery",
    "Frozen Foods",
    "Organic & Health Foods",
    "Pantry Staples",
    "Baby & Pet",
  ])).min(1),

  status: z.enum([
    "pending",
    "approved",
    "rejected",
    "suspended"
  ]).default("pending"),
});

export type ShopType = z.infer<typeof shopSchema>;