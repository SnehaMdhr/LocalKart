"use client";

import { useState, useRef, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/context/AuthContext";
import EditProfileModal from "./EditProfileModal";
import {
  FiMenu,
  FiChevronDown,
  FiEdit3,
  FiLogOut,
} from "react-icons/fi";

interface NavbarProps {
  onMenuClick: () => void;
}

export default function Navbar({ onMenuClick }: NavbarProps) {
  const { user, logout } = useAuth();
  const router = useRouter();
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [showEditProfile, setShowEditProfile] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node)
      ) {
        setIsDropdownOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleLogout = () => {
    logout();
    router.push("/admin/login");
  };

  const initials = user?.name
    ? user.name
        .split(" ")
        .map((n: string) => n[0])
        .join("")
        .toUpperCase()
        .slice(0, 2)
    : "A";

  return (
    <header className="sticky top-0 z-30 flex h-16 shrink-0 items-center border-b border-gray-200 bg-white/80 backdrop-blur-sm">
      <div className="flex flex-1 items-center justify-between px-4 sm:px-6">
        {/* Left: hamburger + breadcrumb */}
        <div className="flex items-center gap-4">
          <button
            onClick={onMenuClick}
            className="flex h-9 w-9 items-center justify-center rounded-lg text-gray-500 hover:bg-gray-100 hover:text-gray-700 lg:hidden"
          >
            <FiMenu className="h-5 w-5" />
          </button>
          <div>
            <h1 className="text-lg font-semibold text-gray-900">Dashboard</h1>
            <p className="text-xs text-gray-500">
              Welcome back, {user?.name || "Admin"}
            </p>
          </div>
        </div>

        {/* Right: notifications + profile */}
        <div className="flex items-center gap-3">
        

          {/* Profile dropdown */}
          <div className="relative" ref={dropdownRef}>
            <button
              onClick={() => setIsDropdownOpen(!isDropdownOpen)}
              className="flex items-center gap-2.5 rounded-lg p-1.5 transition-colors hover:bg-gray-100"
            >
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-admin-primary text-xs font-semibold text-white shadow-sm">
                {initials}
              </div>
              <div className="hidden text-left md:block">
                <p className="text-sm font-medium text-gray-900">
                  {user?.name || "Admin"}
                </p>
                <p className="-mt-0.5 text-xs text-gray-500">
                  {user?.email || ""}
                </p>
              </div>
              <FiChevronDown className="hidden h-4 w-4 text-gray-400 md:block" />
            </button>

            {isDropdownOpen && (
              <div className="absolute right-0 mt-2 w-56 origin-top-right rounded-xl border border-gray-200 bg-white p-1.5 shadow-lg ring-1 ring-black/5">
                <div className="border-b border-gray-100 px-3 py-2.5">
                  <p className="text-sm font-medium text-gray-900">
                    {user?.name}
                  </p>
                  <p className="text-xs text-gray-500">{user?.email}</p>
                </div>

                <button
                  onClick={() => {
                    setIsDropdownOpen(false);
                    setShowEditProfile(true);
                  }}
                  className="flex w-full items-center gap-2.5 rounded-lg px-3 py-2 text-sm text-gray-600 hover:bg-gray-50"
                >
                  <FiEdit3 className="h-4 w-4 text-gray-400" />
                  Edit Profile
                </button>
                <div className="my-1 border-t border-gray-100" />

                <button
                  onClick={handleLogout}
                  className="flex w-full items-center gap-2.5 rounded-lg px-3 py-2 text-sm text-red-600 hover:bg-red-50"
                >
                  <FiLogOut className="h-4 w-4" />
                  Sign out
                </button>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Edit Profile Modal */}
      {showEditProfile && (
        <EditProfileModal
          key="edit-profile"
          isOpen={showEditProfile}
          onClose={() => setShowEditProfile(false)}
        />
      )}
    </header>
  );
}
