import z from "zod";

// Query params for listing notifications
export const GetNotificationsQueryDTO = z.object({
  page: z.coerce.number().int().positive().optional().default(1),
  limit: z.coerce.number().int().positive().max(100).optional().default(20),
});

export type GetNotificationsQueryDTO = z.infer<typeof GetNotificationsQueryDTO>;

// Mark a single notification as read (no body needed, just the ID param)
export const MarkReadDTO = z.object({});

export type MarkReadDTO = z.infer<typeof MarkReadDTO>;

// Mark all notifications as read (no body needed)
export const MarkAllReadDTO = z.object({});

export type MarkAllReadDTO = z.infer<typeof MarkAllReadDTO>;

// Delete notification (no body needed, just the ID param)
export const DeleteNotificationDTO = z.object({});

export type DeleteNotificationDTO = z.infer<typeof DeleteNotificationDTO>;
