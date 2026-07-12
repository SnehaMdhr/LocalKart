"use client";

import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { shopsApi, type Shop } from "@/lib/api/shops";
import StatusBadge from "@/components/admin/StatusBadge";
import { useToast } from "@/context/ToastContext";
import { formatDate, getInitials } from "@/lib/utils/format";
import {
  FiSearch, FiTrash2, FiEye, FiX, FiCheck, FiXCircle, FiPause, FiPlay,
} from "react-icons/fi";

export default function ShopsPage() {
  const queryClient = useQueryClient();
  const { addToast } = useToast();
  const [search, setSearch] = useState("");
  const [viewingShop, setViewingShop] = useState<Shop | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["admin-shops"],
    queryFn: () => shopsApi.getAll(),
  });

  const approveMutation = useMutation({
    mutationFn: (id: string) => shopsApi.approve(id),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["admin-shops"] }); addToast("success", "Shop approved successfully"); },
    onError: (err: any) => { addToast("error", err?.response?.data?.message || "Failed to approve shop"); },
  });
  const rejectMutation = useMutation({
    mutationFn: (id: string) => shopsApi.reject(id),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["admin-shops"] }); addToast("success", "Shop rejected"); },
    onError: (err: any) => { addToast("error", err?.response?.data?.message || "Failed to reject shop"); },
  });
  const suspendMutation = useMutation({
    mutationFn: (id: string) => shopsApi.suspend(id),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["admin-shops"] }); addToast("warning", "Shop suspended"); },
    onError: (err: any) => { addToast("error", err?.response?.data?.message || "Failed to suspend shop"); },
  });
  const deleteMutation = useMutation({
    mutationFn: (id: string) => shopsApi.delete(id),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["admin-shops"] }); setDeleteId(null); addToast("success", "Shop deleted successfully"); },
    onError: (err: any) => { addToast("error", err?.response?.data?.message || "Failed to delete shop"); },
  });

  const shops: Shop[] = data?.data || [];
  const filtered = shops.filter(s => s.shopName?.toLowerCase().includes(search.toLowerCase()));

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Shops</h2>
          <p className="text-sm text-gray-500">Manage all shops and approvals</p>
        </div>
      </div>

      <div className="relative max-w-md">
        <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <input type="text" placeholder="Search shops..." value={search} onChange={e => setSearch(e.target.value)}
          className="w-full rounded-lg border border-gray-300 py-2.5 pl-10 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary" />
      </div>

      <div className="overflow-x-auto rounded-xl border border-gray-200 bg-white shadow-sm">
        <table className="min-w-full divide-y divide-gray-100">
          <thead><tr className="bg-gray-50/50">
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Shop</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Owner</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
          </tr></thead>
          <tbody className="divide-y divide-gray-100">
            {isLoading ? Array.from({ length: 5 }).map((_, i) => (
              <tr key={i}>{Array.from({ length: 6 }).map((_, j) => (
                <td key={j} className="px-6 py-4"><div className="h-4 w-20 animate-pulse rounded bg-gray-200" /></td>
              ))}</tr>
            )) : filtered.length === 0 ? (
              <tr><td colSpan={6} className="px-6 py-12 text-center text-sm text-gray-400">No shops found</td></tr>
            ) : filtered.map((shop) => (
              <tr key={shop._id} className="hover:bg-gray-50 transition-colors">
                <td className="px-6 py-4">
                  <div className="flex items-center gap-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-purple-100 text-xs font-semibold text-purple-700">
                      {shop.shopName?.charAt(0)?.toUpperCase() || "S"}
                    </div>
                    <span className="text-sm font-medium text-gray-900">{shop.shopName}</span>
                  </div>
                </td>
                <td className="px-6 py-4 text-sm text-gray-600">{shop.userId?.name || "—"}</td>
                <td className="px-6 py-4 text-sm text-gray-600">{shop.categories?.[0] || "—"}</td>
                <td className="px-6 py-4"><StatusBadge status={shop.status} /></td>
                <td className="px-6 py-4 text-sm text-gray-500">{formatDate(shop.createdAt)}</td>
                <td className="px-6 py-4 text-right">
                  <div className="flex items-center justify-end gap-1">
                    <button onClick={() => setViewingShop(shop)} className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-admin-primary" title="View"><FiEye className="h-4 w-4" /></button>
                    {shop.status === "pending" && (
                      <>
                        <button onClick={() => approveMutation.mutate(shop._id)} className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-emerald-600" title="Approve"><FiCheck className="h-4 w-4" /></button>
                        <button onClick={() => rejectMutation.mutate(shop._id)} className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-red-600" title="Reject"><FiXCircle className="h-4 w-4" /></button>
                      </>
                    )}
                    {shop.status === "approved" && (
                      <button onClick={() => suspendMutation.mutate(shop._id)} className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-orange-600" title="Suspend"><FiPause className="h-4 w-4" /></button>
                    )}
                    {shop.status === "suspended" && (
                      <button onClick={() => approveMutation.mutate(shop._id)} className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-emerald-600" title="Resume"><FiPlay className="h-4 w-4" /></button>
                    )}
                    {shop.status === "rejected" && (
                      <button onClick={() => approveMutation.mutate(shop._id)} className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-emerald-600" title="Approve"><FiCheck className="h-4 w-4" /></button>
                    )}
                    <button onClick={() => setDeleteId(shop._id)} className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-red-600" title="Delete"><FiTrash2 className="h-4 w-4" /></button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Delete Confirmation */}
      {deleteId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" onClick={() => { if (!deleteMutation.isPending) setDeleteId(null); }}>
          <div className="w-full max-w-sm rounded-xl bg-white p-6 shadow-xl" onClick={e => e.stopPropagation()}>
            <div className="flex items-center gap-3 mb-4"><div className="flex h-10 w-10 items-center justify-center rounded-full bg-red-100"><FiTrash2 className="h-5 w-5 text-red-600" /></div>
              <div><h3 className="text-lg font-semibold text-gray-900">Delete Shop</h3><p className="text-sm text-gray-500">This action cannot be undone.</p></div>
            </div>
            <div className="flex justify-end gap-3">
              <button onClick={() => setDeleteId(null)} className="rounded-lg border border-gray-300 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">Cancel</button>
              <button onClick={() => deleteMutation.mutate(deleteId)} disabled={deleteMutation.isPending} className="rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50">
                {deleteMutation.isPending ? "Deleting..." : "Delete"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* View Modal */}
      {viewingShop && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" onClick={() => setViewingShop(null)}>
          <div className="w-full max-w-lg rounded-xl bg-white p-6 shadow-xl" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-lg font-semibold text-gray-900">Shop Details</h3>
              <button onClick={() => setViewingShop(null)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100"><FiX className="h-5 w-5" /></button>
            </div>
            <div className="flex items-center gap-4 mb-6">
              <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-purple-100 text-lg font-semibold text-purple-700">
                {viewingShop.shopName?.charAt(0)?.toUpperCase() || "S"}
              </div>
              <div><p className="text-lg font-semibold text-gray-900">{viewingShop.shopName}</p><p className="text-sm text-gray-500">{viewingShop.categories?.[0] || "No category"}</p></div>
            </div>
            <dl className="space-y-3">
              <div className="flex justify-between py-2 border-b border-gray-100"><dt className="text-sm text-gray-500">Owner</dt><dd className="text-sm text-gray-900">{viewingShop.userId?.name || "—"}</dd></div>
              <div className="flex justify-between py-2 border-b border-gray-100"><dt className="text-sm text-gray-500">Owner Email</dt><dd className="text-sm text-gray-900">{viewingShop.userId?.email || "—"}</dd></div>
              <div className="flex justify-between py-2 border-b border-gray-100"><dt className="text-sm text-gray-500">Status</dt><dd><StatusBadge status={viewingShop.status} /></dd></div>
              <div className="flex justify-between py-2 border-b border-gray-100"><dt className="text-sm text-gray-500">Address</dt><dd className="text-sm text-gray-900">{viewingShop.address || "—"}</dd></div>
              <div className="flex justify-between py-2"><dt className="text-sm text-gray-500">Created</dt><dd className="text-sm text-gray-900">{formatDate(viewingShop.createdAt)}</dd></div>
            </dl>
            {viewingShop.description && (
              <div className="mt-4 p-3 rounded-lg bg-gray-50"><p className="text-sm text-gray-600">{viewingShop.description}</p></div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
