import Link from "next/link";
import { ThemeSwitcher } from "@/components/theme-switcher";

/**
 * Top nav. Wordmark left ("calendar."), theme toggle right.
 * Sits inside the centered column; the diagonal-hatch rails handle the
 * outer chrome.
 */
export function SiteHeader() {
  return (
    <header className="flex h-14 items-center justify-between px-2">
      <Link
        href="/"
        className="text-sm font-medium tracking-tight text-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring/40 rounded-sm"
      >
        calendar.
      </Link>
      <div className="flex items-center gap-3">
        <ThemeSwitcher />
      </div>
    </header>
  );
}
