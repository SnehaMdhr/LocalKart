"use client";

import { useState, useRef } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  productsApi,
  CATEGORIES,
  type Product,
  type ProductCategory,
} from "@/lib/api/products";
import StatusBadge from "@/components/admin/StatusBadge";
import { useToast } from "@/context/ToastContext";
import { formatDate, formatCurrency } from "@/lib/utils/format";
import {
  FiPlus,
  FiSearch,
  FiEdit2,
  FiTrash2,
  FiEye,
  FiX,
  FiToggleLeft,
  FiToggleRight,
  FiUpload,
  FiAlertCircle,
} from "react-icons/fi";

const productSchema = z.object({
  productName: z.string().min(2, "Name must be at least 2 characters").max(100),
  description: z.string().max(256).optional(),
  categoryName: z.enum(CATEGORIES, { message: "Select a category" }),
  price: z.coerce.number().int().min(1, "Price is required"),
  unit: z.string().min(1, "Unit is required"),
});

type ProductFormValues = z.infer<typeof productSchema>;

const UNITS = ["kg", "litre", "packet", "piece", "dozen", "gram", "ml"];

export default function ProductsPage() {
  const queryClient = useQueryClient();
  const { addToast } = useToast();
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [showModal, setShowModal] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [viewingProduct, setViewingProduct] = useState<Product | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [submitError, setSubmitError] = useState("");
  const fileInputRef = useRef<HTMLInputElement>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["admin-products", page, search],
    queryFn: () => productsApi.getAll({ page, size: 10, search }),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => productsApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-products"] });
      setDeleteId(null);
      addToast("success", "Product deleted successfully");
    },
    onError: (err: any) => { addToast("error", err?.response?.data?.message || "Failed to delete product"); },
  });

  const toggleMutation = useMutation({
    mutationFn: ({
      id,
      action,
    }: {
      id: string;
      action: "activate" | "deactivate";
    }) =>
      action === "activate"
        ? productsApi.activate(id)
        : productsApi.deactivate(id),
    onSuccess: (_, variables) =>
      {
        queryClient.invalidateQueries({ queryKey: ["admin-products"] });
        addToast("success", variables.action === "activate" ? "Product activated" : "Product deactivated");
      },
    onError: (err: any) => { addToast("error", err?.response?.data?.message || "Failed to toggle product status"); },
  });

  const saveMutation = useMutation({
    mutationFn: async (formData: FormData) => {
      if (editingProduct) {
        return productsApi.update(editingProduct._id, formData);
      }
      return productsApi.create(formData);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin-products"] });
      closeModal();
      addToast("success", editingProduct ? "Product updated successfully" : "Product created successfully");
    },
    onError: (err: any) => {
      setSubmitError(
        err?.response?.data?.message ||
          err?.message ||
          "Failed to save product",
      );
    },
  });

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<ProductFormValues>({
    resolver: zodResolver(productSchema) as any,
    defaultValues: {
      productName: "",
      description: "",
      categoryName: undefined,
      price: undefined,
      unit: "",
    },
  });

  const products: Product[] = data?.products || [];
  const pagination = data?.total
    ? {
        page,
        size: 10,
        total: data.total,
        totalPages: Math.ceil(data.total / 10),
      }
    : undefined;

  function openAdd() {
    setEditingProduct(null);
    setImageFile(null);
    setImagePreview(null);
    setSubmitError("");
    reset({
      productName: "",
      description: "",
      categoryName: undefined,
      price: undefined,
      unit: "",
    });
    setShowModal(true);
  }

  function openEdit(product: Product) {
    setEditingProduct(product);
    setImageFile(null);
    setImagePreview(product.imageUrl || null);
    setSubmitError("");
    reset({
      productName: product.productName,
      description: product.description || "",
      categoryName: product.categoryName as ProductCategory,
      price: product.price,
      unit: product.unit,
    });
    setShowModal(true);
  }

  function closeModal() {
    setShowModal(false);
    setEditingProduct(null);
    setImageFile(null);
    setImagePreview(null);
    setSubmitError("");
  }

  function onFormSubmit(values: ProductFormValues) {
    setSubmitError("");
    const parsedPrice = values.price;
    if (isNaN(parsedPrice) || parsedPrice <= 0) {
      setSubmitError("Price must be a positive number");
      return;
    }
    const fd = new FormData();
    fd.append("productName", values.productName);
    fd.append("categoryName", values.categoryName);
    fd.append("price", values.price.toString());
    fd.append("unit", values.unit);
    if (values.description) fd.append("description", values.description);
    if (imageFile) fd.append("imageUrl", imageFile);

    saveMutation.mutate(fd);
  }

  function handleImageChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) {
      setImageFile(file);
      setImagePreview(URL.createObjectURL(file));
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Products</h2>
          <p className="text-sm text-gray-500">Manage all products</p>
        </div>
        <button
          onClick={openAdd}
          className="flex items-center gap-2 rounded-lg bg-admin-primary px-4 py-2 text-sm font-medium text-white hover:bg-admin-primary-dark transition-colors"
        >
          <FiPlus className="h-4 w-4" /> Add Product
        </button>
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <FiSearch className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
        <input
          type="text"
          placeholder="Search products..."
          value={search}
          onChange={(e) => {
            setSearch(e.target.value);
            setPage(1);
          }}
          className="w-full rounded-lg border border-gray-300 py-2.5 pl-10 pr-4 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary"
        />
      </div>

      {/* Table */}
      <div className="overflow-x-auto rounded-xl border border-gray-200 bg-white shadow-sm">
        <table className="min-w-full divide-y divide-gray-100">
          <thead>
            <tr className="bg-gray-50/50">
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Product
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Category
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Price
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Unit
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Status
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Created
              </th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {isLoading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <tr key={i}>
                  {Array.from({ length: 7 }).map((_, j) => (
                    <td key={j} className="px-6 py-4">
                      <div className="h-4 w-20 animate-pulse rounded bg-gray-200" />
                    </td>
                  ))}
                </tr>
              ))
            ) : products.length === 0 ? (
              <tr>
                <td
                  colSpan={7}
                  className="px-6 py-12 text-center text-sm text-gray-400"
                >
                  No products found
                </td>
              </tr>
            ) : (
              products.map((product) => (
                <tr
                  key={product._id}
                  className="hover:bg-gray-50 transition-colors"
                >
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-orange-100 overflow-hidden">
                        {product.imageUrl ? (
                          <img
                            src={product.imageUrl}
                            alt=""
                            className="h-full w-full object-cover"
                          />
                        ) : (
                          <span className="text-xs font-semibold text-orange-700">
                            {product.productName?.charAt(0)?.toUpperCase()}
                          </span>
                        )}
                      </div>
                      <span className="text-sm font-medium text-gray-900">
                        {product.productName}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-600">
                    {product.categoryName || "—"}
                  </td>
                  <td className="px-6 py-4 text-sm font-medium text-gray-900">
                    {formatCurrency(product.price)}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-600">
                    /{product.unit || "—"}
                  </td>
                  <td className="px-6 py-4">
                    <StatusBadge
                      status={product.isActive ? "active" : "inactive"}
                    />
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-500">
                    {formatDate(product.createdAt)}
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-1">
                      <button
                        onClick={() => setViewingProduct(product)}
                        className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-admin-primary"
                        title="View"
                      >
                        <FiEye className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => openEdit(product)}
                        className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-green-600"
                        title="Edit"
                      >
                        <FiEdit2 className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() =>
                          toggleMutation.mutate({
                            id: product._id,
                            action: product.isActive
                              ? "deactivate"
                              : "activate",
                          })
                        }
                        className={`rounded-lg p-2 hover:bg-gray-100 ${product.isActive ? "text-gray-400 hover:text-orange-600" : "text-gray-400 hover:text-emerald-600"}`}
                        title={product.isActive ? "Deactivate" : "Activate"}
                      >
                        {product.isActive ? (
                          <FiToggleLeft className="h-4 w-4" />
                        ) : (
                          <FiToggleRight className="h-4 w-4" />
                        )}
                      </button>
                      <button
                        onClick={() => setDeleteId(product._id)}
                        className="rounded-lg p-2 text-gray-400 hover:bg-gray-100 hover:text-red-600"
                        title="Delete"
                      >
                        <FiTrash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
        {pagination && (
          <div className="flex items-center justify-between border-t border-gray-100 px-6 py-3">
            <span className="text-sm text-gray-500">
              Page {pagination.page || page} of {pagination.totalPages || 1}
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

      {/* Add/Edit Modal */}
      {showModal && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
          onClick={() => {
            if (!saveMutation.isPending) closeModal();
          }}
        >
          <div
            className="w-full max-w-lg rounded-xl bg-white p-6 shadow-xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">
                {editingProduct ? "Edit Product" : "Add Product"}
              </h3>
              <button
                onClick={closeModal}
                className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100"
              >
                <FiX className="h-5 w-5" />
              </button>
            </div>

            {submitError && (
              <div className="mb-4 flex items-center gap-2 rounded-lg bg-red-50 p-3 text-sm text-red-700">
                <FiAlertCircle className="h-4 w-4 shrink-0" />
                {submitError}
              </div>
            )}

            <form onSubmit={handleSubmit(onFormSubmit)} className="space-y-4">
              {/* Product Name */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Product Name *
                </label>
                <input
                  {...register("productName")}
                  className={`w-full rounded-lg border px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary ${errors.productName ? "border-red-300" : "border-gray-300"}`}
                />
                {errors.productName && (
                  <p className="mt-1 text-xs text-red-600">
                    {errors.productName.message}
                  </p>
                )}
              </div>

              {/* Category + Unit row */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Category *
                  </label>
                  <select
                    {...register("categoryName")}
                    className={`w-full rounded-lg border px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary ${errors.categoryName ? "border-red-300" : "border-gray-300"}`}
                  >
                    <option value="">Select category</option>
                    {CATEGORIES.map((c) => (
                      <option key={c} value={c}>
                        {c}
                      </option>
                    ))}
                  </select>
                  {errors.categoryName && (
                    <p className="mt-1 text-xs text-red-600">
                      {errors.categoryName.message}
                    </p>
                  )}
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Unit *
                  </label>
                  <select
                    {...register("unit")}
                    className={`w-full rounded-lg border px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary ${errors.unit ? "border-red-300" : "border-gray-300"}`}
                  >
                    <option value="">Select unit</option>
                    {UNITS.map((u) => (
                      <option key={u} value={u}>
                        {u}
                      </option>
                    ))}
                  </select>
                  {errors.unit && (
                    <p className="mt-1 text-xs text-red-600">
                      {errors.unit.message}
                    </p>
                  )}
                </div>
              </div>

              {/* Price */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Price *
                </label>
                <div className="relative">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-gray-400">
                    Rs.
                  </span>
                  <input
                    type="number"
                    step="0.01"
                    {...register("price", {
                      valueAsNumber: true,
                    })}
                    className={`w-full rounded-lg border py-2 pl-10 pr-3 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary ${errors.price ? "border-red-300" : "border-gray-300"}`}
                  />
                </div>
                {errors.price && (
                  <p className="mt-1 text-xs text-red-600">
                    {errors.price.message}
                  </p>
                )}
              </div>

              {/* Description */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Description
                </label>
                <textarea
                  rows={2}
                  {...register("description")}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-admin-primary"
                />
                {errors.description && (
                  <p className="mt-1 text-xs text-red-600">
                    {errors.description.message}
                  </p>
                )}
              </div>

              {/* Image Upload */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Image
                </label>
                <div className="flex items-center gap-4">
                  <button
                    type="button"
                    onClick={() => fileInputRef.current?.click()}
                    className="flex items-center gap-2 rounded-lg border border-gray-300 px-4 py-2 text-sm text-gray-600 hover:bg-gray-50 transition-colors"
                  >
                    <FiUpload className="h-4 w-4" /> Choose file
                  </button>
                  {imagePreview && (
                    <div className="relative h-12 w-12 shrink-0 overflow-hidden rounded-lg border border-gray-200">
                      <img
                        src={imagePreview}
                        alt=""
                        className="h-full w-full object-cover"
                      />
                    </div>
                  )}
                </div>
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  onChange={handleImageChange}
                  className="hidden"
                />
              </div>

              {/* Submit */}
              <div className="flex justify-end gap-3 pt-2">
                <button
                  type="button"
                  onClick={closeModal}
                  className="rounded-lg border border-gray-300 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={saveMutation.isPending}
                  className="rounded-lg bg-admin-primary px-4 py-2 text-sm font-medium text-white hover:bg-admin-primary-dark disabled:opacity-50"
                >
                  {saveMutation.isPending
                    ? "Saving..."
                    : editingProduct
                      ? "Update Product"
                      : "Create Product"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation */}
      {deleteId && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
          onClick={() => {
            if (!deleteMutation.isPending) setDeleteId(null);
          }}
        >
          <div
            className="w-full max-w-sm rounded-xl bg-white p-6 shadow-xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center gap-3 mb-4">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-red-100">
                <FiTrash2 className="h-5 w-5 text-red-600" />
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">
                  Delete Product
                </h3>
                <p className="text-sm text-gray-500">
                  This action cannot be undone.
                </p>
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

      {/* View Modal */}
      {viewingProduct && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
          onClick={() => setViewingProduct(null)}
        >
          <div
            className="w-full max-w-lg rounded-xl bg-white p-6 shadow-xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-lg font-semibold text-gray-900">
                Product Details
              </h3>
              <button
                onClick={() => setViewingProduct(null)}
                className="rounded-lg p-1.5 text-gray-400 hover:bg-gray-100"
              >
                <FiX className="h-5 w-5" />
              </button>
            </div>
            <div className="flex items-center gap-4 mb-6">
              <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-xl bg-orange-100 overflow-hidden">
                {viewingProduct.imageUrl ? (
                  <img
                    src={viewingProduct.imageUrl}
                    alt=""
                    className="h-full w-full object-cover"
                  />
                ) : (
                  <span className="text-lg font-semibold text-orange-700">
                    {viewingProduct.productName?.charAt(0)?.toUpperCase()}
                  </span>
                )}
              </div>
              <div>
                <p className="text-lg font-semibold text-gray-900">
                  {viewingProduct.productName}
                </p>
                <p className="text-sm text-gray-500">
                  {viewingProduct.categoryName}
                </p>
              </div>
            </div>
            <dl className="space-y-3">
              <div className="flex justify-between py-2 border-b border-gray-100">
                <dt className="text-sm text-gray-500">Price</dt>
                <dd className="text-sm font-medium text-gray-900">
                  {formatCurrency(viewingProduct.price)} / {viewingProduct.unit}
                </dd>
              </div>
              <div className="flex justify-between py-2 border-b border-gray-100">
                <dt className="text-sm text-gray-500">Category</dt>
                <dd className="text-sm text-gray-900">
                  {viewingProduct.categoryName}
                </dd>
              </div>
              <div className="flex justify-between py-2 border-b border-gray-100">
                <dt className="text-sm text-gray-500">Unit</dt>
                <dd className="text-sm text-gray-900">{viewingProduct.unit}</dd>
              </div>
              <div className="flex justify-between py-2 border-b border-gray-100">
                <dt className="text-sm text-gray-500">Status</dt>
                <dd>
                  <StatusBadge
                    status={viewingProduct.isActive ? "active" : "inactive"}
                  />
                </dd>
              </div>
              <div className="flex justify-between py-2">
                <dt className="text-sm text-gray-500">Created</dt>
                <dd className="text-sm text-gray-900">
                  {formatDate(viewingProduct.createdAt)}
                </dd>
              </div>
            </dl>
            {viewingProduct.description && (
              <div className="mt-4 p-3 rounded-lg bg-gray-50">
                <p className="text-sm text-gray-600">
                  {viewingProduct.description}
                </p>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
