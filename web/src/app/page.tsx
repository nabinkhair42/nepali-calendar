import { HugeiconsIcon } from "@hugeicons/react";
import {
  StarIcon,
  Tick02Icon,
  EyeIcon,
  Calendar03Icon,
  TranslationIcon,
  CommandIcon,
} from "@hugeicons/core-free-icons";

import { AppPreview } from "@/components/AppPreview";
import { CodeBlock } from "@/components/CodeBlock";
import { Apple } from "@/components/apple-icons";

const BREW_TAP = "brew install --cask nepali-calendar";
const APP_VERSION = "v1.0";

export default function Home() {
  return (
    <main className="relative isolate flex-1">
      <div className="relative min-h-svh flex flex-col">
        <Nav />
        <Hero />
      </div>
      <Features />
      <Install />
    </main>
  );
}

function Nav() {
  return (
    <header className="mx-auto w-full max-w-6xl px-6 lg:px-8 pt-6 flex items-center">
      <a
        href="#"
        className="focus-ring flex items-center gap-2 font-semibold tracking-tight rounded-md"
      >
        <span className="inline-flex items-center justify-center w-7 h-7 rounded-lg bg-(--accent) text-white text-[13px] font-semibold">
          ने
        </span>
        <span>Nepali Calendar</span>
        <span className="hidden sm:inline-flex items-center px-1.5 py-0.5 ml-1 rounded-md text-[10px] font-medium tracking-wider text-(--muted) border border-(--border)">
          {APP_VERSION}
        </span>
      </a>
      <div className="ml-auto flex items-center gap-2 text-sm">
        <a
          href="#install"
          className="focus-ring px-3 py-1.5 rounded-md bg-(--foreground) text-(--background) hover:opacity-90 transition"
        >
          Download
        </a>
      </div>
    </header>
  );
}

function Hero() {
  return (
    <section className="flex-1 flex items-center">
      <div className="w-full mx-auto max-w-6xl px-6 lg:px-8 py-16 grid lg:grid-cols-12 gap-12 lg:gap-16 items-center">
        <div className="lg:col-span-6">
          <h1 className="text-5xl lg:text-6xl font-semibold tracking-tight leading-[1.05]">
            Nepal lives in
            <br />
            your menu bar.
          </h1>
          <p className="mt-6 text-lg text-(--muted) max-w-md leading-relaxed">
            A clean, native macOS app that keeps the Bikram Sambat calendar a
            glance away. Today&apos;s date in the menu bar. The full month, one
            click below.
          </p>
          <div className="mt-9 flex flex-wrap items-center gap-3">
            <a
              href="#install"
              className="focus-ring inline-flex items-center gap-2 px-5 py-3 rounded-xl bg-(--foreground) text-(--background) font-medium hover:opacity-90 transition"
            >
              <Apple className="w-4 h-4" aria-hidden />
              Download for macOS
            </a>
            <span className="text-sm text-(--muted)">.dmg · free</span>
          </div>
          <div className="mt-8 flex flex-col gap-2.5">
            <div className="flex flex-wrap items-center gap-x-4 gap-y-2 text-xs text-(--muted)">
              <Trust>No telemetry</Trust>
              <Trust>Signed &amp; notarized</Trust>
              <Trust>Free forever</Trust>
            </div>
            <div className="text-[11px] text-(--muted)/70 tracking-wide">
              Devanagari + English · Sun &amp; Sat weekend
            </div>
          </div>
        </div>

        <div className="lg:col-span-6 flex items-center justify-center">
          <AppPreview />
        </div>
      </div>
    </section>
  );
}

