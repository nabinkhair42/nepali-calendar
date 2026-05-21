import Image from "next/image";
import Link from "next/link";
import { ArrowRight, ExternalLink, ShieldCheck } from "lucide-react";
import { CopyCommand } from "@/components/copy-command";
import { ShellWrapper } from "@/components/layouts/shell-wrapper";
import {
  DISPLAY_NAME,
  GITHUB_RELEASES_URL,
  INSTALL_COMMAND,
} from "@/lib/app-constants";
import latestBuild from "../../public/downloads/latest.json";

const APP_VERSION = latestBuild.version;
const APP_BUILD = latestBuild.build;

export default function Page() {
  return (
    <div className="flex flex-col gap-10 py-8">
      <Hero />
      <Previews />
      <Footer />
    </div>
  );
}

function Hero() {
  return (
    <ShellWrapper>
      <section className="relative overflow-hidden px-2 py-6 md:py-8">
        {/* Brand-tinted radial glow sitting behind the icon. Sized large
            enough to feather to transparent before the section's hairline
            divider so the section still reads as a flat band. */}
        <div
          aria-hidden
          className="pointer-events-none absolute left-1/2 top-0 -z-10 h-72 w-xl -translate-x-1/2 bg-[radial-gradient(closest-side,oklch(0.65_0.21_23/0.22),transparent_72%)] blur-2xl dark:bg-[radial-gradient(closest-side,oklch(0.7_0.21_23/0.28),transparent_72%)]"
        />

        <div className="flex flex-col items-center text-center animate-in fade-in slide-in-from-bottom-2 duration-700 ease-out">
          {/* What's-new pill — a quiet hook into the changelog without
              taking up a full section. */}
          <Link
            href="/changelog"
            className="group mb-8 inline-flex items-center gap-2 rounded-full border bg-card/60 px-3 py-1 text-xs text-muted-foreground shadow-xs backdrop-blur-sm transition-colors hover:border-foreground/20 hover:bg-card hover:text-foreground"
          >
            <span className="relative flex size-1.5">
              <span className="absolute inline-flex size-full animate-ping rounded-full bg-primary opacity-60" />
              <span className="relative inline-flex size-1.5 rounded-full bg-primary" />
            </span>
            <span>New in v{APP_VERSION}</span>
            <span className="text-muted-foreground/40">·</span>
            <span className="inline-flex items-center gap-1 underline-offset-4 group-hover:underline">
              Changelog
              <ArrowRight className="size-3 transition-transform group-hover:translate-x-0.5" />
            </span>
          </Link>

          <div className="relative mb-7 size-32 md:size-36">
            <Image
              src="/icon.svg"
              alt={`${DISPLAY_NAME} app icon`}
              fill
              sizes="(min-width: 768px) 144px, 128px"
              priority
              className="object-contain drop-shadow-[0_12px_28px_oklch(0.61_0.21_23/0.35)]"
            />
          </div>

          <h1 className="bg-linear-to-b from-foreground to-foreground/70 bg-clip-text text-5xl font-medium tracking-tight text-transparent md:text-6xl">
            {DISPLAY_NAME}
          </h1>
          <p className="mt-4 max-w-xl text-balance text-base leading-relaxed text-muted-foreground md:text-lg">
            Bikram Sambat in your macOS menu bar — festivals, public holidays,
            and a quiet popover that gets out of the way.
          </p>

          <div className="mt-8 w-full max-w-xl space-y-3">
            <CopyCommand command={INSTALL_COMMAND} shortcut="D" />
            <div className="flex flex-wrap items-center justify-center gap-x-3 gap-y-1 text-xs text-muted-foreground">
              <span className="inline-flex items-center gap-1.5">
                <ShieldCheck className="size-3.5" />
                SHA-256 verified
              </span>
              <span className="text-muted-foreground/40">·</span>
              <span>No telemetry</span>
              <span className="text-muted-foreground/40">·</span>
              <span>macOS 14 or later</span>
            </div>
          </div>
        </div>
      </section>
    </ShellWrapper>
  );
}

function Previews() {
  return (
    <ShellWrapper>
      <section className="space-y-4 p-2">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <PreviewCard src="/light.png" label="Light mode" />
          <PreviewCard src="/dark.png" label="Dark mode" tone="dark" />
        </div>
      </section>
    </ShellWrapper>
  );
}

function PreviewCard({
  src,
  label,
  tone = "light",
}: {
  src: string;
  label: string;
  tone?: "light" | "dark";
}) {
  return (
    <figure className="space-y-2">
      <div
        className={
          "relative aspect-812/1316 w-full overflow-hidden rounded-lg border " +
          (tone === "dark" ? "bg-[oklch(0.16_0_0)]" : "bg-[oklch(0.97_0_0)]")
        }
      >
        <Image
          src={src}
          alt={`${DISPLAY_NAME} in ${label.toLowerCase()}`}
          fill
          sizes="(min-width: 640px) 25rem, 100vw"
          className="object-contain"
        />
      </div>
      <figcaption className="px-1 text-xs text-muted-foreground">
        {label}
      </figcaption>
    </figure>
  );
}

function Footer() {
  return (
    <ShellWrapper>
      <section className="flex flex-wrap items-center justify-between gap-4 p-2 text-sm text-muted-foreground">
        <div className="flex items-center gap-2">
          <ShieldCheck className="size-3.5" />
          <span>
            No accounts, no telemetry.{" "}
            <Link
              href="/privacy"
              className="underline-offset-4 hover:text-foreground hover:underline"
            >
              Privacy
            </Link>
          </span>
        </div>

        <div className="flex items-center gap-4">
          <Link
            href="/changelog"
            className="underline-offset-4 hover:text-foreground hover:underline"
          >
            Changelog
          </Link>
          <a
            href={GITHUB_RELEASES_URL}
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center gap-1 underline-offset-4 hover:text-foreground hover:underline"
          >
            GitHub releases
            <ExternalLink className="size-3" />
          </a>
          <span className="font-mono text-xs">
            v{APP_VERSION} ({APP_BUILD})
          </span>
        </div>
      </section>
    </ShellWrapper>
  );
}
