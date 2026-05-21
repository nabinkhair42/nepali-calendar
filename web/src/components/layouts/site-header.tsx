"use client";

import { History, Moon, Sun } from "lucide-react";
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


export function SiteHeader() {
  const { setTheme, resolvedTheme } = useTheme();
  const { scrollY } = useScroll();
  const [isScrolled, setIsScrolled] = useState(false);
  const [mounted, setMounted] = useState(false);
  // eslint-disable-next-line react-hooks/set-state-in-effect
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
          "flex items-center transition-[background-color,border-color,height] duration-200",
          isScrolled
            ? "mt-3 h-11 w-72 justify-between gap-2.5 border bg-background/85 px-3 backdrop-blur-md"
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
              <Link
                href="/changelog"
                aria-label="Changelog"
                className="flex size-8 items-center justify-center rounded-full text-muted-foreground transition-colors hover:text-primary"
              >
                <History className="size-4" strokeWidth={1.6} />
              </Link>
            </TooltipTrigger>
            <TooltipContent className="flex items-center gap-2">
              Changelog
              <Kbd>C</Kbd>
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
                {mounted ? (
                  resolvedTheme === "dark" ? (
                    <Moon className="size-4" strokeWidth={1.6} />
                  ) : (
                    <Sun className="size-4" strokeWidth={1.6} />
                  )
                ) : (
                  // Layout-preserving placeholder until next-themes resolves
                  // on the client. Identical box size so the button doesn't
                  // jump after mount.
                  <span className="size-4" aria-hidden />
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
