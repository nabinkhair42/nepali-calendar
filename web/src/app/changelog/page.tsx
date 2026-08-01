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

export default function ChangelogPage() {
  return (
    <div className="flex flex-col gap-10 py-8">
      <ShellWrapper>
        <header className="space-y-3 p-2">
          <Link
            href="/"
            className="inline-flex items-center gap-1 text-base leading-normal text-muted-foreground underline-offset-4 transition-colors hover:text-foreground hover:underline hover:decoration-from-font"
          >
            <ChevronLeft className="size-3.5" />
            Back to home
          </Link>
          <div className="space-y-1.5">
            <h1 className="text-balance text-4xl font-semibold leading-[1.1] tracking-[-0.025em] md:text-6xl">
              Changelog
            </h1>
            <p className="max-w-2xl text-pretty text-lg leading-[1.6] text-muted-foreground">
              Release notes for the macOS menu bar app.
            </p>
          </div>
        </header>
      </ShellWrapper>

      <ShellWrapper>
        <section className="space-y-10 p-2">
          {releases.map((release) => (
            <article key={release.version} className="space-y-4">
              <header className="space-y-1">
                <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
                  <h2 className="text-2xl font-semibold leading-[1.15] tracking-[-0.02em] md:text-3xl">
                    <span className="tabular-nums">v{release.version}</span>
                  </h2>
                  <span className="text-sm tabular-nums text-muted-foreground">
                    build {release.build}
                  </span>
                  <time className="text-base leading-normal text-muted-foreground">
                    {formatDate(release.date)}
                  </time>
                </div>
                {release.highlight && (
                  <p className="max-w-2xl text-pretty text-lg leading-[1.6] text-muted-foreground">
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
                    <span className="justify-self-end text-sm font-medium text-muted-foreground">
                      {KIND_LABEL[entry.kind]}
                    </span>
                    <p className="max-w-2xl text-pretty text-base leading-[1.6] text-foreground/90">
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
