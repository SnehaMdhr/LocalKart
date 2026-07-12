import apiClient from "./axios";

export const CATEGORIES = [
  "Fruits",
  "Vegetables",
  "Dairy & Eggs",
  "Rice, Flour & Grains",
  "Pulses & Lentils",
  "Cooking Oil & Ghee",
  "Spices & Masala",
  "Tea, Coffee & Beverages",
  "Snacks & Biscuits",
  "Bakery & Bread",
  "Frozen Foods",
  "Personal Care",
  "Household Essentials",
  "Baby Care",
] as const;

export type ProductCategory = (typeof CATEGORIES)[number];

export interface Product {
  _id: string;
  productName: string;
  description?: string;
  categoryName: ProductCategory;
  price: number;
  unit: string;
  imageUrl?: string;
  isActive?: boolean;
  vendorId?: { _id: string; name: string; email: string };
  createdAt: string;
}

export interface ProductFormData {
  productName: string;
  description?: string;
  categoryName: ProductCategory;
  price: number;
  unit: string;
}

export const productsApi = {
  getAll: async (params?: { page?: number; size?: number; search?: string }) => {
    const response = await apiClient.get("/product/admin/paginated", { params });
    return response.data; // { success, data: Product[], pagination }
  },

  getById: async (id: string) => {
    const response = await apiClient.get(`/product/admin/${id}`);
    return response.data; // { success, data: Product }
  },

  create: async (data: FormData) => {
    const response = await apiClient.post("/product/create-product", data);
    return response.data; // { success, message, data: Product }
  },

  update: async (id: string, data: FormData) => {
    const response = await apiClient.put(`/product/${id}`, data);
    return response.data; // { success, message, data: Product }
  },

  delete: async (id: string) => {
    const response = await apiClient.delete(`/product/${id}`);
    return response.data; // { success, message }
  },

  activate: async (id: string) => {
    const response = await apiClient.patch(`/product/${id}/activate`);
    return response.data; // { success, message, data: Product }
  },

  deactivate: async (id: string) => {
    const response = await apiClient.patch(`/product/${id}/deactivate`);
    return response.data; // { success, message, data: Product }
  },
};
