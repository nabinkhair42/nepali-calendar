import Image from "next/image";
import Link from "next/link";
import { ExternalLink, ShieldCheck } from "lucide-react";
import { Apple } from "@/components/apple-icons";
import { ShellWrapper } from "@/components/layouts/shell-wrapper";
import { Button } from "@/components/ui/button";
import latestBuild from "../../public/downloads/latest.json";

const APP_VERSION = latestBuild.version;
const APP_BUILD = latestBuild.build;
const DOWNLOAD_URL = "/downloads/NepaliCalendar.dmg";
const GITHUB_RELEASE_URL =
  "https://github.com/nabinkhair42/nepali-calendar/releases";

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
      <section className="grid gap-6 p-2 md:grid-cols-[8rem_1fr] md:items-center">
        <div className="relative size-28 shrink-0 md:size-32">
          <Image
            src="/icon.svg"
            alt="Nepali Calendar app icon"
            fill
            sizes="(min-width: 768px) 128px, 112px"
            priority
            className="object-cover"
          />
        </div>

        <div className="space-y-5">
          <div className="space-y-2">
            <h1 className="text-4xl font-medium tracking-tight md:text-5xl">
              Nepali Calendar
            </h1>
            <p className="max-w-2xl text-base leading-relaxed text-muted-foreground md:text-lg">
              Bikram Sambat in your macOS menu bar — festivals, public
              holidays, and a quiet popover that gets out of the way.
            </p>
          </div>

          <Button asChild>
            <a href={DOWNLOAD_URL} download>
              <Apple className="size-4" />
              Download for macOS
            </a>
          </Button>
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
          alt={`Nepali Calendar in ${label.toLowerCase()}`}
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
            href={GITHUB_RELEASE_URL}
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
