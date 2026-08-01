"use client";

import { useEffect, useRef, useState } from "react";
import { AnimatePresence, motion } from "motion/react";
import { CheckIcon, CopyIcon } from "lucide-react";
import { Kbd } from "@/components/ui/kbd";

interface Props {
  command: string;
  shortcut?: string;
}

const ICON_SPRING = { type: "spring" as const, duration: 0.3, bounce: 0 };

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
    } catch {}
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
      className="group relative flex cursor-pointer items-center gap-3 rounded-xl bg-muted/60 py-1 pl-4 pr-3 outline-none transition-[background-color,transform] duration-150 ease-out hover:bg-muted focus-visible:ring-2 focus-visible:ring-ring/40 active:scale-[0.96]"
    >
      <pre className="min-w-0 flex-1 overflow-x-auto py-1.5 text-sm leading-6 text-foreground">
        <span className="select-none text-muted-foreground">$ </span>
        {command}
      </pre>
      <span
        aria-hidden
        className="relative inline-flex h-8 min-w-8 shrink-0 select-none items-center justify-center gap-1.5 text-muted-foreground transition-colors duration-150 group-hover:text-foreground"
      >
        <span className="relative size-4">
          <AnimatePresence initial={false} mode="popLayout">
            <motion.span
              key={copied ? "check" : "copy"}
              className="absolute inset-0 flex items-center justify-center"
              initial={{ opacity: 0, scale: 0.25, filter: "blur(4px)" }}
              animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
              exit={{ opacity: 0, scale: 0.25, filter: "blur(4px)" }}
              transition={ICON_SPRING}
            >
              {copied ? (
                <CheckIcon className="size-4" />
              ) : (
                <CopyIcon className="size-4" />
              )}
            </motion.span>
          </AnimatePresence>
        </span>
        {shortcut && !copied && <Kbd>{shortcut}</Kbd>}
      </span>
    </div>
  );
}
