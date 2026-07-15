"use client";

import {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  type ReactNode,
} from "react";
import { authApi, type AdminUser, type LoginRequest } from "@/lib/api/auth";

interface AuthContextType {
  user: AdminUser | null;
  token: string | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (data: LoginRequest) => Promise<void>;
  logout: () => void;
  updateUser: (updatedUser: AdminUser) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AdminUser | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const storedToken = localStorage.getItem("adminToken");
    const storedUser = localStorage.getItem("adminUser");

    if (storedToken && storedUser) {
      setToken(storedToken);
      try {
        setUser(JSON.parse(storedUser));
        // Verify token is still valid by fetching profile
        authApi
          .getProfile()
          .then((freshUser) => {
            setUser(freshUser);
            localStorage.setItem("adminUser", JSON.stringify(freshUser));
          })
          .catch(() => {
            // Token expired or invalid — clear everything
            localStorage.removeItem("adminToken");
            localStorage.removeItem("adminUser");
            setToken(null);
            setUser(null);
          })
          .finally(() => setIsLoading(false));
      } catch {
        localStorage.removeItem("adminToken");
        localStorage.removeItem("adminUser");
        setIsLoading(false);
      }
    } else {
      setIsLoading(false);
    }
  }, []);

  const login = useCallback(async (data: LoginRequest) => {
    const response = await authApi.login(data);

    // Backend sends token + user data under `data` field
    const newToken = response.token;
    const newUser = response.data || response.user;

    if (!newUser) {
      throw new Error("Invalid login response: no user data");
    }

    localStorage.setItem("adminToken", newToken);
    localStorage.setItem("adminUser", JSON.stringify(newUser));

    setToken(newToken);
    setUser(newUser);
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem("adminToken");
    localStorage.removeItem("adminUser");
    setToken(null);
    setUser(null);
  }, []);

  const updateUser = useCallback((updatedUser: AdminUser) => {
    setUser(updatedUser);
    localStorage.setItem("adminUser", JSON.stringify(updatedUser));
  }, []);

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isLoading,
        isAuthenticated: !!token && !!user,
        login,
        logout,
        updateUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
