import z from "zod";
import { productSchema } from "../types/product.type";

export const CreateProductDto = productSchema.pick({
    productName: true,
    description: true,
    categoryName: true,
    unit: true,
    price: true,
}).extend({
    imageUrl: z.string().optional(),
})

export type CreateProductDto = z.infer<typeof CreateProductDto>;

export const UpdateProductDto = productSchema.partial();
export type UpdateProductDto = z.infer<typeof UpdateProductDto>;