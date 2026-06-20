"use client";

import { useEffect } from "react";

type Props = {
  isOpen: boolean; onClose: () => void; onConfirm: () => void;
  title: string; message: string; confirmLabel?: string; cancelLabel?: string; variant?: "primary" | "danger";
};

function DialogButtons({ onClose, onConfirm, cancel, confirm, variant }: {
  onClose: () => void;
  onConfirm: () => void;
  cancel: string;
  confirm: string;
  variant: "primary" | "danger";
}) {
  const c = variant === "danger" ? "bg-error" : "bg-primary";
  return (
    <div className="mt-8 flex justify-end gap-3">
      <button onClick={onClose} className="rounded-full px-5 py-2 text-sm font-semibold text-on-surface-variant hover:bg-surface-container-high">{cancel}</button>
      <button onClick={() => { onConfirm(); onClose(); }} className={`rounded-full px-6 py-2 text-sm font-semibold text-white ${c}`}>{confirm}</button>
    </div>
  );
}

export default function ConfirmationDialog({ isOpen, onClose, onConfirm, title, message, confirmLabel = "Confirm", cancelLabel = "Cancel", variant = "primary" }: Props) {
  useEffect(() => {
    if (!isOpen) return;
    const esc = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", esc);
    return () => window.removeEventListener("keydown", esc);
  }, [isOpen, onClose]);

  if (!isOpen) return null;
  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div className="fixed inset-0 bg-black/40 backdrop-blur-sm" onClick={onClose} />
      <div className="relative w-full max-w-md rounded-2xl bg-surface p-6 shadow-2xl border border-outline-variant/30">
        <h3 className="font-headline text-xl font-semibold">{title}</h3>
        <p className="mt-4 text-sm leading-relaxed text-on-surface-variant">{message}</p>
        <DialogButtons onClose={onClose} onConfirm={onConfirm} cancel={cancelLabel} confirm={confirmLabel} variant={variant} />
      </div>
    </div>
  );
}
