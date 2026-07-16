import { Request, Response } from "express";
import { CreateRatingDTO, UpdateRatingDTO } from "../dtos/rating.dtos";
import { RatingService } from "../services/rating.service";

const ratingService = new RatingService();

export class RatingController {
  /**
   * POST /ratings
   * Create a new rating for a delivered order.
   */
  async createRating(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();

      const validatedData = CreateRatingDTO.parse(req.body);

      const rating = await ratingService.createRating(
        userId,
        validatedData
      );

      return res.status(201).json({
        success: true,
        message: "Rating submitted successfully",
        data: rating,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * GET /ratings/vendor/:vendorId
   * Get all ratings and stats for a vendor.
   */
  async getVendorRatings(req: Request, res: Response) {
    try {
      const vendorId = String(req.params.vendorId);

      const result = await ratingService.getVendorRatings(vendorId);

      return res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * GET /ratings/order/:orderId
   * Get the rating for a specific order.
   */
  async getOrderRating(req: Request, res: Response) {
    try {
      const orderId = String(req.params.orderId);

      const rating = await ratingService.getOrderRating(orderId);

      return res.status(200).json({
        success: true,
        data: rating,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * PATCH /ratings/:id
   * Update an existing rating (edit comment/stars).
   */
  async updateRating(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();
      const ratingId = String(req.params.id);

      const validatedData = UpdateRatingDTO.parse(req.body);

      const updated = await ratingService.updateRating(
        ratingId,
        userId,
        validatedData
      );

      return res.status(200).json({
        success: true,
        message: "Rating updated successfully",
        data: updated,
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * DELETE /ratings/:id
   * Delete a rating.
   */
  async deleteRating(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();
      const ratingId = String(req.params.id);

      await ratingService.deleteRating(ratingId, userId);

      return res.status(200).json({
        success: true,
        message: "Rating deleted successfully",
      });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({
        success: false,
        message: error.message,
      });
    }
  }
}
