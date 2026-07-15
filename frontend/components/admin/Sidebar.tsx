"use client";


import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  FiGrid,
  FiUsers,
  FiShoppingBag,
  FiPackage,
  FiShoppingCart,
  FiClipboard,
  FiX,
} from "react-icons/fi";

interface NavItem {
  label: string;
  href: string;
  icon: React.ReactNode;
  badge?: number;
}

const navItems: NavItem[] = [
  { label: "Dashboard", href: "/admin/dashboard", icon: <FiGrid className="h-5 w-5" /> },
  { label: "Order", href: "/admin/orders", icon: <FiClipboard className="h-5 w-5" /> },
  { label: "Products", href: "/admin/products", icon: <FiPackage className="h-5 w-5" /> },
  { label: "Shops", href: "/admin/shops", icon: <FiShoppingBag className="h-5 w-5" /> },
  { label: "Users", href: "/admin/users", icon: <FiUsers className="h-5 w-5" /> },
];

interface SidebarProps {
  isMobileOpen: boolean;
  onMobileClose: () => void;
}

export default function Sidebar({
  isMobileOpen,
  onMobileClose,
}: SidebarProps) {
  const pathname = usePathname();

  const isActive = (href: string) => {
    if (href === "/admin/dashboard") {
      return pathname === "/admin/dashboard";
    }
    return pathname.startsWith(href);
  };

  const sidebarContent = (
    <div className="flex h-full flex-col bg-white">
      {/* Logo */}
      <div className="flex h-16 items-center gap-3 border-b border-gray-100 px-6">
        <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-white p-1 shadow-sm">
          <img
            src="/logo1.png"
            alt="LocalKart"
            className="h-full w-full object-contain"
          />
        </div>
        <div className="flex flex-col">
          <span className="text-base font-semibold">
            <span className="text-admin-primary">Local</span><span className="text-gray-900">Kart</span>
          </span>
          <span className="-mt-0.5 text-[11px] font-medium text-gray-400 uppercase tracking-wider">
            Admin Panel
          </span>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto px-3 py-4">
        <ul className="space-y-1">
          {navItems.map((item) => {
            const active = isActive(item.href);
            return (
              <li key={item.href}>
                <Link
                  href={item.href}
                  onClick={onMobileClose}
                  className={`group relative flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-all ${
                    active
                      ? "bg-admin-primary-light text-admin-primary"
                      : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                  }`}
                >
                  <span
                    className={`shrink-0 transition-colors ${
                      active ? "text-admin-primary" : "text-gray-400 group-hover:text-gray-600"
                    }`}
                  >
                    {item.icon}
                  </span>
                  <>
                    <span className="flex-1">{item.label}</span>
                    {item.badge !== undefined && item.badge > 0 && (
                      <span className="inline-flex items-center justify-center rounded-full bg-red-50 px-2 py-0.5 text-xs font-medium text-red-600 ring-1 ring-red-500/10">
                        {item.badge}
                      </span>
                    )}
                    {active && (
                      <span className="absolute inset-y-2 -left-3 w-1 rounded-r-full bg-admin-primary" />
                    )}
                  </>
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>

    </div>
  );

  return (
    <>
      {/* Desktop sidebar */}
      <aside
        className="hidden w-64 border-r border-gray-200 bg-white lg:block"
      >
        {sidebarContent}
      </aside>

      {/* Mobile sidebar overlay */}
      {isMobileOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <div
            className="fixed inset-0 bg-gray-900/50 backdrop-blur-sm"
            onClick={onMobileClose}
          />
          <aside className="relative z-50 h-full w-72 shadow-xl">
            <div className="absolute right-3 top-3">
              <button
                onClick={onMobileClose}
                className="flex h-8 w-8 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-100 hover:text-gray-600"
              >
                <FiX className="h-5 w-5" />
              </button>
            </div>
            {sidebarContent}
          </aside>
        </div>
      )}
    </>
  );
}
