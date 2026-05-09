import { AppPreview } from "@/components/AppPreview";

const REPO_URL = "https://github.com/nabinkhair42/nepali-calendar";
const BREW_TAP = "brew install --cask nabinkhair42/tap/nepali-calendar";

export default function Home() {
  return (
    <main className="relative isolate flex-1 overflow-hidden">
      <BackgroundDecor />
      <Nav />
      <Hero />
      <Features />
      <Install />
      <Footer />
    </main>
  );
}

function BackgroundDecor() {
  return (
    <>
      <div
        aria-hidden
        className="glass-bg absolute inset-0 -z-10 opacity-90 pointer-events-none"
      />
      <div
        aria-hidden
        className="absolute inset-x-0 top-0 -z-10 h-[60vh] bg-gradient-to-b from-transparent to-(--background) pointer-events-none"
      />
    </>
  );
}

function Nav() {
  return (
    <header className="mx-auto max-w-6xl px-6 lg:px-8 pt-6 flex items-center">
      <a href="#" className="flex items-center gap-2 font-semibold tracking-tight">
        <span className="inline-flex items-center justify-center w-7 h-7 rounded-lg bg-(--accent) text-white text-[13px] font-semibold shadow-[0_4px_14px_-2px_rgba(210,53,72,0.45)]">
          ने
        </span>
        <span>Nepali Calendar</span>
      </a>
      <div className="ml-auto flex items-center gap-2 text-sm">
        <a
          href={REPO_URL}
          className="px-3 py-1.5 rounded-md hover:bg-black/5 dark:hover:bg-white/6 text-(--muted) hover:text-(--foreground) transition"
        >
          GitHub
        </a>
        <a
          href="#install"
          className="px-3 py-1.5 rounded-md bg-(--foreground) text-(--background) hover:opacity-90 transition"
        >
          Download
        </a>
      </div>
    </header>
  );
}

function Hero() {
  return (
    <section className="mx-auto max-w-6xl px-6 lg:px-8 pt-20 lg:pt-28 pb-20 grid lg:grid-cols-2 gap-16 items-center">
      <div>
        <div className="inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs glass-card mb-6">
          <span className="inline-block w-1.5 h-1.5 rounded-full bg-(--accent)" />
          <span className="text-(--muted)">macOS 14 + · 376 KB · open source</span>
        </div>
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
        <div className="mt-9 flex flex-wrap gap-3">
          <a
            href="#install"
            className="inline-flex items-center gap-2 px-5 py-3 rounded-xl bg-(--foreground) text-(--background) font-medium hover:opacity-90 transition"
          >
            Download for macOS
            <span className="opacity-60 text-sm">·</span>
            <span className="text-sm opacity-70">.dmg · free</span>
          </a>
          <a
            href={REPO_URL}
            className="inline-flex items-center gap-2 px-5 py-3 rounded-xl glass-card font-medium hover:opacity-90 transition"
          >
            <GitHubIcon />
            <span>Star on GitHub</span>
          </a>
        </div>
        <p className="mt-6 text-xs text-(--muted)">
          BS dates 1975 – 2099 · Devanagari + English · No tracking · MIT
        </p>
      </div>

      <div className="relative">
        <div className="absolute -inset-12 -z-10 rounded-[64px] bg-gradient-to-br from-(--accent-soft) to-transparent blur-2xl opacity-80" />
        <AppPreview />
      </div>
    </section>
  );
}

function Features() {
  const items = [
    {
      title: "Always at a glance",
      body: "Today's BS date sits quietly in your menu bar — no animations, no badges, no nag.",
      glyph: "👁",
    },
    {
      title: "Full month, one click",
      body: "A clean Liquid Glass popover with the full Bikram Sambat month and matching AD dates.",
      glyph: "🗓",
    },
    {
      title: "Devanagari or English",
      body: "Toggle the script with one tap. Numerals, weekdays, and month names all switch in step.",
      glyph: "अ",
    },
    {
      title: "Tiny and native",
      body: "376 KB. Pure SwiftUI. Uses Apple's MenuBarExtra and SMAppService — no Electron, no extras.",
      glyph: "⌘",
    },
  ];
  return (
    <section className="mx-auto max-w-6xl px-6 lg:px-8 py-20 border-t border-(--border)">
      <h2 className="text-3xl font-semibold tracking-tight">
        Quietly useful, every day.
      </h2>
      <p className="mt-3 text-(--muted) max-w-xl">
        v1 is intentionally minimal. The point is to know what date it is in the
        Nepali calendar without breaking your flow.
      </p>
      <div className="mt-12 grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {items.map((it) => (
          <div
            key={it.title}
            className="glass-card rounded-2xl p-6 hover:translate-y-[-2px] transition"
          >
            <div className="text-2xl">{it.glyph}</div>
            <div className="mt-4 font-semibold tracking-tight">{it.title}</div>
            <p className="mt-2 text-sm text-(--muted) leading-relaxed">{it.body}</p>
          </div>
        ))}
      </div>
    </section>
  );
}

