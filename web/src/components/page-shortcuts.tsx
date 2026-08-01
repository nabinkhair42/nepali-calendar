"use client";

import { useTheme } from "next-themes";
import { useEffect } from "react";
import { INSTALL_COMMAND } from "@/lib/app-constants";

/** Global shortcuts: C copy install, D toggle theme. */
export function PageShortcuts() {
  const { setTheme, resolvedTheme } = useTheme();

  useEffect(() => {
    function isTypingTarget(el: EventTarget | null): boolean {
      if (!(el instanceof HTMLElement)) return false;
      const tag = el.tagName;
      return (
        tag === "INPUT" ||
        tag === "TEXTAREA" ||
        tag === "SELECT" ||
        el.isContentEditable
      );
    }

    function onKey(e: KeyboardEvent) {
      if (e.metaKey || e.ctrlKey || e.altKey) return;
      if (isTypingTarget(e.target)) return;
      const k = e.key.toLowerCase();

      if (k === "c") {
        e.preventDefault();
        navigator.clipboard
          .writeText(INSTALL_COMMAND)
          .then(() => {
            window.dispatchEvent(new Event("nepalicalendar:copy-install"));
          })
          .catch(() => {});
      } else if (k === "d") {
        e.preventDefault();
        setTheme(resolvedTheme === "dark" ? "light" : "dark");
      }
    }

    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [resolvedTheme, setTheme]);

  return null;
}
