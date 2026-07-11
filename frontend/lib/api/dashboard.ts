import apiClient from "./axios";

export interface DashboardStats {
  totalCustomers: number;
  totalVendors: number;
  totalShops: number;
  totalProducts: number;
  pendingShops: number;
  totalOrders: number;
}

export interface RecentOrder {
  _id: string;
  orderId?: string;
  customerId: { name: string; email: string; photo?: string };
  shopId?: { shopName: string };
  totalAmount: number;
  paymentMethod: string;
  paymentStatus: string;
  status: string;
  createdAt: string;
}

export interface RecentUser {
  _id: string;
  name: string;
  email: string;
  phone?: string;
  role: string;
  photo?: string;
  isActive?: boolean;
  createdAt: string;
}

export interface RecentShop {
  _id: string;
  shopName: string;
  ownerId?: { name: string; email: string };
  category?: string;
  status: string;
  createdAt: string;
}

export interface DashboardResponse {
  success: boolean;
  stats: DashboardStats;
  recentOrders: RecentOrder[];
  recentUsers: RecentUser[];
  recentShops: RecentShop[];
}

export const dashboardApi = {
  getDashboard: async (): Promise<DashboardResponse> => {
    const response = await apiClient.get<DashboardResponse>("/admin/dashboard");
    return response.data;
  },
};
