import Image from "next/image";
import Link from "next/link";
import { ExternalLink } from "lucide-react";
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

const linkClass =
  "underline decoration-from-font underline-offset-4 transition-colors hover:text-foreground";

export default function Page() {
  return (
    <div className="flex flex-col gap-12 py-8 md:gap-16">
      <Hero />
      <Previews />
      <PageFooter />
    </div>
  );
}

function Hero() {
  return (
    <ShellWrapper>
      <section className="px-2 py-10 md:py-14">
        <div className="flex flex-col items-center text-center">
          <div className="relative mb-6 size-24 md:size-28">
            <Image
              src="/icon.svg"
              alt={`${DISPLAY_NAME} app icon`}
              fill
              sizes="(min-width: 768px) 112px, 96px"
              priority
              className="rounded-[22%] object-contain outline outline-1 outline-black/10 dark:outline-white/10"
            />
          </div>

          <h1 className="text-balance text-5xl font-semibold leading-[1.1] tracking-[-0.03em] text-foreground md:text-7xl">
            {DISPLAY_NAME}
          </h1>
          <p className="mt-4 max-w-lg text-pretty text-lg leading-[1.6] text-muted-foreground md:text-xl md:leading-[1.6]">
            Bikram Sambat in your macOS menu bar — festivals, public holidays,
            and a quiet popover that gets out of the way.
          </p>

          <div className="mt-8 w-full max-w-xl">
            <CopyCommand command={INSTALL_COMMAND} shortcut="C" />
          </div>
        </div>
      </section>
    </ShellWrapper>
  );
}

function Previews() {
  return (
    <ShellWrapper>
      <section className="space-y-3 p-2">
        <h2 className="sr-only">App previews</h2>
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2">
          <PreviewCard src="/light.png" label="Light mode" tone="light" />
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
    <figure className="space-y-2.5">
      <div
        className={
          "relative aspect-812/1316 w-full overflow-hidden rounded-2xl p-2 shadow-[0_1px_2px_oklch(0_0_0/0.04),0_8px_24px_oklch(0_0_0/0.06)] " +
          (tone === "dark"
            ? "bg-[oklch(0.16_0.01_23)]"
            : "bg-[oklch(0.97_0.006_23)]")
        }
      >
        <div className="relative h-full w-full overflow-hidden rounded-lg outline outline-1 outline-black/10 dark:outline-white/10">
          <Image
            src={src}
            alt={`${DISPLAY_NAME} in ${label.toLowerCase()}`}
            fill
            sizes="(min-width: 640px) 25rem, 100vw"
            className="object-contain"
          />
        </div>
      </div>
      <figcaption className="px-1 text-sm leading-normal text-muted-foreground">
        {label}
      </figcaption>
    </figure>
  );
}

function PageFooter() {
  return (
    <ShellWrapper>
      <section className="flex flex-wrap items-center justify-between gap-4 p-2 text-base leading-normal text-muted-foreground">
        <p className="text-pretty">
          No accounts, no telemetry.{" "}
          <Link href="/privacy" className={linkClass}>
            Privacy
          </Link>
        </p>

        <div className="flex items-center gap-4">
          <Link href="/changelog" className={linkClass}>
            Changelog
          </Link>
          <a
            href={GITHUB_RELEASES_URL}
            target="_blank"
            rel="noreferrer"
            className={`inline-flex items-center gap-1 ${linkClass}`}
          >
            GitHub
            <ExternalLink className="size-3" />
          </a>
          <span className="text-sm tabular-nums">
            v{APP_VERSION} ({APP_BUILD})
          </span>
        </div>
      </section>
    </ShellWrapper>
  );
}
