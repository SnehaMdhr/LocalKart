import mongoose from "mongoose";
import { CreateRatingDTO, UpdateRatingDTO } from "../dtos/rating.dtos";
import { HttpError } from "../errors/https-error";
import { OrderModel } from "../model/order.model";
import { ShopModel } from "../model/shop.model";
import { RatingRepository } from "../repositories/rating.repository";

const ratingRepository = new RatingRepository();

export class RatingService {
  /**
   * Automatically recalculate a shop's averageRating and totalRatings
   * based on all existing ratings for that shop.
   */
  private async recalculateShopRating(shopId: string): Promise<void> {
    const stats = await ratingRepository.getStatsByShopId(shopId);

    await ShopModel.findByIdAndUpdate(shopId, {
      averageRating: stats.averageRating,
      totalRatings: stats.totalRatings,
    });
  }

  /**
   * Create a new rating (only by the order's customer, and only once).
   */
  async createRating(
    customerId: string,
    data: CreateRatingDTO
  ): Promise<any> {
    // Fetch the order to validate ownership and status
    const order = await OrderModel.findById(data.orderId);
    if (!order) {
      throw new HttpError(404, "Order not found");
    }

    // Only the customer who owns the order can rate
    if (order.customerId.toString() !== customerId) {
      throw new HttpError(403, "You can only rate your own orders");
    }

    // Order must be delivered
    if (order.status !== "Delivered") {
      throw new HttpError(400, "You can only rate delivered orders");
    }

    // Check if already rated
    const existing = await ratingRepository.findByOrderId(data.orderId);
    if (existing) {
      throw new HttpError(400, "You have already rated this order");
    }

    // Find the shop that fulfilled this order
    if (!order.shopId) {
      throw new HttpError(400, "This order was not fulfilled by any shop");
    }

    // Get the vendor's shop
    const shop = await ShopModel.findOne({ userId: order.shopId });
    if (!shop) {
      throw new HttpError(404, "Vendor shop not found");
    }

    const rating = await ratingRepository.create({
      orderId: new mongoose.Types.ObjectId(data.orderId),
      customerId: new mongoose.Types.ObjectId(customerId),
      vendorId: new mongoose.Types.ObjectId(order.shopId.toString()),
      shopId: shop._id as mongoose.Types.ObjectId,
      rating: data.rating,
      comment: data.comment || "",
    });

    // Auto-recalculate shop rating
    await this.recalculateShopRating(shop._id.toString());

    return rating;
  }

  /**
   * Get ratings for a specific vendor (by vendor userId).
   */
  async getVendorRatings(vendorId: string): Promise<{
    ratings: any[];
    stats: { averageRating: number; totalRatings: number; distribution: { [key: number]: number } };
  }> {
    // Find the shop for this vendor
    const shop = await ShopModel.findOne({ userId: new mongoose.Types.ObjectId(vendorId) });
    if (!shop) {
      throw new HttpError(404, "Shop not found for this vendor");
    }

    const ratings = await ratingRepository.findByShopId(shop._id.toString());
    const stats = await ratingRepository.getStatsByShopId(shop._id.toString());

    return { ratings, stats };
  }

  /**
   * Get the rating for a specific order.
   */
  async getOrderRating(orderId: string): Promise<any> {
    const rating = await ratingRepository.findByOrderId(orderId);
    if (!rating) {
      return null;
    }
    return rating;
  }

  /**
   * Update an existing rating (customer can edit their own rating).
   */
  async updateRating(
    ratingId: string,
    customerId: string,
    data: UpdateRatingDTO
  ): Promise<any> {
    const rating = await ratingRepository.findById(ratingId);
    if (!rating) {
      throw new HttpError(404, "Rating not found");
    }

    if (rating.customerId.toString() !== customerId) {
      throw new HttpError(403, "You can only edit your own ratings");
    }

    const updateData: any = {};
    if (data.rating !== undefined) updateData.rating = data.rating;
    if (data.comment !== undefined) updateData.comment = data.comment;

    const updated = await ratingRepository.update(ratingId, updateData);
    if (!updated) {
      throw new HttpError(404, "Rating not found");
    }

    // Auto-recalculate shop rating
    await this.recalculateShopRating(rating.shopId.toString());

    return updated;
  }

  /**
   * Delete a rating (customer can delete their own rating).
   */
  async deleteRating(ratingId: string, customerId: string): Promise<void> {
    const rating = await ratingRepository.findById(ratingId);
    if (!rating) {
      throw new HttpError(404, "Rating not found");
    }

    if (rating.customerId.toString() !== customerId) {
      throw new HttpError(403, "You can only delete your own ratings");
    }

    const shopId = rating.shopId.toString();
    const deleted = await ratingRepository.delete(ratingId);
    if (!deleted) {
      throw new HttpError(404, "Rating not found");
    }

    // Auto-recalculate shop rating
    await this.recalculateShopRating(shopId);
  }
}
