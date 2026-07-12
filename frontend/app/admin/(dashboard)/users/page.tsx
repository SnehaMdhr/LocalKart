"use client";

import { useState, useRef } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { usersApi, type User, type UserFormData } from "@/lib/api/users";
import StatusBadge from "@/components/admin/StatusBadge";
import { useToast } from "@/context/ToastContext";
import { formatDate, getInitials } from "@/lib/utils/format";
import {
  FiPlus, FiSearch, FiEdit2, FiTrash2, FiEye, FiX, FiAlertCircle, FiUpload,
} from "react-icons/fi";

export default function UsersPage() {
  const queryClient = useQueryClient();
  const { addToast } = useToast();
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [showModal, setShowModal] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [viewingUser, setViewingUser] = useState<User | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [form, setForm] = useState<UserFormData>({ name: "", email: "", password: "", phone: "", role: "Customer" });
  const [formError, setFormError] = useState("");
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["admin-users", page, search],
    queryFn: () => usersApi.getAll({ page, size: 10, search }),
  });

  const createMutation = useMutation({
    mutationFn: (d: UserFormData) => usersApi.create(d),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["admin-users"] }); setShowModal(false); resetForm(); addToast("success", "User created successfully"); },
    onError: (err: any) => {
      setFormError(err?.response?.data?.message || "Failed to create user");
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, d }: { id: string; d: FormData }) => usersApi.update(id, d),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["admin-users"] }); setShowModal(false); resetForm(); addToast("success", "User updated successfully"); },
    onError: (err: any) => {
      setFormError(err?.response?.data?.message || "Failed to update user");
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => usersApi.delete(id),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ["admin-users"] }); setDeleteId(null); addToast("success", "User deleted successfully"); },
    onError: (err: any) => { addToast("error", err?.response?.data?.message || "Failed to delete user"); },
  });

  const users: User[] = data?.data || [];
  const pagination = data?.pagination;

  function resetForm() { setForm({ name: "", email: "", password: "", phone: "", role: "Customer" }); setEditingUser(null); setFormError(""); setImageFile(null); setImagePreview(null); }

  function openEdit(user: User) {
    setEditingUser(user);
    setForm({ name: user.name, email: user.email, phone: user.phone || "", role: user.role, imageUrl: user.imageUrl });
    setImageFile(null);
    setImagePreview(user.imageUrl || null);
    setShowModal(true);
  }

  function openAdd() { resetForm(); setImageFile(null); setImagePreview(null); setShowModal(true); }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setFormError("");
    if (!form.name || !form.email) { setFormError("Name and email are required"); return; }
    if (!editingUser && !form.password) { setFormError("Password is required for new users"); return; }
    if (!editingUser && form.password !== form.confirmPassword) { setFormError("Passwords do not match"); return; }
    if (editingUser) {
      const fd = new FormData();
      fd.append("name", form.name); fd.append("email", form.email);
      if (form.phone) fd.append("phone", form.phone);
      if (form.role) fd.append("role", form.role);
      if (form.password) fd.append("password", form.password);
      if (imageFile) fd.append("imageUrl", imageFile);
      updateMutation.mutate({ id: editingUser._id, d: fd });
    } else {
      createMutation.mutate(form);
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Users</h2>
          <p className="text-sm text-gray-500">Manage all registered users</p>
        </div>
        <button onClick={openAdd} className="flex items-center gap-2 rounded-lg bg-admin-primary px-4 py-2 text-sm font-medium text-white hover:bg-admin-primary-dark transition-colors">
          <FiPlus className="h-4 w-4" /> Add User
        </button>
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <input type="text" placeholder="Search users..." value={search} onChange={e => { setSearch(e.target.value); setPage(1); }}
          className="w-full rounded-lg border border-gray-300 py-2.5 pl-10 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary" />
      </div>

      {/* Table */}
      <div className="overflow-x-auto rounded-xl border border-gray-200 bg-white shadow-sm">
        <table className="min-w-full divide-y divide-gray-100">
          <thead><tr className="bg-gray-50/50">
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Phone</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Joined</th>
            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
          </tr></thead>
          <tbody className="divide-y divide-gray-100">
            {isLoading ? Array.from({ length: 5 }).map((_, i) => (
              <tr key={i}>{Array.from({ length: 6 }).map((_, j) => (
                <td key={j} className="px-6 py-4"><div className="h-4 w-20 animate-pulse rounded bg-gray-200" /></td>
              ))}</tr>
            )) : users.length === 0 ? (
              <tr><td colSpan={6} className="px-6 py-12 text-center text-sm text-gray-400">No users found</td></tr>
            ) : users.map((user) => (
              <tr key={user._id} className="hover:bg-gray-50 transition-colors">
                <td className="px-6 py-4">
                  <div className="flex items-center gap-3">
                    <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-admin-primary-light text-xs font-semibold text-admin-primary overflow-hidden">
                      {user.imageUrl ? (
                        <img src={user.imageUrl} alt="" className="h-full w-full object-cover" />
                      ) : (
                        getInitials(user.name)
                      )}
                    </div>
                    <span className="text-sm font-medium text-gray-900">{user.name}</span>
                  </div>
                </td>
                <td className="px-6 py-4 text-sm text-gray-600">{user.email}</td>
                <td className="px-6 py-4 text-sm text-gray-600">{user.phone || "—"}</td>
                <td className="px-6 py-4"><StatusBadge status={user.role} /></td>
                <td className="px-6 py-4 text-sm text-gray-500">{formatDate(user.createdAt)}</td>
                <td className="px-6 py-4 text-right">
                  <div className="flex items-center justify-end gap-1">
                    <button onClick={() => setViewingUser(user)} className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-admin-primary" title="View"><FiEye className="h-4 w-4" /></button>
                    <button onClick={() => openEdit(user)} className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-green-600" title="Edit"><FiEdit2 className="h-4 w-4" /></button>
                    <button onClick={() => setDeleteId(user._id)} className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-red-600" title="Delete"><FiTrash2 className="h-4 w-4" /></button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {pagination && (
          <div className="flex items-center justify-between border-t border-gray-100 px-6 py-3">
            <span className="text-sm text-gray-500">Page {pagination.page || page} of {pagination.totalPages || 1}</span>
            <div className="flex gap-2">
              <button disabled={page <= 1} onClick={() => setPage(p => p - 1)} className="rounded-lg border border-gray-300 px-3 py-1 text-sm hover:bg-gray-50 disabled:opacity-50">Prev</button>
              <button disabled={page >= (pagination.totalPages || 1)} onClick={() => setPage(p => p + 1)} className="rounded-lg border border-gray-300 px-3 py-1 text-sm hover:bg-gray-50 disabled:opacity-50">Next</button>
            </div>
          </div>
        )}
      </div>

      {/* Add/Edit Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" onClick={() => { if (!createMutation.isPending && !updateMutation.isPending) { setShowModal(false); resetForm(); }}}>
          <div className="w-full max-w-lg rounded-xl bg-white p-6 shadow-xl" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">{editingUser ? "Edit User" : "Add User"}</h3>
              <button onClick={() => { setShowModal(false); resetForm(); }} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100"><FiX className="h-5 w-5" /></button>
            </div>
            {formError && <div className="mb-4 flex items-center gap-2 rounded-lg bg-red-50 p-3 text-sm text-red-700"><FiAlertCircle className="h-4 w-4" />{formError}</div>}
            <form onSubmit={handleSubmit} className="space-y-4">
              <div><label className="block text-sm font-medium text-gray-700 mb-1">Name *</label>
                <input value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))} className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary" /></div>
              <div><label className="block text-sm font-medium text-gray-700 mb-1">Email *</label>
                <input type="email" value={form.email} onChange={e => setForm(f => ({ ...f, email: e.target.value }))} className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary" /></div>
              {!editingUser && (
                <div><label className="block text-sm font-medium text-gray-700 mb-1">Password *</label>
                  <input type="password" value={form.password || ""} onChange={e => setForm(f => ({ ...f, password: e.target.value }))} className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary" /></div>
              )}
              {!editingUser && (
                <div><label className="block text-sm font-medium text-gray-700 mb-1">Confirm Password *</label>
                  <input type="password" value={form.confirmPassword || ""} onChange={e => setForm(f => ({ ...f, confirmPassword: e.target.value }))} className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary" /></div>
              )}
              <div className="grid grid-cols-2 gap-4">
                <div><label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
                  <input value={form.phone || ""} onChange={e => setForm(f => ({ ...f, phone: e.target.value }))} className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary" /></div>
                <div><label className="block text-sm font-medium text-gray-700 mb-1">Role</label>
                  <select value={form.role} onChange={e => setForm(f => ({ ...f, role: e.target.value as "Customer" | "Shopkeeper" | "admin" }))} className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary">
                    <option value="Customer">Customer</option><option value="Shopkeeper">Shopkeeper</option><option value="admin">Admin</option>
                  </select></div>
              </div>

              {/* Image Upload */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Profile Photo</label>
                <div className="flex items-center gap-4">
                  <button
                    type="button"
                    onClick={() => fileInputRef.current?.click()}
                    className="flex items-center gap-2 rounded-lg border border-gray-300 px-4 py-2 text-sm text-gray-600 hover:bg-gray-50 transition-colors"
                  >
                    <FiUpload className="h-4 w-4" />
                    {editingUser ? "Change photo" : "Upload photo"}
                  </button>
                  {imagePreview && (
                    <div className="relative h-12 w-12 shrink-0 overflow-hidden rounded-full border border-gray-200">
                      <img
                        src={imagePreview}
                        alt=""
                        className="h-full w-full object-cover"
                      />
                    </div>
                  )}
                  {imagePreview && editingUser && (
                    <button
                      type="button"
                      onClick={() => { setImageFile(null); setImagePreview(null); }}
                      className="text-xs text-red-500 hover:text-red-700"
                    >
                      Remove
                    </button>
                  )}
                </div>
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  onChange={(e) => {
                    const file = e.target.files?.[0];
                    if (file) {
                      setImageFile(file);
                      setImagePreview(URL.createObjectURL(file));
                    }
                  }}
                  className="hidden"
                />
              </div>

              <div className="flex justify-end gap-3 pt-2">
                <button type="button" onClick={() => { setShowModal(false); resetForm(); }} className="rounded-lg border border-gray-300 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50">Cancel</button>
                <button type="submit" disabled={createMutation.isPending || updateMutation.isPending} className="rounded-lg bg-admin-primary px-4 py-2 text-sm font-medium text-white hover:bg-admin-primary-dark disabled:opacity-50">
                  {createMutation.isPending || updateMutation.isPending ? "Saving..." : editingUser ? "Update User" : "Create User"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      {deleteId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" onClick={() => { if (!deleteMutation.isPending) setDeleteId(null); }}>
          <div className="w-full max-w-sm rounded-xl bg-white p-6 shadow-xl" onClick={e => e.stopPropagation()}>
            <div className="flex items-center gap-3 mb-4"><div className="flex h-10 w-10 items-center justify-center rounded-full bg-red-100"><FiTrash2 className="h-5 w-5 text-red-600" /></div>
              <div><h3 className="text-lg font-semibold text-gray-900">Delete User</h3><p className="text-sm text-gray-500">This action cannot be undone.</p></div>
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
      {viewingUser && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm" onClick={() => setViewingUser(null)}>
          <div className="w-full max-w-lg rounded-xl bg-white p-6 shadow-xl" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-lg font-semibold text-gray-900">User Details</h3>
              <button onClick={() => setViewingUser(null)} className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100"><FiX className="h-5 w-5" /></button>
            </div>
            <div className="flex items-center gap-4 mb-6">
              <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-full bg-admin-primary-light text-lg font-semibold text-admin-primary overflow-hidden">
                {viewingUser.imageUrl ? (
                  <img src={viewingUser.imageUrl} alt="" className="h-full w-full object-cover" />
                ) : (
                  getInitials(viewingUser.name)
                )}
              </div>
              <div><p className="text-lg font-semibold text-gray-900">{viewingUser.name}</p><p className="text-sm text-gray-500">{viewingUser.email}</p></div>
            </div>
            <dl className="space-y-3">
              <div className="flex justify-between py-2 border-b border-gray-100"><dt className="text-sm text-gray-500">Phone</dt><dd className="text-sm text-gray-900">{viewingUser.phone || "—"}</dd></div>
              <div className="flex justify-between py-2 border-b border-gray-100"><dt className="text-sm text-gray-500">Role</dt><dd><StatusBadge status={viewingUser.role} /></dd></div>
              <div className="flex justify-between py-2"><dt className="text-sm text-gray-500">Joined</dt><dd className="text-sm text-gray-900">{formatDate(viewingUser.createdAt)}</dd></div>
            </dl>
          </div>
        </div>
      )}
    </div>
  );
}
