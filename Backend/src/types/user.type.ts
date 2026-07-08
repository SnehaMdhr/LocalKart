import z from "zod";

export const userSchema = z.object({
    email: z.email().min(5),
    password: z.string().min(8).optional(),
    authProvider: z.enum(["local", "google", "github"]).default("local"),
    name: z.string().optional(),
    phone: z.string().optional(),
    role: z.enum(["Customer","Shopkeeper", "admin"]).default("Customer"),
    imageUrl: z.string().optional(),
    address: z.string().optional(),
    newPassword: z.string().min(8).optional(),
    resetOtpExpiry: z.date().optional(),
    otp: z.string().length(6).optional(),
});

export type UserType = z.infer<typeof userSchema>;