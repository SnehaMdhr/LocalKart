"use client";

import { useEffect, useState, useCallback } from "react";
import { FiX, FiCheckCircle, FiAlertCircle, FiInfo, FiAlertTriangle } from "react-icons/fi";

export type ToastType = "success" | "error" | "info" | "warning";

export interface ToastData {
  id: string;
  type: ToastType;
  message: string;
}

const ICONS: Record<ToastType, React.ReactNode> = {
  success: <FiCheckCircle className="h-5 w-5 text-emerald-500" />,
  error: <FiAlertCircle className="h-5 w-5 text-red-500" />,
  info: <FiInfo className="h-5 w-5 text-blue-500" />,
  warning: <FiAlertTriangle className="h-5 w-5 text-amber-500" />,
};

const STYLES: Record<ToastType, string> = {
  success: "border-emerald-200 bg-emerald-50",
  error: "border-red-200 bg-red-50",
  info: "border-blue-200 bg-blue-50",
  warning: "border-amber-200 bg-amber-50",
};

function ToastItem({ toast, onDismiss }: { toast: ToastData; onDismiss: (id: string) => void }) {
  useEffect(() => {
    const timer = setTimeout(() => onDismiss(toast.id), 4000);
    return () => clearTimeout(timer);
  }, [toast.id, onDismiss]);

  return (
    <div
      className={`flex items-start gap-3 rounded-lg border px-4 py-3 shadow-lg backdrop-blur-sm transition-all duration-300 ${STYLES[toast.type]}`}
    >
      <span className="shrink-0 mt-0.5">{ICONS[toast.type]}</span>
      <p className="flex-1 text-sm text-gray-800">{toast.message}</p>
      <button
        onClick={() => onDismiss(toast.id)}
        className="shrink-0 rounded p-0.5 text-gray-400 hover:text-gray-600 transition-colors"
      >
        <FiX className="h-4 w-4" />
      </button>
    </div>
  );
}

export default function ToastContainer({ toasts, onDismiss }: { toasts: ToastData[]; onDismiss: (id: string) => void }) {
  if (toasts.length === 0) return null;

  return (
    <div className="fixed top-4 right-4 z-[100] flex flex-col gap-2 w-80 max-w-[calc(100vw-2rem)]">
      {toasts.map((toast) => (
        <ToastItem key={toast.id} toast={toast} onDismiss={onDismiss} />
      ))}
    </div>
  );
}
