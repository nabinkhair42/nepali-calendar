import Link from "next/link";
import { HugeiconsIcon } from "@hugeicons/react";
import {
  Calendar03Icon,
  CommandIcon,
  EyeIcon,
  GithubIcon,
  ShieldKeyIcon,
} from "@hugeicons/core-free-icons";
import { Apple } from "@/components/apple-icons";

export default function Page() {
  return (
    <main className="min-h-screen flex flex-col">
      <Nav />
      <Hero />
      <Features />
      <Install />
      <Footer />
    </main>
  );
}

/* -------------------------------------------------------------------------- */
/*  Nav                                                                       */
/* -------------------------------------------------------------------------- */

function Nav() {
  return (
    <header className="sticky top-0 z-30 px-6 py-4 backdrop-blur-md bg-[color-mix(in_srgb,var(--background)_72%,transparent)] border-b border-[var(--border)]">
      <div className="mx-auto max-w-6xl flex items-center justify-between">
        <Link href="/" className="flex items-center gap-2 focus-ring">
          <span className="inline-flex items-center justify-center w-7 h-7 rounded-lg bg-[color-mix(in_srgb,var(--accent)_14%,transparent)] text-[var(--accent)]">
            <HugeiconsIcon icon={Calendar03Icon} size={16} strokeWidth={1.75} />
          </span>
          <span className="text-sm font-semibold tracking-tight">
            Nepali Calendar
          </span>
        </Link>
        <nav className="flex items-center gap-3 text-sm">
          <a
            href="https://github.com/nabinkhair12/nepali-calendar"
            className="text-[var(--muted)] hover:text-[var(--foreground)] transition-colors focus-ring inline-flex items-center gap-1.5"
            aria-label="GitHub repository"
          >
            <HugeiconsIcon icon={GithubIcon} size={16} />
            <span className="hidden sm:inline">GitHub</span>
          </a>
          <a
            href="#install"
            className="inline-flex items-center gap-2 rounded-full px-3.5 py-1.5 bg-[var(--foreground)] text-[var(--background)] font-medium hover:opacity-90 transition-opacity focus-ring"
          >
            <Apple className="w-3.5 h-3.5" />
            Download
          </a>
        </nav>
      </div>
    </header>
  );
}

/* -------------------------------------------------------------------------- */
/*  Hero                                                                      */
/* -------------------------------------------------------------------------- */

function Hero() {
  return (
    <section className="px-6 pt-16 pb-24 sm:pt-24 sm:pb-32 relative overflow-hidden">
      {/* Soft accent halo behind hero */}
      <div
        className="pointer-events-none absolute inset-x-0 -top-32 h-[420px] opacity-60 blur-3xl"
        style={{
          background:
            "radial-gradient(50% 60% at 50% 40%, color-mix(in srgb, var(--accent) 22%, transparent), transparent 70%)",
        }}
      />
      <div className="relative mx-auto max-w-6xl grid lg:grid-cols-2 gap-16 lg:gap-12 items-center">
        <div>
          <span className="eyebrow">For macOS · Free forever</span>
          <h1 className="mt-5 text-5xl sm:text-6xl font-semibold tracking-tight leading-[1.05]">
            Bikram Sambat,
            <br />
            in your menu bar.
          </h1>
          <p className="mt-6 text-lg text-[var(--muted)] max-w-md leading-relaxed">
            A native macOS calendar that lives one click away. Festivals,
            public holidays, and the dates the way you actually read them.
          </p>
          <div className="mt-8 flex flex-wrap items-center gap-3">
            <a
              href="#install"
              className="inline-flex items-center gap-2 rounded-full px-5 py-3 bg-[var(--foreground)] text-[var(--background)] font-medium hover:opacity-90 transition-opacity focus-ring"
            >
              <Apple className="w-4 h-4" />
              Download for macOS
            </a>
            <a
              href="https://github.com/nabinkhair12/nepali-calendar"
              className="inline-flex items-center gap-2 rounded-full px-5 py-3 border border-[var(--border)] hover:bg-[color-mix(in_srgb,var(--foreground)_4%,transparent)] transition-colors focus-ring text-sm"
            >
              <HugeiconsIcon icon={GithubIcon} size={16} />
              View source
            </a>
          </div>
          <p className="mt-5 text-xs text-[var(--muted)]">
            macOS 14 Sonoma or later · Apple silicon &amp; Intel · 6 MB
          </p>
        </div>
        <MenuBarMock />
      </div>
    </section>
  );
}

/* -------------------------------------------------------------------------- */
/*  Menu-bar mock — the hero visual                                           */
/* -------------------------------------------------------------------------- */

