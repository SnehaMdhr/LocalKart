"use client";

import type { ReactNode } from "react";
import { FiTrendingUp, FiTrendingDown } from "react-icons/fi";

interface StatCardProps {
  title: string;
  value: number | string;
  icon: ReactNode;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  color?: "blue" | "green" | "purple" | "orange" | "red" | "teal";
  isLoading?: boolean;
}

const colorMap = {
  blue: {
    bg: "bg-admin-primary-light",
    icon: "text-admin-primary",
    ring: "ring-admin-primary/10",
  },
  green: {
    bg: "bg-emerald-50",
    icon: "text-emerald-600",
    ring: "ring-emerald-500/10",
  },
  purple: {
    bg: "bg-purple-50",
    icon: "text-purple-600",
    ring: "ring-purple-500/10",
  },
  orange: {
    bg: "bg-orange-50",
    icon: "text-orange-600",
    ring: "ring-orange-500/10",
  },
  red: {
    bg: "bg-red-50",
    icon: "text-red-600",
    ring: "ring-red-500/10",
  },
  teal: {
    bg: "bg-teal-50",
    icon: "text-teal-600",
    ring: "ring-teal-500/10",
  },
};

export default function StatCard({
  title,
  value,
  icon,
  trend,
  color = "blue",
  isLoading = false,
}: StatCardProps) {
  const colors = colorMap[color];

  return (
    <div className="group relative overflow-hidden rounded-xl border border-gray-200 bg-white p-6 shadow-sm transition-all hover:shadow-md">
      {/* Subtle gradient accent */}
      <div
        className={`absolute inset-x-0 top-0 h-0.5 bg-gradient-to-r ${color === "blue" ? "from-[#2E7D32] to-admin-primary" : color === "green" ? "from-emerald-400 to-emerald-600" : color === "purple" ? "from-purple-400 to-purple-600" : color === "orange" ? "from-orange-400 to-orange-600" : color === "red" ? "from-red-400 to-red-600" : "from-teal-400 to-teal-600"}`}
      />

      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm font-medium text-gray-500">{title}</p>
          {isLoading ? (
            <div className="mt-2 h-8 w-24 animate-pulse rounded-md bg-gray-200" />
          ) : (
            <p className="mt-2 text-3xl font-bold tracking-tight text-gray-900">
              {typeof value === "number" ? value.toLocaleString() : value}
            </p>
          )}
          {trend && !isLoading && (
            <div className="mt-2 flex items-center gap-1">
              {trend.isPositive ? (
                <FiTrendingUp className="h-3.5 w-3.5 text-emerald-500" />
              ) : (
                <FiTrendingDown className="h-3.5 w-3.5 text-red-500" />
              )}
              <span
                className={`text-xs font-medium ${trend.isPositive ? "text-emerald-600" : "text-red-600"}`}
              >
                {trend.value}%
              </span>
              <span className="text-xs text-gray-400">vs last month</span>
            </div>
          )}
        </div>
        <div
          className={`flex h-12 w-12 items-center justify-center rounded-xl ${colors.bg} ${colors.icon} ring-1 ${colors.ring} transition-transform group-hover:scale-110`}
        >
          {icon}
        </div>
      </div>
    </div>
  );
}