function Features() {
  const items = [
    {
      title: "Always at a glance",
      body: "Today's BS date sits quietly in your menu bar. No animations, no badges, no nag.",
      icon: EyeIcon,
    },
    {
      title: "Full month, one click",
      body: "A clean popover with the full Bikram Sambat month and matching AD dates, weekend tinted.",
      icon: Calendar03Icon,
    },
    {
      title: "Devanagari or English",
      body: "Toggle the script with one tap. Numerals, weekdays, and month names all switch in step.",
      icon: TranslationIcon,
    },
    {
      title: "Tiny and native",
      body: "376 KB. Pure SwiftUI. Uses Apple's MenuBarExtra and SMAppService. No Electron, no extras.",
      icon: CommandIcon,
    },
  ];
  return (
    <section className="mx-auto max-w-6xl px-6 lg:px-8 pt-32 pb-24">
      <div className="max-w-2xl">
        <span className="eyebrow">What it does</span>
        <h2 className="mt-4 text-3xl sm:text-4xl font-semibold tracking-tight">
          Quietly useful, every day.
        </h2>
        <p className="mt-4 text-(--muted) leading-relaxed">
          v1 is intentionally minimal. The point is to know what date it is in
          the Nepali calendar without breaking your flow.
        </p>
      </div>
      <div className="mt-14 grid sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {items.map(({ title, body, icon }, i) => (
          <article
            key={title}
            className="group glass-card rounded-2xl p-7 min-h-[15rem] flex flex-col transition-all duration-300 hover:-translate-y-0.5 hover:border-(--accent)/30"
          >

            <div className="flex items-start justify-between">
              <span className="icon-tile">
                <HugeiconsIcon icon={icon} size={24} strokeWidth={1.6} />
              </span>
              <span className="text-[10px] font-mono tracking-[0.2em] text-(--muted)/50 group-hover:text-(--accent) transition-colors">
                {String(i + 1).padStart(2, "0")}
              </span>
            </div>
            <h3 className="mt-6 font-semibold tracking-tight text-[15px]">
              {title}
            </h3>
            <p className="mt-2 text-sm text-(--muted) leading-relaxed">{body}</p>
          </article>
        ))}
      </div>
    </section>
  );
}

function Install() {
  return (
    <section
      id="install"
      className="mx-auto max-w-6xl px-6 lg:px-8 pt-32 pb-32 scroll-mt-20"
    >
      <div className="text-center max-w-2xl mx-auto">
        <span className="eyebrow justify-center">Get it</span>
        <h2 className="mt-4 text-3xl sm:text-4xl font-semibold tracking-tight">
          Install in 30 seconds.
        </h2>
        <p className="mt-4 text-(--muted) leading-relaxed">
          macOS 14 (Sonoma) or newer. Apple Silicon and Intel both supported.
        </p>
        <div className="mt-5 inline-flex items-center gap-2 text-[11px] text-(--muted)">
          <Apple className="w-3 h-3" aria-hidden />
          macOS 14+ · Universal binary
        </div>
      </div>

      <div className="mt-12 max-w-2xl mx-auto">
        <div className="glass-card rounded-2xl p-7 sm:p-8">
          <div className="flex items-center justify-between">
            <span className="inline-flex items-center gap-1.5 text-xs uppercase tracking-wider text-(--accent) font-medium">
              <HugeiconsIcon icon={StarIcon} size={11} />
              Recommended
            </span>
            <span className="text-[10px] font-mono text-(--muted)">~10s</span>
          </div>
          <div className="mt-3 font-semibold text-lg tracking-tight">Homebrew</div>
          <p className="mt-1.5 text-sm text-(--muted)">
            Auto-updates with the rest of your stack.
          </p>
          <div className="mt-5">
            <CodeBlock code={BREW_TAP} label="brew install command" />
          </div>
        </div>
      </div>
    </section>
  );
}

function Trust({ children }: { children: React.ReactNode }) {
  return (
    <span className="inline-flex items-center gap-1.5">
      <HugeiconsIcon
        icon={Tick02Icon}
        size={12}
        className="text-(--accent)"
        strokeWidth={3}
      />
      {children}
    </span>
  );
}
