import React from "react";

export function XLogo({ className = "h-3 w-3" }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true" className={className} fill="currentColor">
      <path d="M18.901 2H22l-6.77 7.736L23.195 22h-6.238l-4.885-7.436L5.56 22H2.46l7.24-8.275L1.805 2H8.2l4.416 6.73L18.901 2Zm-1.086 18.146h1.717L7.267 3.758H5.425l12.39 16.388Z" />
    </svg>
  );
}

export function YouTubeLogo({ className = "h-3 w-4" }: { className?: string }) {
  return (
    <svg viewBox="0 0 28 20" aria-hidden="true" className={className}>
      <path
        d="M27.417 3.132a3.52 3.52 0 0 0-2.477-2.49C22.753 0 14 0 14 0S5.247 0 3.06.642A3.52 3.52 0 0 0 .583 3.132C0 5.33 0 10 0 10s0 4.67.583 6.868a3.52 3.52 0 0 0 2.477 2.49C5.247 20 14 20 14 20s8.753 0 10.94-.642a3.52 3.52 0 0 0 2.477-2.49C28 14.67 28 10 28 10s0-4.67-.583-6.868Z"
        fill="currentColor"
      />
      <path d="m11.2 14.286 7.286-4.286L11.2 5.714v8.572Z" fill="white" />
    </svg>
  );
}

export function CloseIcon({ className = "h-3 w-3" }: { className?: string }) {
  return (
    <svg viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <path d="M15 5L5 15M5 5L15 15" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

export function SearchIcon({ className = "h-4 w-4" }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className={className}>
      <circle cx="11" cy="11" r="8" />
      <line x1="21" y1="21" x2="16.65" y2="16.65" />
    </svg>
  );
}
