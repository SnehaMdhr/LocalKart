import z from "zod";
import { productSchema } from "../types/product.type";

const toNumber = (val: unknown) =>
  typeof val === "string" ? Number(val) : val;

export const CreateProductDto = productSchema.pick({
    productName: true,
    description: true,
    categoryName: true,
    unit: true,
}).extend({
    price: z.preprocess(toNumber, z.number().positive()),
    imageUrl: z.string().optional(),
})

export type CreateProductDto = z.infer<typeof CreateProductDto>;

export const UpdateProductDto = productSchema.partial().extend({
    price: z.preprocess(toNumber, z.number().positive()).optional(),
});
export type UpdateProductDto = z.infer<typeof UpdateProductDto>;