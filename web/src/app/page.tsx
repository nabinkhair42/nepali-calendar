import Image from "next/image";
import Link from "next/link";
import type { ReactNode } from "react";
import {
  CheckCircle2,
  Download,
  ExternalLink,
  RefreshCcw,
  ShieldCheck,
  Sparkles,
  Terminal,
} from "lucide-react";
import { Apple } from "@/components/apple-icons";
import { CopyCommand } from "@/components/copy-command";
import { ShellWrapper } from "@/components/layouts/shell-wrapper";
import { Swift } from "@/components/swift-icon";
import { Button } from "@/components/ui/button";
import { Kbd } from "@/components/ui/kbd";
import latestBuild from "../../public/downloads/latest.json";

const APP_VERSION = latestBuild.version;
const APP_BUILD = latestBuild.build;
const DMG_SHA256 = latestBuild.sha256;
const DOWNLOAD_URL = "/downloads/NepaliCalendar.dmg";
const MANIFEST_URL = "/downloads/latest.json";
const GITHUB_RELEASE_URL =
  "https://github.com/nabinkhair42/nepali-calendar/releases";
const INSTALL_COMMAND =
  "curl -fsSL https://calendar.nabinkhair.com.np/install.sh | bash";

export default function Page() {
  return (
    <div className="flex flex-col gap-10 py-8">
      <Hero />
      <ReleaseNotes />
      <Previews />
      <Install />
      <Trust />
    </div>
  );
}

function Hero() {
  return (
    <ShellWrapper>
      <section className="grid gap-6 p-2 md:grid-cols-[8rem_1fr] md:items-start">
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
            <p className="inline-flex items-center gap-2 rounded-md border px-2 py-1 text-xs font-medium text-muted-foreground">
              <CheckCircle2 className="size-3.5 text-primary" />
              v{APP_VERSION} build {APP_BUILD}
            </p>
            <h1 className="text-4xl font-medium tracking-tight md:text-5xl">
              Nepali Calendar
            </h1>
            <p className="max-w-2xl text-base leading-relaxed text-muted-foreground md:text-lg">
              Bikram Sambat in your macOS menu bar, with festivals, public
              holidays, Nepali/English labels, and a popover that stays useful
              after midnight and system sleep.
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-2">
            <Button asChild>
              <a href={DOWNLOAD_URL} download>
                <Apple className="size-4" />
                Download for macOS
                <Kbd>D</Kbd>
              </a>
            </Button>
            <Button asChild size="sm" variant="outline">
              <a href="#install">
                <Terminal className="size-4" />
                Terminal install
                <Kbd>I</Kbd>
              </a>
            </Button>
          </div>

          <dl className="grid gap-3 border-t pt-4 text-sm sm:grid-cols-3">
            <Stat label="Platform" value="macOS 14+" />
            <Stat label="Privacy" value="No accounts or telemetry" />
            <Stat label="Distribution" value="Website + GitHub" />
          </dl>
        </div>
      </section>
    </ShellWrapper>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="space-y-0.5">
      <dt className="text-xs text-muted-foreground">{label}</dt>
      <dd className="font-medium">{value}</dd>
    </div>
  );
}

function ReleaseNotes() {
  const items: Array<{
    icon: ReactNode;
    title: string;
    copy: string;
  }> = [
    {
      icon: <RefreshCcw className="size-4" />,
      title: "Self-healing date state",
      copy:
        "When the BS day changes, the menu label, selected day, and visible month now move together.",
    },
    {
      icon: <Sparkles className="size-4" />,
      title: "Sleep and wake recovery",
      copy:
        "The app refreshes after wake, on popover open, and through a lightweight heartbeat.",
    },
    {
      icon: <Swift className="size-5" />,
      title: "Native and quiet",
      copy:
        "Built in Swift for the menu bar, with local preferences and a small festival cache.",
    },
  ];

  return (
    <ShellWrapper>
      <section className="space-y-5 p-2">
        <header className="space-y-2">
          <p className="text-sm text-muted-foreground">Current release</p>
          <h2 className="text-3xl font-medium tracking-tight md:text-4xl">
            Ready for everyday menu bar use
          </h2>
          <p className="max-w-2xl text-base leading-relaxed text-muted-foreground">
            v{APP_VERSION} focuses on the thing a calendar cannot get wrong:
            today should still be today after midnight, sleep, wake, and a long
            running session.
          </p>
        </header>

        <div className="grid gap-3 md:grid-cols-3">
          {items.map((item) => (
            <article key={item.title} className="space-y-3 rounded-lg border p-4">
              <div className="flex size-9 items-center justify-center rounded-md bg-primary/10 text-primary">
                {item.icon}
              </div>
              <div className="space-y-1">
                <h3 className="font-medium">{item.title}</h3>
                <p className="text-sm leading-relaxed text-muted-foreground">
                  {item.copy}
                </p>
              </div>
            </article>
          ))}
        </div>
      </section>
    </ShellWrapper>
  );
}

