"use client";

import { useEffect, useRef, useState } from "react";
import { Kbd } from "@/components/ui/kbd";
import { CheckIcon, CopyIcon } from "lucide-react";

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

  function onKeyDown(e: React.KeyboardEvent<HTMLDivElement>) {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      copy();
    }
  }

  return (
    <div
      role="button"
      tabIndex={0}
      onClick={copy}
      onKeyDown={onKeyDown}
      aria-label={copied ? "Copied" : "Copy command"}
      className="group relative flex cursor-pointer items-center gap-3 rounded-lg border border-border bg-card pl-4 pr-3 py-0.5 transition-colors hover:bg-muted/40 outline-none focus-visible:ring-2 focus-visible:ring-ring/40"
    >
      <pre className="min-w-0 flex-1 font-mono text-[13px] leading-6 overflow-x-auto text-foreground py-0.5">
        <span className="text-muted-foreground select-none">$ </span>
        {command}
      </pre>
      <span
        aria-hidden
        className="shrink-0 inline-flex h-6 items-center gap-1.5 px-1 text-muted-foreground transition-colors group-hover:text-foreground"
      >
        {copied ? <CheckIcon className="h-4 w-4" /> : <CopyIcon className="h-4 w-4" />}
        {shortcut && !copied && <Kbd>{shortcut}</Kbd>}
      </span>
    </div>
  );
}
