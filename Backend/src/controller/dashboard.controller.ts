import { Request, Response } from "express";
import { UserModel } from "../model/user.model";
import { ShopModel } from "../model/shop.model";
import { ProductModel } from "../model/product.model";
import { OrderModel } from "../model/order.model";

export class DashboardController {
  async getDashboard(req: Request, res: Response) {
    try {
      // Run all queries in parallel for performance
      const [
        totalCustomers,
        totalVendors,
        totalShops,
        totalProducts,
        pendingShops,
        totalOrders,
        recentOrders,
        recentUsers,
        recentShops,
      ] = await Promise.all([
        // Count customers
        UserModel.countDocuments({ role: "Customer" }),

        // Count vendors / shopkeepers
        UserModel.countDocuments({ role: "Shopkeeper" }),

        // Count all shops
        ShopModel.countDocuments(),

        // Count all products
        ProductModel.countDocuments(),

        // Count pending shops
        ShopModel.countDocuments({ status: "pending" }),

        // Count all orders
        OrderModel.countDocuments(),

        // Get 5 most recent orders with populated customer & shop data
        OrderModel.find()
          .populate("customerId", "name email photo")
          .sort({ createdAt: -1 })
          .limit(5)
          .lean(),

        // Get 5 most recent users
        UserModel.find()
          .sort({ createdAt: -1 })
          .limit(5)
          .lean(),

        // Get 5 most recent shops with populated owner data
        ShopModel.find()
          .populate("userId", "name email")
          .sort({ createdAt: -1 })
          .limit(5)
          .lean(),
      ]);

      // Map orders to match the frontend's RecentOrder interface
      const mappedOrders = recentOrders.map((order: any) => ({
        _id: order._id,
        orderId: order.orderNumber || order._id.toString().slice(-6).toUpperCase(),
        customerId: order.customerId || { name: "N/A", email: "" },
        shopId: order.shopId,
        totalAmount: order.totalAmount,
        paymentMethod: order.paymentMethod,
        paymentStatus: order.paymentStatus,
        status: order.status,
        createdAt: order.createdAt,
      }));

      // Map users to match frontend's RecentUser interface
      const mappedUsers = recentUsers.map((user: any) => ({
        _id: user._id,
        name: user.name || "Unknown",
        email: user.email,
        phone: user.phone,
        role: user.role,
        createdAt: user.createdAt,
      }));

      // Map shops to match frontend's RecentShop interface
      const mappedShops = recentShops.map((shop: any) => ({
        _id: shop._id,
        shopName: shop.shopName,
        ownerId: shop.userId || null,
        categories: shop.categories || [],
        status: shop.status,
        createdAt: shop.createdAt,
      }));

      return res.status(200).json({
        success: true,
        stats: {
          totalCustomers,
          totalVendors,
          totalShops,
          totalProducts,
          pendingShops,
          totalOrders,
        },
        recentOrders: mappedOrders,
        recentUsers: mappedUsers,
        recentShops: mappedShops,
      });
    } catch (error: any) {
      console.error("Dashboard error:", error);
      return res.status(500).json({
        success: false,
        message: "Failed to fetch dashboard data",
        error: error.message,
      });
    }
  }
}
