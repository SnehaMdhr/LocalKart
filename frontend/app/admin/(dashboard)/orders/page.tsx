"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { ordersApi, type Order } from "@/lib/api/orders";
import { useToast } from "@/context/ToastContext";
import { formatDate } from "@/lib/utils/format";
import {
  FiSearch,  FiEye, FiX, FiChevronDown, FiPackage, FiMapPin, FiCreditCard, FiUser, FiCalendar, FiTrash2,
} from "react-icons/fi";

const STATUS_OPTIONS = [
  "All", "Pending", "Accepted", "Preparing", "Out for Delivery", "Delivered", "Cancelled", "Rejected",
] as const;

const PAYMENT_OPTIONS = ["All", "Pending", "Paid", "Failed"] as const;

const STATUS_COLORS: Record<string, string> = {
  Pending: "bg-amber-100 text-amber-700 ring-amber-600/20",
  Accepted: "bg-blue-100 text-blue-700 ring-blue-600/20",
  Preparing: "bg-indigo-100 text-indigo-700 ring-indigo-600/20",
  "Out for Delivery": "bg-purple-100 text-purple-700 ring-purple-600/20",
  Delivered: "bg-emerald-100 text-emerald-700 ring-emerald-600/20",
  Cancelled: "bg-red-100 text-red-700 ring-red-600/20",
  Rejected: "bg-rose-100 text-rose-700 ring-rose-600/20",
};

const PAYMENT_COLORS: Record<string, string> = {
  Pending: "bg-amber-50 text-amber-600 ring-amber-500/20",
  Paid: "bg-emerald-50 text-emerald-600 ring-emerald-500/20",
  Failed: "bg-red-50 text-red-600 ring-red-500/20",
};

function StatusBadge({ status }: { status: string }) {
  const color = STATUS_COLORS[status] || "bg-gray-100 text-gray-600 ring-gray-500/20";
  return (
    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ring-1 ring-inset ${color}`}>
      {status}
    </span>
  );
}

function PaymentBadge({ status }: { status: string }) {
  const color = PAYMENT_COLORS[status] || "bg-gray-100 text-gray-600 ring-gray-500/20";
  return (
    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ring-1 ring-inset ${color}`}>
      {status}
    </span>
  );
}

