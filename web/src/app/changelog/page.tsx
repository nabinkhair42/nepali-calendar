import type { Metadata } from "next";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";
import { ShellWrapper } from "@/components/layouts/shell-wrapper";
import { releases, type ChangeKind } from "@/lib/changelog";

export const metadata: Metadata = {
  title: "Changelog — Nepali Calendar",
  description: "Release notes for the Nepali Calendar macOS menu bar app.",
};

const KIND_LABEL: Record<ChangeKind, string> = {
  feat: "New",
  fix: "Fix",
  ui: "UI",
  internal: "Internal",
};

const KIND_CLASSES: Record<ChangeKind, string> = {
  feat: "bg-emerald-500/15 text-emerald-700 dark:bg-emerald-500/18 dark:text-emerald-300",
  fix: "bg-amber-500/15 text-amber-700 dark:bg-amber-500/18 dark:text-amber-300",
  ui: "bg-sky-500/15 text-sky-700 dark:bg-sky-500/18 dark:text-sky-300",
  internal:
    "bg-foreground/8 text-foreground/65 dark:bg-foreground/10 dark:text-foreground/70",
};

export default function ChangelogPage() {
  return (
    <div className="flex flex-col gap-8 py-8">
      <ShellWrapper>
        <header className="space-y-3 p-2">
          <Link
            href="/"
            className="inline-flex items-center gap-1 text-sm text-muted-foreground underline-offset-4 hover:text-foreground hover:underline"
          >
            <ChevronLeft className="size-3.5" />
            Back to home
          </Link>
          <div className="space-y-1">
            <h1 className="text-4xl font-medium tracking-tight md:text-5xl">
              Changelog
            </h1>
            <p className="text-base text-muted-foreground">
              Release notes for the macOS menu bar app.
            </p>
          </div>
        </header>
      </ShellWrapper>

      <ShellWrapper>
        <section className="space-y-8 p-2">
          {releases.map((release) => (
            <article
              key={release.version}
              className="space-y-4 border-b pb-8 last:border-b-0 last:pb-0"
            >
              <header className="space-y-1">
                <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
                  <h2 className="text-2xl font-medium tracking-tight">
                    v{release.version}
                  </h2>
                  <span className="font-mono text-xs text-muted-foreground">
                    build {release.build}
                  </span>
                  <time className="text-sm text-muted-foreground">
                    {formatDate(release.date)}
                  </time>
                </div>
                {release.highlight && (
                  <p className="text-base text-muted-foreground">
                    {release.highlight}
                  </p>
                )}
              </header>

              <ul className="space-y-2.5">
                {release.entries.map((entry, idx) => (
                  <li
                    key={idx}
                    className="grid grid-cols-[4.5rem_1fr] items-baseline gap-3"
                  >
                    <span
                      className={
                        "inline-flex w-fit items-center justify-self-end rounded px-1.5 py-[3px] text-[11px] font-semibold leading-none tracking-wide " +
                        KIND_CLASSES[entry.kind]
                      }
                    >
                      {KIND_LABEL[entry.kind]}
                    </span>
                    <p className="text-sm leading-relaxed text-foreground/90">
                      {entry.text}
                    </p>
                  </li>
                ))}
              </ul>
            </article>
          ))}
        </section>
      </ShellWrapper>
    </div>
  );
}

function formatDate(iso: string): string {
  const d = new Date(iso + "T00:00:00Z");
  return d.toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
    timeZone: "UTC",
  });
}
