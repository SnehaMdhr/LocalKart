import apiClient from "./axios";

export interface OrderItem {
  productId: string;
  productName: string;
  price: number;
  quantity: number;
}

export interface DeliveryAddress {
  fullAddress: string;
  latitude: number;
  longitude: number;
}

export interface Order {
  _id: string;
  orderNumber: string;
  customerId: { _id: string; name: string; email: string };
  shopId?: { _id: string; shopName?: string; name?: string };
  items: OrderItem[];
  deliveryAddress: DeliveryAddress;
  totalAmount: number;
  paymentMethod: string;
  paymentStatus: "Pending" | "Paid" | "Failed";
  status: "Pending" | "Accepted" | "Preparing" | "Out for Delivery" | "Delivered" | "Cancelled" | "Rejected";
  customerNote?: string;
  estimatedDeliveryTime?: number;
  createdAt: string;
}

export const ordersApi = {
  getAll: async (params?: {
    page?: number;
    size?: number;
    status?: string;
    paymentStatus?: string;
  }) => {
    const response = await apiClient.get("/order/admin", { params });
    return response.data; // { success, data: Order[], pagination }
  },

  getOne: async (id: string) => {
    const response = await apiClient.get(`/order/${id}`);
    return response.data; // { success, data: Order }
  },

  delete: async (id: string) => {
    const response = await apiClient.delete(`/order/${id}`);
    return response.data; // { success, message }
  },
};
