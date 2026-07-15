import apiClient from "./axios";

export interface LoginRequest {
  email: string;
  password: string;
}

export interface AdminUser {
  _id?: string;
  id?: string;
  name: string;
  email: string;
  role: string;
  photo?: string;
  imageUrl?: string;
}

export interface LoginResponse {
  success: boolean;
  token: string;
  data?: AdminUser;
  user?: AdminUser;
  message?: string;
}

export interface ProfileResponse {
  success: boolean;
  data?: AdminUser;
  user?: AdminUser;
}

export const authApi = {
  login: async (data: LoginRequest): Promise<LoginResponse> => {
    const response = await apiClient.post<LoginResponse>("/auth/login", data);
    return response.data;
  },

  updateProfile: async (data: FormData): Promise<AdminUser> => {
    const response = await apiClient.put<ProfileResponse>(
      "/auth/update-profile",
      data
    );
    const profile = response.data;
    return (profile.data || profile.user) as AdminUser;
  },

  getProfile: async (): Promise<AdminUser> => {
    const response = await apiClient.get<ProfileResponse>(
      "/auth/view-my-profile"
    );
    // Backend returns user under `data`, frontend may use either `data` or `user`
    const profile = response.data;
    return (profile.data || profile.user) as AdminUser;
  },
};
