"use client";

interface StatusBadgeProps {
  status: string;
  size?: "sm" | "md";
}

const colorMap: Record<string, string> = {
  active: "bg-emerald-50 text-emerald-700 ring-emerald-600/10",
  inactive: "bg-gray-50 text-gray-700 ring-gray-600/10",
  pending: "bg-amber-50 text-amber-700 ring-amber-600/10",
  suspended: "bg-red-50 text-red-700 ring-red-600/10",
  approved: "bg-emerald-50 text-emerald-700 ring-emerald-600/10",
  rejected: "bg-red-50 text-red-700 ring-red-600/10",
  delivered: "bg-emerald-50 text-emerald-700 ring-emerald-600/10",
  processing: "bg-admin-primary-light text-admin-primary ring-admin-primary/10",
  shipped: "bg-purple-50 text-purple-700 ring-purple-600/10",
  cancelled: "bg-gray-50 text-gray-700 ring-gray-600/10",
  paid: "bg-emerald-50 text-emerald-700 ring-emerald-600/10",
  unpaid: "bg-amber-50 text-amber-700 ring-amber-600/10",
  refunded: "bg-red-50 text-red-700 ring-red-600/10",
  completed: "bg-emerald-50 text-emerald-700 ring-emerald-600/10",
  customer: "bg-admin-primary-light text-admin-primary ring-admin-primary/10",
  vendor: "bg-purple-50 text-purple-700 ring-purple-600/10",
  admin: "bg-rose-50 text-rose-700 ring-rose-600/10",
  shopkeeper: "bg-purple-50 text-purple-700 ring-purple-600/10",
};

export default function StatusBadge({ status, size = "sm" }: StatusBadgeProps) {
  const styles =
    colorMap[status?.toLowerCase()] ||
    "bg-gray-50 text-gray-700 ring-gray-600/10";

  const sizeStyles = size === "sm" ? "px-2 py-0.5 text-xs" : "px-2.5 py-1 text-sm";

  return (
    <span
      className={`inline-flex items-center rounded-full font-medium ring-1 ring-inset ${sizeStyles} ${styles}`}
    >
      {status}
    </span>
  );
}
