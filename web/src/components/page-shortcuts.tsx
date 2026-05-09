"use client";

import { useTheme } from "next-themes";
import { useEffect } from "react";

const DMG_URL = "/downloads/NepaliCalendar.dmg";
const INSTALL_CMD =
  "curl -fsSL https://calendar.nabinkhair.com.np/install.sh | bash";

/**
 * Global keyboard shortcuts:
 *   D — trigger the .dmg download
 *   I — copy the install command to the clipboard
 *   T — toggle light / dark theme
 *
 * Skipped while the user is typing in an input/textarea or holding a
 * modifier (so cmd-D for "bookmark" still works).
 */
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

      if (k === "d") {
        e.preventDefault();
        const a = document.createElement("a");
        a.href = DMG_URL;
        a.download = "NepaliCalendar.dmg";
        document.body.appendChild(a);
        a.click();
        a.remove();
      } else if (k === "i") {
        e.preventDefault();
        navigator.clipboard?.writeText(INSTALL_CMD).catch(() => {});
        window.dispatchEvent(new CustomEvent("nepalicalendar:copy-install"));
      } else if (k === "t") {
        e.preventDefault();
        setTheme(resolvedTheme === "dark" ? "light" : "dark");
      }
    }

    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [resolvedTheme, setTheme]);

  return null;
}
