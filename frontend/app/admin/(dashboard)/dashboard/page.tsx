"use client";

import { useQuery } from "@tanstack/react-query";
import { dashboardApi } from "@/lib/api/dashboard";
import StatCard from "@/components/admin/StatCard";
import StatusBadge from "@/components/admin/StatusBadge";
import { formatDate, formatCurrency, getInitials } from "@/lib/utils/format";
import {
  FiUsers,
  FiShoppingBag,
  FiPackage,
  FiShoppingCart,
  FiClock,
  FiDollarSign,
  FiChevronRight,
  FiTrendingUp,
} from "react-icons/fi";
import Link from "next/link";
import type { RecentOrder, RecentUser, RecentShop } from "@/lib/api/dashboard";

export default function DashboardPage() {
  const { data, isLoading } = useQuery({
    queryKey: ["admin-dashboard"],
    queryFn: dashboardApi.getDashboard,
  });

  const stats = data?.stats;
  const recentOrders = data?.recentOrders ?? [];
  const recentUsers = data?.recentUsers ?? [];
  const recentShops = data?.recentShops ?? [];

  // Compute order status breakdown from recent orders
  const orderStatusCounts = recentOrders.reduce<Record<string, number>>((acc, o) => {
    const s = o.status || "Unknown";
    acc[s] = (acc[s] || 0) + 1;
    return acc;
  }, {});

  const totalRevenue = recentOrders.reduce((sum, o) => sum + (o.totalAmount || 0), 0);

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div>
        <h2 className="text-2xl font-bold tracking-tight text-gray-900">
          Overview
        </h2>
        <p className="mt-1 text-sm text-gray-500">
          Monitor your marketplace performance at a glance.
        </p>
      </div>

      {/* Statistics Cards */}
      <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6">
        <StatCard
          title="Total Customers"
          value={stats?.totalCustomers ?? 0}
          icon={<FiUsers className="h-6 w-6" />}
          color="blue"
          isLoading={isLoading}
        />
        <StatCard
          title="Total Vendors"
          value={stats?.totalVendors ?? 0}
          icon={<FiShoppingBag className="h-6 w-6" />}
          color="green"
          isLoading={isLoading}
        />
        <StatCard
          title="Total Shops"
          value={stats?.totalShops ?? 0}
          icon={<FiShoppingCart className="h-6 w-6" />}
          color="purple"
          isLoading={isLoading}
        />
        <StatCard
          title="Total Products"
          value={stats?.totalProducts ?? 0}
          icon={<FiPackage className="h-6 w-6" />}
          color="orange"
          isLoading={isLoading}
        />
        <StatCard
          title="Pending Shops"
          value={stats?.pendingShops ?? 0}
          icon={<FiClock className="h-6 w-6" />}
          color="red"
          isLoading={isLoading}
        />
        <StatCard
          title="Total Orders"
          value={stats?.totalOrders ?? 0}
          icon={<FiTrendingUp className="h-6 w-6" />}
          color="teal"
          isLoading={isLoading}
        />
      </div>

      {/* Revenue & Orders Overview Row */}
      <div className="grid gap-6 lg:grid-cols-2">
        {/* Revenue Overview */}
        <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-base font-semibold text-gray-900">
              Recent Revenue
            </h3>
            <span className="text-2xl font-bold text-admin-primary">
              {formatCurrency(totalRevenue)}
            </span>
          </div>
          {isLoading ? (
            <div className="space-y-3">
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="h-10 animate-pulse rounded-lg bg-gray-100" />
              ))}
            </div>
          ) : recentOrders.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-gray-400">
              <FiDollarSign className="h-10 w-10 mb-2" />
              <p className="text-sm">No revenue data yet</p>
            </div>
          ) : (
            <div className="space-y-2">
              {recentOrders.slice(0, 5).map((order) => {
                const maxAmount = Math.max(...recentOrders.map((o) => o.totalAmount), 1);
                const barWidth = (order.totalAmount / maxAmount) * 100;
                return (
                  <div key={order._id} className="flex items-center gap-3">
                    <span className="w-20 truncate text-xs text-gray-500">
                      #{order.orderId || order._id.slice(-6).toUpperCase()}
                    </span>
                    <div className="flex-1 h-7 rounded-md bg-gray-50 relative overflow-hidden">
                      <div
                        className="h-full rounded-md bg-gradient-to-r from-admin-primary-light to-admin-primary transition-all duration-500"
                        style={{ width: `${Math.max(barWidth, 5)}%` }}
                      />
                      <span className="absolute inset-0 flex items-center px-2 text-xs font-medium text-gray-900">
                        {formatCurrency(order.totalAmount)}
                      </span>
                    </div>
                    <StatusBadge status={order.status} size="sm" />
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Orders Overview */}
        <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-base font-semibold text-gray-900">
              Orders by Status
            </h3>
            <span className="text-sm text-gray-400">
              {recentOrders.length} total
            </span>
          </div>
          {isLoading ? (
            <div className="space-y-3">
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="h-10 animate-pulse rounded-lg bg-gray-100" />
              ))}
            </div>
          ) : Object.keys(orderStatusCounts).length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-gray-400">
              <FiShoppingCart className="h-10 w-10 mb-2" />
              <p className="text-sm">No orders yet</p>
            </div>
          ) : (
            <div className="space-y-3">
              {Object.entries(orderStatusCounts).map(([status, count]) => {
                const total = recentOrders.length;
                const percentage = total > 0 ? (count / total) * 100 : 0;
                return (
                  <div key={status}>
                    <div className="flex items-center justify-between mb-1">
                      <div className="flex items-center gap-2">
                        <StatusBadge status={status} size="sm" />
                      </div>
                      <span className="text-sm font-medium text-gray-900">
                        {count} <span className="text-xs text-gray-400">({percentage.toFixed(0)}%)</span>
                      </span>
                    </div>
                    <div className="h-2 rounded-full bg-gray-100 overflow-hidden">
                      <div
                        className="h-full rounded-full bg-admin-primary transition-all duration-500"
                        style={{ width: `${percentage}%` }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* Recent Orders Table */}
      <div className="rounded-xl border border-gray-200 bg-white shadow-sm">
        <div className="flex items-center justify-between border-b border-gray-100 px-6 py-4">
          <h3 className="text-base font-semibold text-gray-900">
            Recent Orders
          </h3>
          <Link
            href="/admin/orders"
            className="flex items-center gap-1 text-sm font-medium text-admin-primary hover:text-admin-primary-dark"
          >
            View all
            <FiChevronRight className="h-4 w-4" />
          </Link>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-100">
            <thead>
              <tr className="bg-gray-50/50">
                <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                  Order ID
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                  Customer
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                  Amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                  Payment
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                  Date
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i}>
                    {Array.from({ length: 6 }).map((_, j) => (
                      <td key={j} className="px-6 py-4">
                        <div className="h-4 w-20 animate-pulse rounded bg-gray-200" />
                      </td>
                    ))}
                  </tr>
                ))
              ) : recentOrders.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-sm text-gray-400">
                    No orders yet
                  </td>
                </tr>
              ) : (
                recentOrders.map((order: RecentOrder) => (
                  <tr
                    key={order._id}
                    className="transition-colors hover:bg-gray-50"
                  >
                    <td className="whitespace-nowrap px-6 py-4 text-sm font-medium text-gray-900">
                      #{order.orderId || order._id.slice(-6).toUpperCase()}
                    </td>
                    <td className="whitespace-nowrap px-6 py-4 text-sm text-gray-600">
                      {order.customerId?.name || "N/A"}
                    </td>
                    <td className="whitespace-nowrap px-6 py-4 text-sm font-medium text-gray-900">
                      {formatCurrency(order.totalAmount)}
                    </td>
                    <td className="whitespace-nowrap px-6 py-4 text-sm text-gray-600">
                      {order.paymentMethod || "N/A"}
                    </td>
                    <td className="whitespace-nowrap px-6 py-4">
                      <StatusBadge status={order.status} />
                    </td>
                    <td className="whitespace-nowrap px-6 py-4 text-sm text-gray-500">
                      {formatDate(order.createdAt)}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Recent Users + Recent Shops Grid */}
      <div className="grid gap-6 lg:grid-cols-2">
        {/* Recent Users */}
        <div className="rounded-xl border border-gray-200 bg-white shadow-sm">
          <div className="flex items-center justify-between border-b border-gray-100 px-6 py-4">
            <h3 className="text-base font-semibold text-gray-900">
              Recent Users
            </h3>
            <Link
              href="/admin/users"
              className="flex items-center gap-1 text-sm font-medium text-admin-primary hover:text-admin-primary-dark"
            >
              View all
              <FiChevronRight className="h-4 w-4" />
            </Link>
          </div>
          <div className="divide-y divide-gray-100">
            {isLoading ? (
              Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="flex items-center gap-3 px-6 py-3.5">
                  <div className="h-9 w-9 animate-pulse rounded-full bg-gray-200" />
                  <div className="flex-1 space-y-1.5">
                    <div className="h-3.5 w-32 animate-pulse rounded bg-gray-200" />
                    <div className="h-3 w-24 animate-pulse rounded bg-gray-200" />
                  </div>
                </div>
              ))
            ) : recentUsers.length === 0 ? (
              <div className="px-6 py-12 text-center text-sm text-gray-400">
                No users yet
              </div>
            ) : (
              recentUsers.map((user: RecentUser) => (
                <div
                  key={user._id}
                  className="flex items-center gap-3 px-6 py-3.5 transition-colors hover:bg-gray-50"
                >
                  <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-admin-primary-light text-xs font-semibold text-admin-primary">
                    {getInitials(user.name)}
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium text-gray-900">
                      {user.name}
                    </p>
                    <p className="truncate text-xs text-gray-500">
                      {user.email}
                    </p>
                  </div>
                  <div className="shrink-0">
                    <StatusBadge status={user.role} />
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Recent Shops */}
        <div className="rounded-xl border border-gray-200 bg-white shadow-sm">
          <div className="flex items-center justify-between border-b border-gray-100 px-6 py-4">
            <h3 className="text-base font-semibold text-gray-900">
              Recent Shop Registrations
            </h3>
            <Link
              href="/admin/shops"
              className="flex items-center gap-1 text-sm font-medium text-admin-primary hover:text-admin-primary-dark"
            >
              View all
              <FiChevronRight className="h-4 w-4" />
            </Link>
          </div>
          <div className="divide-y divide-gray-100">
            {isLoading ? (
              Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="flex items-center gap-3 px-6 py-3.5">
                  <div className="h-9 w-9 animate-pulse rounded bg-gray-200" />
                  <div className="flex-1 space-y-1.5">
                    <div className="h-3.5 w-32 animate-pulse rounded bg-gray-200" />
                    <div className="h-3 w-24 animate-pulse rounded bg-gray-200" />
                  </div>
                </div>
              ))
            ) : recentShops.length === 0 ? (
              <div className="px-6 py-12 text-center text-sm text-gray-400">
                No shops registered yet
              </div>
            ) : (
              recentShops.map((shop: RecentShop) => (
                <div
                  key={shop._id}
                  className="flex items-center gap-3 px-6 py-3.5 transition-colors hover:bg-gray-50"
                >
                  <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-purple-100 text-sm font-semibold text-purple-700">
                    {shop.shopName.charAt(0).toUpperCase()}
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium text-gray-900">
                      {shop.shopName}
                    </p>
                    <p className="truncate text-xs text-gray-500">
                      {shop.ownerId?.name || "Unknown owner"}
                    </p>
                  </div>
                  <div className="shrink-0">
                    <StatusBadge status={shop.status} />
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
