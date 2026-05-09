"use client";

import { useState } from "react";
import { HugeiconsIcon } from "@hugeicons/react";
import { Copy01Icon, Tick02Icon } from "@hugeicons/core-free-icons";

export function CodeBlock({ code, label }: { code: string; label?: string }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(code);
      setCopied(true);
      setTimeout(() => setCopied(false), 1800);
    } catch {
      // clipboard unavailable — fail silently
    }
  };

  return (
    <div className="relative">
      <pre className="rounded-xl bg-black text-white text-[13px] font-mono p-4 pr-14 overflow-x-auto">
        <code>{code}</code>
      </pre>
      <button
        type="button"
        onClick={handleCopy}
        aria-label={copied ? "Copied" : `Copy ${label ?? "to clipboard"}`}
        className="focus-ring absolute top-2.5 right-2.5 inline-flex items-center justify-center w-8 h-8 rounded-md bg-white/10 hover:bg-white/20 text-white/70 hover:text-white transition"
      >
        <HugeiconsIcon icon={copied ? Tick02Icon : Copy01Icon} size={14} />
      </button>
    </div>
  );
}
