"use client";

import { useEffect, useRef, useState } from "react";
import { Kbd } from "@/components/ui/kbd";

interface Props {
  /** Command to copy to clipboard. Shown verbatim with a leading "$ ". */
  command: string;
  /** Optional shortcut key shown as a Kbd badge. */
  shortcut?: string;
}

/**
 * Terminal-styled block with click-to-copy. Listens for a global
 * `nepalicalendar:copy-install` window event so the card flashes "Copied"
 * even when the copy was triggered by the page-level keyboard shortcut.
 */
export function CopyCommand({ command, shortcut }: Props) {
  const [copied, setCopied] = useState(false);
  const timeoutRef = useRef<number | null>(null);

  function flashCopied() {
    setCopied(true);
    if (timeoutRef.current) window.clearTimeout(timeoutRef.current);
    timeoutRef.current = window.setTimeout(() => setCopied(false), 1600);
  }

  async function copy() {
    try {
      await navigator.clipboard.writeText(command);
      flashCopied();
    } catch {
      // Clipboard API fails on insecure contexts; no-op.
    }
  }

  useEffect(() => {
    function onExternalCopy() {
      flashCopied();
    }
    window.addEventListener("nepalicalendar:copy-install", onExternalCopy);
    return () => {
      window.removeEventListener("nepalicalendar:copy-install", onExternalCopy);
      if (timeoutRef.current) window.clearTimeout(timeoutRef.current);
    };
  }, []);

  return (
    <div className="group relative flex items-center gap-3 rounded-lg border border-border bg-card pl-4 pr-1.5 py-1.5">
      <pre className="flex-1 font-mono text-[13px] leading-6 overflow-x-auto text-foreground py-1.5">
        <span className="text-muted-foreground select-none">$ </span>
        {command}
      </pre>
      <button
        type="button"
        onClick={copy}
        aria-label={copied ? "Copied" : "Copy command"}
        className="shrink-0 inline-flex items-center gap-1.5 px-2.5 h-8 rounded-md text-xs font-medium border border-transparent hover:border-border hover:bg-muted transition-colors outline-none focus-visible:ring-2 focus-visible:ring-ring/40"
      >
        {copied ? <CheckIcon /> : <CopyIcon />}
        <span className="text-foreground">{copied ? "Copied" : "Copy"}</span>
        {shortcut && !copied && <Kbd>{shortcut}</Kbd>}
      </button>
    </div>
  );
}

function CopyIcon() {
  return (
    <svg
      width="13"
      height="13"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden
    >
      <rect x="9" y="9" width="13" height="13" rx="2" />
      <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
    </svg>
  );
}

function CheckIcon() {
  return (
    <svg
      width="13"
      height="13"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.5"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden
    >
      <polyline points="20 6 9 17 4 12" />
    </svg>
  );
}
