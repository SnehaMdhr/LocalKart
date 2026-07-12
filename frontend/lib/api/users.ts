import apiClient from "./axios";

export interface User {
  _id: string;
  name: string;
  email: string;
  phone?: string;
  role: "Customer" | "Shopkeeper" | "admin";
  imageUrl?: string;
  createdAt: string;
}

export interface UserFormData {
  name: string;
  email: string;
  password?: string;
  phone?: string;
  role?: "Customer" | "Shopkeeper" | "admin";
  imageUrl?: string;
  imageFile?: File;
  confirmPassword?: string;
}

export const usersApi = {
  getAll: async (params?: { page?: number; size?: number; search?: string }) => {
    const response = await apiClient.get("/auth", { params });
    return response.data; // { success, data: User[], pagination }
  },

  getOne: async (id: string) => {
    const response = await apiClient.get(`/auth/${id}`);
    return response.data; // { success, data: User }
  },

  create: async (data: UserFormData) => {
    const response = await apiClient.post("/auth/register", data);
    return response.data; // { success, message, data: User }
  },

  update: async (id: string, data: FormData | Partial<UserFormData>) => {
    const response = await apiClient.put(`/auth/${id}`, data);
    return response.data; // { success, message, data: User }
  },

  delete: async (id: string) => {
    const response = await apiClient.delete(`/auth/${id}`);
    return response.data; // { success, message }
  },
};
