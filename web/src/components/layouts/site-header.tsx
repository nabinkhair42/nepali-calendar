"use client";

import { Moon, Sun } from "lucide-react";
import { AnimatePresence, motion } from "motion/react";
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
import { DISPLAY_NAME, GITHUB_REPO } from "@/lib/app-constants";

const ICON_SPRING = { type: "spring" as const, duration: 0.3, bounce: 0 };
const GITHUB_URL = `https://github.com/${GITHUB_REPO}`;

export function SiteHeader() {
  const { setTheme, resolvedTheme } = useTheme();
  const [mounted, setMounted] = useState(false);
  // eslint-disable-next-line react-hooks/set-state-in-effect
  useEffect(() => setMounted(true), []);

  const isDark = mounted && resolvedTheme === "dark";

  return (
    <header className="sticky top-0 z-50 bg-background/90 backdrop-blur-md">
      <div className="flex h-14 w-full items-center justify-between gap-3 px-2">
        <Link
          href="/"
          aria-label={DISPLAY_NAME}
          className="flex select-none items-center gap-2 rounded-md text-lg font-semibold tracking-tight text-foreground outline-none transition-colors hover:text-primary focus-visible:ring-2 focus-visible:ring-ring/40"
        >
          <Image
            src="/icon.svg"
            alt=""
            width={22}
            height={22}
            className="rounded-[5px] outline outline-1 outline-black/10 dark:outline-white/10"
            aria-hidden
          />
          <span>calendar.</span>
        </Link>

        <nav aria-label="Main navigation" className="flex items-center gap-0.5">
          <Tooltip>
            <TooltipTrigger asChild>
              <a
                href={GITHUB_URL}
                target="_blank"
                rel="noreferrer"
                aria-label="GitHub"
                className="relative flex size-10 select-none items-center justify-center rounded-md text-muted-foreground transition-[color,transform] duration-150 ease-out hover:text-foreground active:scale-[0.96]"
              >
                <span className="text-sm font-semibold">GH</span>
              </a>
            </TooltipTrigger>
            <TooltipContent>GitHub</TooltipContent>
          </Tooltip>

          <Tooltip>
            <TooltipTrigger asChild>
              <button
                type="button"
                onClick={() =>
                  setTheme(resolvedTheme === "light" ? "dark" : "light")
                }
                aria-label="Toggle theme"
                className="relative flex size-10 select-none items-center justify-center rounded-md text-muted-foreground transition-[color,transform] duration-150 ease-out hover:text-foreground active:scale-[0.96]"
              >
                <span className="relative size-4">
                  {mounted ? (
                    <AnimatePresence initial={false} mode="popLayout">
                      <motion.span
                        key={isDark ? "moon" : "sun"}
                        className="absolute inset-0 flex items-center justify-center"
                        initial={{
                          opacity: 0,
                          scale: 0.25,
                          filter: "blur(4px)",
                        }}
                        animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
                        exit={{ opacity: 0, scale: 0.25, filter: "blur(4px)" }}
                        transition={ICON_SPRING}
                      >
                        {isDark ? (
                          <Moon className="size-4" strokeWidth={1.6} />
                        ) : (
                          <Sun className="size-4" strokeWidth={1.6} />
                        )}
                      </motion.span>
                    </AnimatePresence>
                  ) : (
                    <span className="size-4" aria-hidden />
                  )}
                </span>
              </button>
            </TooltipTrigger>
            <TooltipContent className="flex items-center gap-2">
              Toggle theme
              <Kbd>D</Kbd>
            </TooltipContent>
          </Tooltip>
        </nav>
      </div>
    </header>
  );
}
