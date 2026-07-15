import z from "zod";
import { shopSchema } from "../types/shop.type";

export const CreateShopDto = shopSchema.pick({
    shopName: true,
    address: true,
    description: true,
    categories: true,
    latitude: true,
    longitude: true,
})

export type CreateShopDto = z.infer<typeof CreateShopDto>;

export const UpdateShopDto = shopSchema.partial();
export type UpdateShopDto = z.infer<typeof UpdateShopDto>;