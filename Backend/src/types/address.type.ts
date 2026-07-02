import mongoose from "mongoose";
import z from "zod";

export const addressSchema = z.object({
  userId: z.instanceof(mongoose.Types.ObjectId),
  label: z.enum(["Home", "Work", "Other"]).default("Home"),
  fullAddress: z.string().min(5),
  latitude: z.number(),
  longitude: z.number(),
});

export type AddressType = z.infer<typeof addressSchema>;