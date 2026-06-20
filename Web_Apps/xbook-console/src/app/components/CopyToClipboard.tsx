"use client";

import { useState } from "react";

type Props = {
  text: string;
  label?: string;
};

export default function CopyToClipboard({ text, label = "Copy" }: Props) {
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.error("Failed to copy text: ", err);
    }
  };

  return (
    <button
      onClick={handleCopy}
      className="text-[10px] font-bold uppercase text-primary transition hover:underline"
    >
      {copied ? "Copied!" : label}
    </button>
  );
}