function MenuBarMock() {
  return (
    <div className="relative">
      {/* Faux desktop wallpaper square */}
      <div
        className="rounded-3xl overflow-hidden border border-[var(--border)] aspect-[5/4]"
        style={{
          background:
            "linear-gradient(140deg, #FFB199 0%, #FF6E5C 35%, #B947FF 75%, #5e3eff 100%)",
        }}
      >
        {/* Faux menu bar */}
        <div className="px-3 py-2 bg-black/35 backdrop-blur-md flex items-center gap-3 text-[11px] text-white/90 font-medium">
          <Apple className="w-3 h-3 fill-white" />
          <span className="opacity-80">Finder</span>
          <span className="opacity-60">File</span>
          <span className="opacity-60">Edit</span>
          <span className="opacity-60">View</span>
          <span className="ml-auto inline-flex items-center gap-2">
            <span className="font-semibold">२८ बैशाख</span>
            <span className="opacity-60">Tue 6 May</span>
          </span>
        </div>

        {/* Popover, anchored to the date in menu bar */}
        <div className="px-6 pt-5">
          <div className="ml-auto w-[300px] rounded-2xl glass-strong shadow-2xl shadow-black/30 p-4">
            {/* Header */}
            <div className="flex items-baseline justify-between">
              <div>
                <div className="text-[26px] font-semibold tracking-tight leading-none">
                  बैशाख
                </div>
                <div className="text-[11px] text-[var(--muted)] mt-1">
                  May 2026 · 2083 BS
                </div>
              </div>
              <div className="flex items-center gap-1 text-[var(--muted)]">
                <button className="w-7 h-7 rounded-md hover:bg-black/5">‹</button>
                <button className="text-[11px] px-2 py-1 rounded-md hover:bg-black/5">Today</button>
                <button className="w-7 h-7 rounded-md hover:bg-black/5">›</button>
              </div>
            </div>

            {/* Weekday header */}
            <div className="mt-4 grid grid-cols-7 text-center text-[10px] font-medium text-[var(--muted)]">
              {["आ", "सो", "मं", "बु", "बि", "शु", "श"].map((d, i) => (
                <span
                  key={i}
                  className={i === 0 || i === 6 ? "text-[var(--accent)]" : ""}
                >
                  {d}
                </span>
              ))}
            </div>

            {/* Day grid */}
            <div className="mt-1 grid grid-cols-7 gap-y-0.5 text-[12px]">
              {buildMockDays().map((d, i) => (
                <DayCell key={i} {...d} />
              ))}
            </div>

            {/* Selected day panel */}
            <div className="mt-3 pt-3 border-t border-[var(--border)]">
              <div className="flex items-baseline justify-between">
                <div className="text-sm font-semibold">मंगलबार</div>
                <div className="text-[10px] text-[var(--muted)]">May 6, 2026</div>
              </div>
              <div className="text-[11px] text-[var(--muted)] mt-0.5">
                २८ बैशाख २०८३
              </div>
              <div className="mt-2 flex items-center gap-2 text-[11px]">
                <span className="w-1.5 h-1.5 rounded-full bg-[var(--accent)]" />
                <span className="font-medium">माता तीर्थ औंसी</span>
                <span className="ml-auto text-[10px] text-[var(--muted)]">Holiday</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

interface DayProps {
  n: string;
  weekend?: boolean;
  today?: boolean;
  selected?: boolean;
  holiday?: boolean;
  blank?: boolean;
}

function DayCell({ n, weekend, today, selected, holiday, blank }: DayProps) {
  if (blank) return <span className="aspect-square" />;
  return (
    <span
      className="relative aspect-square flex items-center justify-center"
    >
      <span
        className={[
          "absolute inset-0.5 rounded-md flex items-center justify-center font-medium",
          selected
            ? "bg-[var(--accent)] text-white"
            : today
              ? "ring-1 ring-[var(--accent)] text-[var(--accent)]"
              : weekend || holiday
                ? "text-[var(--accent)]"
                : "",
        ].join(" ")}
      >
        {n}
      </span>
    </span>
  );
}

function buildMockDays(): DayProps[] {
  // Three blank cells (offset for weekday alignment), then 1..31 with
  // markers for weekends, today (28), selected (28), and holidays.
  const ne = ["१","२","३","४","५","६","७","८","९","१०","११","१२","१३","१४","१५","१६","१७","१८","१९","२०","२१","२२","२३","२४","२५","२६","२७","२८","२९","३०","३१"];
  const days: DayProps[] = [
    { n: "", blank: true },
    { n: "", blank: true },
    { n: "", blank: true },
  ];
  ne.forEach((n, idx) => {
    const dayNum = idx + 1;
    const col = (idx + 3) % 7;
    days.push({
      n,
      weekend: col === 0 || col === 6,
      today: dayNum === 28,
      selected: dayNum === 28,
      holiday: [1, 6, 14, 28].includes(dayNum),
    });
  });
  return days;
}

/* -------------------------------------------------------------------------- */
/*  Features                                                                  */
/* -------------------------------------------------------------------------- */

function Features() {
  return (
    <section className="px-6 py-24 sm:py-32 border-t border-[var(--border)]">
      <div className="mx-auto max-w-6xl">
        <div className="max-w-2xl">
          <span className="eyebrow">What you get</span>
          <h2 className="mt-4 text-3xl sm:text-4xl font-semibold tracking-tight leading-tight">
            Built for daily glances,
            <br />
            not weekend planning.
          </h2>
        </div>
        <div className="mt-14 grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
          <FeatureCard
            icon={EyeIcon}
            title="One click away"
            body="Lives in your menu bar. Click to open. Click anywhere else to dismiss. No window to manage, no dock space taken."
          />
          <FeatureCard
            icon={Calendar03Icon}
            title="Festivals you celebrate"
            body="Every public holiday, religious festival, and cultural observance. Color-coded so a month tells its story at a glance."
          />
          <FeatureCard
            icon={ShieldKeyIcon}
            title="Native, private, free"
            body="Built in Swift for Apple silicon and Intel. No accounts. No telemetry. No server knows which day you opened it."
          />
        </div>
      </div>
    </section>
  );
}

function FeatureCard({
  icon,
  title,
  body,
}: {
  icon: typeof EyeIcon;
  title: string;
  body: string;
}) {
  return (
    <div className="glass-card rounded-2xl p-6 hover:border-[color-mix(in_srgb,var(--accent)_30%,var(--border))] transition-colors">
      <div className="icon-tile">
        <HugeiconsIcon icon={icon} size={20} strokeWidth={1.75} />
      </div>
      <h3 className="mt-5 text-lg font-semibold tracking-tight">{title}</h3>
      <p className="mt-2 text-sm text-[var(--muted)] leading-relaxed">{body}</p>
    </div>
  );
}

/* -------------------------------------------------------------------------- */
/*  Install                                                                   */
/* -------------------------------------------------------------------------- */

function Install() {
  return (
    <section
      id="install"
      className="px-6 py-24 sm:py-32 border-t border-[var(--border)]"
    >
      <div className="mx-auto max-w-3xl text-center">
        <span className="eyebrow">Install</span>
        <h2 className="mt-4 text-3xl sm:text-4xl font-semibold tracking-tight">
          One command. Or one click.
        </h2>
        <p className="mt-4 text-[var(--muted)] max-w-xl mx-auto">
          Install via Homebrew Cask or download the signed disk image
          directly. The app auto-updates festival data daily; nothing else
          phones home.
        </p>

        <div className="mt-10 glass-card rounded-2xl p-5 text-left">
          <div className="flex items-center gap-2 text-[10px] uppercase tracking-widest text-[var(--muted)]">
            <HugeiconsIcon icon={CommandIcon} size={12} />
            <span>Terminal</span>
          </div>
          <pre className="mt-3 font-mono text-[13px] leading-6 overflow-x-auto">
            <span className="text-[var(--muted)]">$ </span>
            brew install --cask nepali-calendar
          </pre>
        </div>

        <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
          <a
            href="https://github.com/nabinkhair12/nepali-calendar/releases/latest"
            className="inline-flex items-center gap-2 rounded-full px-5 py-3 bg-[var(--foreground)] text-[var(--background)] font-medium hover:opacity-90 transition-opacity focus-ring"
          >
            <Apple className="w-4 h-4" />
            Download .dmg
          </a>
          <a
            href="https://github.com/nabinkhair12/nepali-calendar"
            className="inline-flex items-center gap-2 rounded-full px-5 py-3 border border-[var(--border)] hover:bg-[color-mix(in_srgb,var(--foreground)_4%,transparent)] transition-colors text-sm focus-ring"
          >
            <HugeiconsIcon icon={GithubIcon} size={16} />
            Read the source
          </a>
        </div>
      </div>
    </section>
  );
}

/* -------------------------------------------------------------------------- */
/*  Footer                                                                    */
/* -------------------------------------------------------------------------- */

function Footer() {
  return (
    <footer className="px-6 py-10 border-t border-[var(--border)] text-xs text-[var(--muted)]">
      <div className="mx-auto max-w-6xl flex flex-wrap items-center justify-between gap-3">
        <span>
          Made by{" "}
          <a
            href="https://github.com/nabinkhair12"
            className="hover:text-[var(--foreground)] transition-colors"
          >
            Nabin Khair
          </a>
          . MIT licensed.
        </span>
        <span>© {new Date().getFullYear()}</span>
      </div>
    </footer>
  );
}
