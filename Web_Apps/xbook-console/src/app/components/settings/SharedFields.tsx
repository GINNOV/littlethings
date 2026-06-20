"use client";

import { useState } from "react";
import type React from "react";
import type { InputHTMLAttributes } from "react";

type SettingsSectionProps = {
  title: string;
  description: string;
  children: React.ReactNode;
  icon?: React.ReactNode;
  defaultOpen?: boolean;
};

export const secondaryButtonClass =
  "rounded-md border border-black/10 px-4 py-2 text-sm font-semibold text-slate-800 transition hover:bg-slate-50 disabled:opacity-60";

export const primaryButtonClass =
  "rounded-md bg-emerald-700 px-4 py-2 text-sm font-semibold text-white transition hover:bg-emerald-800 disabled:opacity-60";

export function SettingsSection({
  title,
  description,
  children,
  icon,
  defaultOpen = false,
}: SettingsSectionProps) {
  return (
    <details
      open={defaultOpen || undefined}
      className="group/settings rounded-lg border border-black/10 bg-white p-6 shadow-sm"
    >
      <summary className="flex cursor-pointer list-none items-center justify-between gap-4">
        <span className="flex min-w-0 items-center gap-3">
          {icon ? icon : null}
          <span className="min-w-0">
            <span className="block text-lg font-semibold">{title}</span>
            <span className="block text-xs text-slate-500">{description}</span>
          </span>
        </span>
        <span
          aria-hidden="true"
          className="shrink-0 text-slate-500 transition-transform duration-200 group-open/settings:rotate-180"
        >
          <svg
            viewBox="0 0 20 20"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            className="h-5 w-5"
          >
            <path
              d="M5 7.5L10 12.5L15 7.5"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </span>
      </summary>
      <div className="mt-5">{children}</div>
    </details>
  );
}

export function HelpTooltip({ text }: { text: string }) {
  return (
    <span className="tooltip-help relative ml-1 inline-block">
      <span className="cursor-help text-xs text-slate-400">(?)</span>
      <span className="tooltip-help-content pointer-events-none absolute bottom-full left-1/2 mb-2 w-48 -translate-x-1/2 rounded bg-slate-800 p-2 text-center text-[10px] leading-tight text-white opacity-0 transition-opacity">
        {text}
        <span className="absolute top-full left-1/2 -ml-1 border-4 border-transparent border-t-slate-800" />
      </span>
    </span>
  );
}

type SecretFieldProps = {
  label: React.ReactNode;
  value: string | null | undefined;
  onChange: (event: React.ChangeEvent<HTMLInputElement>) => void;
  placeholder?: string;
  inputProps?: Omit<InputHTMLAttributes<HTMLInputElement>, "type" | "value" | "onChange">;
};

export function SecretField({ label, value, onChange, placeholder, inputProps }: SecretFieldProps) {
  const [visible, setVisible] = useState(false);

  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between gap-3">
        <label className="text-sm font-semibold">{label}</label>
        <button
          type="button"
          onClick={() => setVisible((prev) => !prev)}
          className="text-xs font-semibold text-slate-500 transition hover:text-slate-800"
        >
          {visible ? "Hide" : "Show"}
        </button>
      </div>
      <input
        {...inputProps}
        type={visible ? "text" : "password"}
        value={value ?? ""}
        onChange={onChange}
        placeholder={placeholder}
        className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm"
      />
    </div>
  );
}
