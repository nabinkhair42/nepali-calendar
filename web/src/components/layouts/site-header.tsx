"use client";

import { Download, Moon, Sun } from "lucide-react";
import { motion, useMotionValueEvent, useScroll } from "motion/react";
import { useTheme } from "next-themes";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";
import { Kbd } from "@/components/ui/kbd";
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { cn } from "@/lib/utils";

const SPRING = { type: "spring" as const, stiffness: 360, damping: 32, mass: 0.85 };
const SCROLL_THRESHOLD = 32;
const DMG_URL = "/downloads/NepaliCalendar.dmg";

/**
 * Sticky header that shrinks into a floating pill when scrolled.
 * Mirrors the portfolio's nav rhythm:
 *   - At top: full-width 50rem strip, transparent
 *   - Scrolled: ~290px pill, glass background, soft shadow
 *
 * Left:  app icon + "calendar." wordmark
 * Right: Download icon, theme toggle — each tooltip + Kbd badge
 */
export function SiteHeader() {
  const { setTheme, resolvedTheme } = useTheme();
  const { scrollY } = useScroll();
  const [isScrolled, setIsScrolled] = useState(false);
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  useMotionValueEvent(scrollY, "change", (latest) => {
    setIsScrolled(latest > SCROLL_THRESHOLD);
  });

  return (
    <header
      className={cn(
        "sticky top-0 z-50 flex justify-center transition-colors duration-200",
        isScrolled ? "bg-transparent" : "bg-background/85 backdrop-blur-md"
      )}
    >
      <motion.div
        layout
        transition={SPRING}
        animate={{ borderRadius: isScrolled ? 999 : 0 }}
        className={cn(
          "flex items-center transition-[background-color,border-color,box-shadow,height] duration-200",
          isScrolled
            ? "mt-3 h-11 w-72 justify-between gap-2.5 border bg-background/85 px-3 shadow-lg shadow-black/15 backdrop-blur-md"
            : "h-14 w-full max-w-200 justify-between gap-3 border-transparent px-2"
        )}
      >
        <motion.div layout="position" className="shrink-0">
          <Tooltip>
            <TooltipTrigger asChild>
              <Link
                href="/"
                aria-label="Home"
                className="flex items-center gap-2 text-base font-medium tracking-tight outline-none transition-colors hover:text-primary focus-visible:ring-2 focus-visible:ring-ring/40 rounded-sm"
              >
                <Image
                  src="/icon.svg"
                  alt=""
                  width={22}
                  height={22}
                  className="rounded-sm"
                  aria-hidden
                />
                <span>calendar.</span>
              </Link>
            </TooltipTrigger>
            <TooltipContent>Home</TooltipContent>
          </Tooltip>
        </motion.div>

        <motion.nav
          layout="position"
          aria-label="Main navigation"
          className="flex shrink-0 items-center gap-0.5"
        >
          <Tooltip>
            <TooltipTrigger asChild>
              <a
                href={DMG_URL}
                download
                aria-label="Download for macOS"
                className="flex size-8 items-center justify-center rounded-full text-muted-foreground transition-colors hover:text-primary"
              >
                <Download className="size-4" strokeWidth={1.6} />
              </a>
            </TooltipTrigger>
            <TooltipContent className="flex items-center gap-2">
              Download
              <Kbd>D</Kbd>
            </TooltipContent>
          </Tooltip>

          <Tooltip>
            <TooltipTrigger asChild>
              <button
                type="button"
                onClick={() =>
                  setTheme(resolvedTheme === "light" ? "dark" : "light")
                }
                aria-label="Toggle theme"
                className="flex size-8 items-center justify-center rounded-full text-muted-foreground transition-colors hover:text-primary"
              >
                {mounted && resolvedTheme === "dark" ? (
                  <Moon className="size-4" strokeWidth={1.6} />
                ) : (
                  <Sun className="size-4" strokeWidth={1.6} />
                )}
              </button>
            </TooltipTrigger>
            <TooltipContent className="flex items-center gap-2">
              Toggle theme
              <Kbd>T</Kbd>
            </TooltipContent>
          </Tooltip>
        </motion.nav>
      </motion.div>
    </header>
  );
}
