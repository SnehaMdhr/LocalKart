import z from "zod";
import { addressSchema } from "../types/address.type";

export const CreateAddressDTO = addressSchema.omit({
  userId: true,
});

export type CreateAddressDTO = z.infer<typeof CreateAddressDTO>;

export const UpdateAddressDTO = addressSchema
  .omit({
    userId: true,
  })
  .partial();

export type UpdateAddressDTO = z.infer<typeof UpdateAddressDTO>;