function Install() {
  return (
    <section
      id="install"
      className="mx-auto max-w-6xl px-6 lg:px-8 py-20 border-t border-(--border)"
    >
      <h2 className="text-3xl font-semibold tracking-tight">Install in 30 seconds.</h2>
      <p className="mt-3 text-(--muted) max-w-xl">
        macOS 14 (Sonoma) or newer. Apple Silicon and Intel both supported.
      </p>
      <div className="mt-10 grid lg:grid-cols-2 gap-4">
        <div className="glass-card rounded-2xl p-7">
          <div className="text-xs uppercase tracking-wider text-(--muted)">
            Recommended
          </div>
          <div className="mt-2 font-semibold text-lg tracking-tight">Homebrew</div>
          <p className="mt-2 text-sm text-(--muted)">
            Auto-updates with the rest of your stack.
          </p>
          <pre className="mt-5 rounded-xl bg-black text-white text-[13px] font-mono p-4 overflow-x-auto">
            <code>{BREW_TAP}</code>
          </pre>
        </div>
        <div className="glass-card rounded-2xl p-7">
          <div className="text-xs uppercase tracking-wider text-(--muted)">
            Direct
          </div>
          <div className="mt-2 font-semibold text-lg tracking-tight">.dmg download</div>
          <p className="mt-2 text-sm text-(--muted)">
            Drag NepaliCalendar.app into your Applications folder.
          </p>
          <a
            href={`${REPO_URL}/releases/latest`}
            className="mt-5 inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-(--foreground) text-(--background) font-medium hover:opacity-90 transition text-sm"
          >
            Download .dmg
          </a>
        </div>
      </div>
      <div className="mt-10 glass-card rounded-2xl p-7">
        <div className="font-semibold tracking-tight">Or build it yourself</div>
        <p className="mt-2 text-sm text-(--muted)">
          The whole app is &lt; 500 lines of Swift. Clone and run.
        </p>
        <pre className="mt-4 rounded-xl bg-black text-white text-[13px] font-mono p-4 overflow-x-auto">
          <code>{`git clone ${REPO_URL}
cd nepali-calendar/app
./build.sh
open build/NepaliCalendar.app`}</code>
        </pre>
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer className="border-t border-(--border) mt-10">
      <div className="mx-auto max-w-6xl px-6 lg:px-8 py-10 flex flex-col sm:flex-row items-start sm:items-center gap-4 text-sm text-(--muted)">
        <div>
          Built by{" "}
          <a
            href="https://github.com/nabinkhair42"
            className="underline underline-offset-4 decoration-(--border) hover:decoration-(--accent)"
          >
            Nabin Khair
          </a>
          . MIT-licensed.
        </div>
        <div className="sm:ml-auto flex items-center gap-5">
          <a href={REPO_URL} className="hover:text-(--foreground) transition">
            GitHub
          </a>
          <a
            href={`${REPO_URL}/issues`}
            className="hover:text-(--foreground) transition"
          >
            Report an issue
          </a>
        </div>
      </div>
    </footer>
  );
}

function GitHubIcon() {
  return (
    <svg
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="currentColor"
      aria-hidden
    >
      <path d="M12 .5C5.6.5.5 5.6.5 12c0 5.1 3.3 9.4 7.9 10.9.6.1.8-.2.8-.6v-2.2c-3.2.7-3.9-1.4-3.9-1.4-.5-1.4-1.3-1.7-1.3-1.7-1.1-.7.1-.7.1-.7 1.2.1 1.8 1.2 1.8 1.2 1.1 1.8 2.8 1.3 3.4 1 .1-.8.4-1.3.8-1.6-2.6-.3-5.3-1.3-5.3-5.7 0-1.3.5-2.3 1.2-3.1-.1-.3-.5-1.5.1-3.1 0 0 1-.3 3.3 1.2 1-.3 2-.4 3-.4s2 .1 3 .4c2.3-1.5 3.3-1.2 3.3-1.2.6 1.6.2 2.8.1 3.1.8.8 1.2 1.9 1.2 3.1 0 4.4-2.7 5.4-5.3 5.7.4.3.8 1 .8 2v3c0 .3.2.7.8.6 4.6-1.5 7.9-5.8 7.9-10.9C23.5 5.6 18.4.5 12 .5z" />
    </svg>
  );
}
