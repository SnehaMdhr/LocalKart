import apiClient from "./axios";

export interface Shop {
  _id: string;
  shopName: string;
  description: string;
  address: string;
  imageUrl?: string;
  categories: string[];
  latitude?: number;
  longitude?: number;
  userId?: { _id: string; name: string; email: string };
  status: "pending" | "approved" | "rejected" | "suspended";
  createdAt: string;
}

export interface ShopFormData {
  shopName: string;
  description?: string;
  category?: string;
  address?: string;
}

export const shopsApi = {
  getAll: async () => {
    const response = await apiClient.get("/shop");
    return response.data; // { success, data: Shop[] }
  },

  getById: async (id: string) => {
    const response = await apiClient.get(`/shop/${id}`);
    return response.data; // { success, data: Shop }
  },

  create: async (data: FormData) => {
    const response = await apiClient.post("/shop/register-shop", data);
    return response.data; // { success, message, data: Shop }
  },

  update: async (data: FormData) => {
    const response = await apiClient.put("/shop/update-shop", data);
    return response.data; // { success, message, data: Shop }
  },

  delete: async (id: string) => {
    const response = await apiClient.delete(`/shop/delete-shop/${id}`);
    return response.data; // { success, message }
  },

  approve: async (id: string) => {
    const response = await apiClient.patch(`/shop/admin/${id}/approve`);
    return response.data; // { success, message, data: Shop }
  },

  reject: async (id: string) => {
    const response = await apiClient.patch(`/shop/admin/${id}/reject`);
    return response.data; // { success, message, data: Shop }
  },

  suspend: async (id: string) => {
    const response = await apiClient.patch(`/shop/admin/${id}/suspend`);
    return response.data; // { success, message, data: Shop }
  },
};
