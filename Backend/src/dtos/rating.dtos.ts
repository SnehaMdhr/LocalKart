import z from "zod";

// Create a rating (after order is delivered)
export const CreateRatingDTO = z.object({
  orderId: z.string(),
  rating: z.number().int().min(1).max(5),
  comment: z.string().max(300).optional().default(""),
});

export type CreateRatingDTO = z.infer<typeof CreateRatingDTO>;

// Update an existing rating (only rating and comment can change)
export const UpdateRatingDTO = z.object({
  rating: z.number().int().min(1).max(5).optional(),
  comment: z.string().max(300).optional(),
});

export type UpdateRatingDTO = z.infer<typeof UpdateRatingDTO>;