function Previews() {
  return (
    <ShellWrapper>
      <section className="space-y-5 p-2">
        <header className="space-y-2">
          <p className="text-sm text-muted-foreground">Preview</p>
          <h2 className="text-3xl font-medium tracking-tight md:text-4xl">
            A compact calendar that follows your Mac
          </h2>
          <p className="max-w-2xl text-base leading-relaxed text-muted-foreground">
            The popover keeps the calendar, selected day details, and festival
            markers close without taking over the screen.
          </p>
        </header>

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
          className="object-cover"
        />
      </div>
      <figcaption className="px-1 text-xs text-muted-foreground">
        {label}
      </figcaption>
    </figure>
  );
}

function Install() {
  return (
    <ShellWrapper>
      <section id="install" className="space-y-5 p-2 scroll-mt-20">
        <header className="space-y-2">
          <p className="text-sm text-muted-foreground">Install</p>
          <h2 className="text-3xl font-medium tracking-tight md:text-4xl">
            Website first, GitHub too
          </h2>
          <p className="max-w-2xl text-base leading-relaxed text-muted-foreground">
            The website serves the same disk image used for GitHub releases.
            The installer verifies the v{APP_VERSION} download before replacing
            the app in Applications.
          </p>
        </header>

        <CopyCommand command={INSTALL_COMMAND} shortcut="I" />

        <div className="flex flex-wrap items-center gap-2">
          <Button asChild size="sm" variant="outline">
            <a href={DOWNLOAD_URL} download>
              <Download className="size-4" />
              Download DMG
            </a>
          </Button>
          <Button asChild size="sm" variant="outline">
            <a href={GITHUB_RELEASE_URL} target="_blank" rel="noreferrer">
              <ExternalLink className="size-4" />
              GitHub releases
            </a>
          </Button>
          <Button asChild size="sm" variant="ghost">
            <Link href={MANIFEST_URL}>Build manifest</Link>
          </Button>
        </div>
      </section>
    </ShellWrapper>
  );
}

function Trust() {
  return (
    <ShellWrapper>
      <section className="grid gap-5 p-2 md:grid-cols-[1fr_1fr]">
        <div className="space-y-3">
          <div className="flex size-9 items-center justify-center rounded-md bg-primary/10 text-primary">
            <ShieldCheck className="size-4" />
          </div>
          <div className="space-y-2">
            <h2 className="text-2xl font-medium tracking-tight">
              Private by default
            </h2>
            <p className="text-base leading-relaxed text-muted-foreground">
              Nepali Calendar has no account system, no analytics SDK, and no
              telemetry. It stores only a festival cache and your language
              preference on your Mac.
            </p>
            <Link
              href="/privacy"
              className="inline-flex items-center gap-1 text-sm font-medium text-primary underline-offset-4 hover:underline"
            >
              Read privacy details
              <ExternalLink className="size-3.5" />
            </Link>
          </div>
        </div>

        <div className="space-y-2 rounded-lg border bg-card p-4">
          <p className="text-sm font-medium">Build verification</p>
          <dl className="space-y-2 text-sm text-muted-foreground">
            <div className="flex items-center justify-between gap-3">
              <dt>Version</dt>
              <dd className="font-mono text-foreground">
                {APP_VERSION} ({APP_BUILD})
              </dd>
            </div>
            <div className="space-y-1">
              <dt>SHA-256</dt>
              <dd className="break-all font-mono text-xs text-foreground">
                {DMG_SHA256}
              </dd>
            </div>
          </dl>
        </div>
      </section>
    </ShellWrapper>
  );
}