export default function OrdersPage() {
  const queryClient = useQueryClient();
  const { addToast } = useToast();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("All");
  const [paymentFilter, setPaymentFilter] = useState("All");
  const [showStatusDropdown, setShowStatusDropdown] = useState(false);
  const [showPaymentDropdown, setShowPaymentDropdown] = useState(false);
  const [viewingOrder, setViewingOrder] = useState<Order | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["admin-orders", page, statusFilter, paymentFilter],
    queryFn: () => ordersApi.getAll({
      page,
      size: 10,
      status: statusFilter !== "All" ? statusFilter : undefined,
      paymentStatus: paymentFilter !== "All" ? paymentFilter : undefined,
    }),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => ordersApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-orders"] });
      setDeleteId(null);
      addToast("success", "Order deleted successfully");
    },
    onError: (err: any) => { addToast("error", err?.response?.data?.message || "Failed to delete order"); },
  });

  const orders: Order[] = data?.data || [];
  const pagination = data?.pagination;

  const filtered = search
    ? orders.filter((o) =>
        o.orderNumber?.toLowerCase().includes(search.toLowerCase()) ||
        o.customerId?.name?.toLowerCase().includes(search.toLowerCase())
      )
    : orders;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Orders</h2>
          <p className="text-sm text-gray-500">Manage all orders across the marketplace</p>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        {/* Search */}
        <div className="relative max-w-xs w-full">
          <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder="Search orders or customers..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full rounded-lg border border-gray-300 py-2.5 pl-10 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary"
          />
        </div>

        {/* Status + Payment filters */}
        <div className="flex items-center gap-2">
          {/* Status filter */}
          <div className="relative">
            <button
              onClick={() => { setShowStatusDropdown(!showStatusDropdown); setShowPaymentDropdown(false); }}
              className="flex items-center gap-2 rounded-lg border border-gray-300 px-3.5 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
            >
              {statusFilter === "All" ? "All Status" : statusFilter}
              <FiChevronDown className="h-4 w-4 text-gray-400" />
            </button>
            {showStatusDropdown && (
              <div className="absolute right-0 mt-1 z-10 w-44 rounded-xl border border-gray-200 bg-white py-1 shadow-lg">
                {STATUS_OPTIONS.map((s) => (
                  <button
                    key={s}
                    onClick={() => { setStatusFilter(s); setShowStatusDropdown(false); setPage(1); }}
                    className={`flex w-full items-center px-3.5 py-2 text-sm text-left transition-colors ${
                      statusFilter === s ? "bg-admin-primary-light text-admin-primary font-medium" : "text-gray-600 hover:bg-gray-50"
                    }`}
                  >
                    {s === "All" ? "All Status" : s}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Payment filter */}
          <div className="relative">
            <button
              onClick={() => { setShowPaymentDropdown(!showPaymentDropdown); setShowStatusDropdown(false); }}
              className="flex items-center gap-2 rounded-lg border border-gray-300 px-3.5 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors"
            >
              {paymentFilter === "All" ? "All Payment" : paymentFilter}
              <FiChevronDown className="h-4 w-4 text-gray-400" />
            </button>
            {showPaymentDropdown && (
              <div className="absolute right-0 mt-1 z-10 w-40 rounded-xl border border-gray-200 bg-white py-1 shadow-lg">
                {PAYMENT_OPTIONS.map((p) => (
                  <button
                    key={p}
                    onClick={() => { setPaymentFilter(p); setShowPaymentDropdown(false); setPage(1); }}
                    className={`flex w-full items-center px-3.5 py-2 text-sm text-left transition-colors ${
                      paymentFilter === p ? "bg-admin-primary-light text-admin-primary font-medium" : "text-gray-600 hover:bg-gray-50"
                    }`}
                  >
                    {p === "All" ? "All Payment" : p}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Table */}
      <div className="overflow-x-auto rounded-xl border border-gray-200 bg-white shadow-sm">
        <table className="min-w-full divide-y divide-gray-100">
          <thead>
            <tr className="bg-gray-50/50">
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Order</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Customer</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Payment</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {isLoading ? Array.from({ length: 5 }).map((_, i) => (
              <tr key={i}>{Array.from({ length: 7 }).map((_, j) => (
                <td key={j} className="px-6 py-4"><div className="h-4 w-20 animate-pulse rounded bg-gray-200" /></td>
              ))}</tr>
            )) : filtered.length === 0 ? (
              <tr><td colSpan={7} className="px-6 py-12 text-center text-sm text-gray-400">No orders found</td></tr>
            ) : filtered.map((order) => (
              <tr key={order._id} className="hover:bg-gray-50 transition-colors">
                <td className="px-6 py-4">
                  <div className="flex items-center gap-2">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-100 text-xs font-semibold text-blue-700">
                      <FiPackage className="h-4 w-4" />
                    </div>
                    <span className="text-sm font-medium text-gray-900">#{order.orderNumber?.slice(-8) || order._id.slice(-8)}</span>
                  </div>
                </td>
                <td className="px-6 py-4">
                  <div className="text-sm font-medium text-gray-900">{order.customerId?.name || "—"}</div>
                  <div className="text-xs text-gray-500">{order.customerId?.email || ""}</div>
                </td>
                <td className="px-6 py-4 text-sm font-medium text-gray-900">Rs. {order.totalAmount?.toFixed(2)}</td>
                <td className="px-6 py-4">
                  <div className="flex flex-col gap-1">
                    <PaymentBadge status={order.paymentStatus} />
                    <span className="text-xs text-gray-400">{order.paymentMethod}</span>
                  </div>
                </td>
                <td className="px-6 py-4"><StatusBadge status={order.status} /></td>
                <td className="px-6 py-4 text-sm text-gray-500">{formatDate(order.createdAt)}</td>
                <td className="px-6 py-4 text-right">
                  <div className="flex items-center justify-end gap-1">
                    <button
                      onClick={() => setViewingOrder(order)}
                      className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-admin-primary"
                      title="View"
                    >
                      <FiEye className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => setDeleteId(order._id)}
                      className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-red-600"
                      title="Delete"
                    >
                      <FiTrash2 className="h-4 w-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {/* Pagination */}
        {pagination && (
          <div className="flex items-center justify-between border-t border-gray-100 px-6 py-3">
            <span className="text-sm text-gray-500">
              Page {pagination.page || page} of {pagination.totalPages || 1} ({pagination.total} orders)
            </span>
            <div className="flex gap-2">
              <button
                disabled={page <= 1}
                onClick={() => setPage((p) => p - 1)}
                className="rounded-lg border border-gray-300 px-3 py-1 text-sm hover:bg-gray-50 disabled:opacity-50"
              >
                Prev
              </button>
              <button
                disabled={page >= (pagination.totalPages || 1)}
                onClick={() => setPage((p) => p + 1)}
                className="rounded-lg border border-gray-300 px-3 py-1 text-sm hover:bg-gray-50 disabled:opacity-50"
              >
                Next
              </button>
            </div>
          </div>
        )}
      </div>

      {/* View Modal */}
      {viewingOrder && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4"
          onClick={() => setViewingOrder(null)}
        >
          <div
            className="w-full max-w-2xl max-h-[90vh] overflow-y-auto rounded-xl bg-white p-6 shadow-xl"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="flex items-center justify-between mb-6">
              <div>
                <h3 className="text-lg font-semibold text-gray-900">
                  Order #{viewingOrder.orderNumber?.slice(-8) || viewingOrder._id.slice(-8)}
                </h3>
                <p className="text-sm text-gray-500">Placed on {formatDate(viewingOrder.createdAt)}</p>
              </div>
              <button
                onClick={() => setViewingOrder(null)}
                className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100"
              >
                <FiX className="h-5 w-5" />
              </button>
            </div>

            <div className="grid grid-cols-1 gap-6">
              {/* Customer Info */}
              <div className="rounded-lg border border-gray-200 p-4">
                <div className="flex items-center gap-2 mb-3">
                  <FiUser className="h-4 w-4 text-gray-400" />
                  <h4 className="text-sm font-semibold text-gray-900">Customer</h4>
                </div>
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100 text-sm font-semibold text-blue-700">
                    {viewingOrder.customerId?.name?.charAt(0)?.toUpperCase() || "?"}
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">{viewingOrder.customerId?.name || "—"}</p>
                    <p className="text-xs text-gray-500">{viewingOrder.customerId?.email || ""}</p>
                  </div>
                </div>
              </div>

              {/* Order Items */}
              <div className="rounded-lg border border-gray-200 p-4">
                <div className="flex items-center gap-2 mb-3">
                  <FiPackage className="h-4 w-4 text-gray-400" />
                  <h4 className="text-sm font-semibold text-gray-900">Items ({viewingOrder.items?.length || 0})</h4>
                </div>
                <div className="space-y-2">
                  {viewingOrder.items?.map((item, idx) => (
                    <div key={idx} className="flex items-center justify-between rounded-lg bg-gray-50 px-3 py-2">
                      <div className="flex items-center gap-3 min-w-0">
                        <span className="text-sm font-medium text-gray-900 truncate">{item.productName}</span>
                        <span className="text-xs text-gray-400 shrink-0">x{item.quantity}</span>
                      </div>
                      <span className="text-sm font-medium text-gray-900 shrink-0 ml-2">
                        Rs. {(item.price * item.quantity).toFixed(2)}
                      </span>
                    </div>
                  ))}
                </div>
                <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-200">
                  <span className="text-sm font-semibold text-gray-900">Total</span>
                  <span className="text-base font-bold text-admin-primary">Rs. {viewingOrder.totalAmount?.toFixed(2)}</span>
                </div>
              </div>

              {/* Delivery & Payment */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {/* Delivery Address */}
                <div className="rounded-lg border border-gray-200 p-4">
                  <div className="flex items-center gap-2 mb-3">
                    <FiMapPin className="h-4 w-4 text-gray-400" />
                    <h4 className="text-sm font-semibold text-gray-900">Delivery Address</h4>
                  </div>
                  <p className="text-sm text-gray-600">{viewingOrder.deliveryAddress?.fullAddress || "—"}</p>
                </div>

                {/* Payment Info */}
                <div className="rounded-lg border border-gray-200 p-4">
                  <div className="flex items-center gap-2 mb-3">
                    <FiCreditCard className="h-4 w-4 text-gray-400" />
                    <h4 className="text-sm font-semibold text-gray-900">Payment</h4>
                  </div>
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="text-xs text-gray-500">Method</span>
                      <span className="text-sm text-gray-900">{viewingOrder.paymentMethod}</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-xs text-gray-500">Status</span>
                      <PaymentBadge status={viewingOrder.paymentStatus} />
                    </div>
                  </div>
                </div>
              </div>

              {/* Order Status */}
              <div className="rounded-lg border border-gray-200 p-4">
                <div className="flex items-center gap-2 mb-3">
                  <FiCalendar className="h-4 w-4 text-gray-400" />
                  <h4 className="text-sm font-semibold text-gray-900">Order Status</h4>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-500">Current status</span>
                  <StatusBadge status={viewingOrder.status} />
                </div>
                {viewingOrder.customerNote && (
                  <div className="mt-3 pt-3 border-t border-gray-100">
                    <span className="text-xs text-gray-500">Customer Note</span>
                    <p className="text-sm text-gray-700 mt-0.5">{viewingOrder.customerNote}</p>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      {deleteId && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
          onClick={() => { if (!deleteMutation.isPending) setDeleteId(null); }}
        >
          <div className="w-full max-w-sm rounded-xl bg-white p-6 shadow-xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center gap-3 mb-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-red-100">
                <FiTrash2 className="h-5 w-5 text-red-600" />
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">Delete Order</h3>
                <p className="text-sm text-gray-500">This action cannot be undone.</p>
              </div>
            </div>
            <div className="flex justify-end gap-3">
              <button
                onClick={() => setDeleteId(null)}
                className="rounded-lg border border-gray-300 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={() => deleteMutation.mutate(deleteId)}
                disabled={deleteMutation.isPending}
                className="rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50"
              >
                {deleteMutation.isPending ? "Deleting..." : "Delete"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
