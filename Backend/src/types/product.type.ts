import z from "zod";

export const productSchema = z.object({
  productName: z.string().min(2).max(100),
  description: z.string().max(256).optional(),
  categoryName:z.enum(["Fruits",
            "Vegetables",
            "Dairy & Eggs",
            "Rice, Flour & Grains",
            "Pulses & Lentils",
            "Cooking Oil & Ghee",
            "Spices & Masala",
            "Tea, Coffee & Beverages",
            "Snacks & Biscuits",
            "Bakery & Bread",
            "Frozen Foods",
            "Personal Care",
            "Household Essentials",
            "Baby Care"]),

  imageUrl: z.string().optional(),

  price: z.number().positive(),

  unit: z.string(), // kg, litre, packet, piece

  isActive: z.boolean().optional(),
});

export type ProductType = z.infer<typeof productSchema>;