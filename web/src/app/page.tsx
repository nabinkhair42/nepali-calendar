import Image from "next/image";
import Link from "next/link";
import { HugeiconsIcon } from "@hugeicons/react";
import {
  Calendar03Icon,
  CommandIcon,
  EyeIcon,
  ShieldKeyIcon,
} from "@hugeicons/core-free-icons";
import { Apple } from "@/components/apple-icons";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";

export default function Page() {
  return (
    <main className="min-h-screen flex flex-col bg-background text-foreground">
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
    <header className="sticky top-0 z-30 px-6 py-4 backdrop-blur-md bg-background/72 border-b border-border">
      <div className="mx-auto max-w-6xl flex items-center justify-between">
        <Link
          href="/"
          className="flex items-center gap-2 outline-none focus-visible:ring-3 focus-visible:ring-ring/30 rounded-md"
        >
          <span className="inline-flex items-center justify-center w-7 h-7 rounded-lg bg-primary/10 text-primary">
            <HugeiconsIcon icon={Calendar03Icon} size={16} strokeWidth={1.75} />
          </span>
          <span className="text-sm font-semibold tracking-tight">
            Nepali Calendar
          </span>
        </Link>
        <nav className="flex items-center gap-2 text-sm">
          <Button asChild size="sm">
            <a href="#install">
              <Apple className="w-3.5 h-3.5" />
              Download
            </a>
          </Button>
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
    <section className="px-6 pt-16 pb-24 sm:pt-24 sm:pb-32">
      <div className="mx-auto max-w-6xl grid lg:grid-cols-2 gap-16 lg:gap-12 items-center">
        <div>
          <Badge variant="outline" className="text-muted-foreground">
            For macOS · Free forever
          </Badge>
          <h1 className="mt-5 font-heading text-5xl sm:text-6xl font-semibold tracking-tight leading-[1.05]">
            Bikram Sambat,
            <br />
            in your menu bar.
          </h1>
          <p className="mt-6 text-lg text-muted-foreground max-w-md leading-relaxed">
            A native macOS calendar that lives one click away. Festivals,
            public holidays, and the dates the way you actually read them.
          </p>
          <div className="mt-8 flex flex-wrap items-center gap-3">
            <Button asChild size="lg">
              <a href="#install">
                <Apple className="w-4 h-4" />
                Download for macOS
              </a>
            </Button>
          </div>
          <p className="mt-5 text-xs text-muted-foreground">
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
      <div className="rounded-3xl overflow-hidden border border-border aspect-[5/4] shadow-md ring-1 ring-foreground/5 bg-muted">
        <div className="px-3 py-2 bg-foreground/85 backdrop-blur-md flex items-center gap-3 text-[11px] text-background font-medium">
          <Apple className="w-3 h-3 fill-background" />
          <span className="opacity-80">Finder</span>
          <span className="opacity-60">File</span>
          <span className="opacity-60">Edit</span>
          <span className="opacity-60">View</span>
          <span className="ml-auto inline-flex items-center gap-2">
            <span className="font-semibold">२८ बैशाख</span>
            <span className="opacity-60">Tue 6 May</span>
          </span>
        </div>

        <div className="px-6 pt-5">
          <Card
            size="sm"
            className="ml-auto w-[300px] gap-3 rounded-2xl bg-card/95 backdrop-blur-md shadow-none"
          >
            <CardContent className="space-y-3">
              <div className="flex items-baseline justify-between">
                <div>
                  <div className="font-heading text-[26px] font-semibold tracking-tight leading-none">
                    बैशाख
                  </div>
                  <div className="text-[11px] text-muted-foreground mt-1">
                    May 2026 · 2083 BS
                  </div>
                </div>
                <div className="flex items-center gap-1">
                  <Button variant="ghost" size="icon-xs" aria-label="Previous month">
                    ‹
                  </Button>
                  <Button variant="ghost" size="xs">
                    Today
                  </Button>
                  <Button variant="ghost" size="icon-xs" aria-label="Next month">
                    ›
                  </Button>
                </div>
              </div>

              <div className="grid grid-cols-7 text-center text-[10px] font-medium text-muted-foreground">
                {["आ", "सो", "मं", "बु", "बि", "शु", "श"].map((d, i) => (
                  <span
                    key={i}
                    className={i === 0 || i === 6 ? "text-primary" : ""}
                  >
                    {d}
                  </span>
                ))}
              </div>

              <div className="grid grid-cols-7 gap-y-0.5 text-[12px]">
                {buildMockDays().map((d, i) => (
                  <DayCell key={i} {...d} />
                ))}
              </div>

              <div className="pt-3 border-t border-border">
                <div className="flex items-baseline justify-between">
                  <div className="text-sm font-semibold">मंगलबार</div>
                  <div className="text-[10px] text-muted-foreground">May 6, 2026</div>
                </div>
                <div className="text-[11px] text-muted-foreground mt-0.5">
                  २८ बैशाख २०८३
                </div>
                <div className="mt-2 flex items-center gap-2 text-[11px]">
                  <span className="w-1.5 h-1.5 rounded-full bg-primary" />
                  <span className="font-medium">माता तीर्थ औंसी</span>
                  <Badge variant="secondary" className="ml-auto h-4 text-[10px]">
                    Holiday
                  </Badge>
                </div>
              </div>
            </CardContent>
          </Card>
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
    <span className="relative aspect-square flex items-center justify-center">
      <span
        className={[
          "absolute inset-0.5 rounded-md flex items-center justify-center font-medium",
          selected
            ? "bg-primary text-primary-foreground"
            : today
              ? "ring-1 ring-primary text-primary"
              : weekend || holiday
                ? "text-primary"
                : "text-foreground",
        ].join(" ")}
      >
        {n}
      </span>
    </span>
  );
}

function buildMockDays(): DayProps[] {
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
    <section className="px-6 py-24 sm:py-32 border-t border-border">
      <div className="mx-auto max-w-6xl">
        <div className="max-w-2xl">
          <Badge variant="outline" className="text-muted-foreground">
            What you get
          </Badge>
          <h2 className="mt-4 font-heading text-3xl sm:text-4xl font-semibold tracking-tight leading-tight">
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
    <Card className="shadow-none transition-colors hover:ring-primary/30">
      <CardContent>
        <div className="inline-flex items-center justify-center w-10 h-10 rounded-xl bg-primary/10 text-primary">
          <HugeiconsIcon icon={icon} size={20} strokeWidth={1.75} />
        </div>
        <h3 className="mt-5 font-heading text-lg font-semibold tracking-tight text-foreground">
          {title}
        </h3>
        <p className="mt-2 text-sm text-muted-foreground leading-relaxed">
          {body}
        </p>
      </CardContent>
    </Card>
  );
}

/* -------------------------------------------------------------------------- */
/*  Install                                                                   */
/* -------------------------------------------------------------------------- */

function Install() {
  return (
    <section
      id="install"
      className="px-6 py-24 sm:py-32 border-t border-border"
    >
      <div className="mx-auto max-w-3xl text-center">
        <Badge variant="outline" className="text-muted-foreground">
          Install
        </Badge>
        <h2 className="mt-4 font-heading text-3xl sm:text-4xl font-semibold tracking-tight">
          One command. Or one click.
        </h2>
        <p className="mt-4 text-muted-foreground max-w-xl mx-auto">
          Install via Homebrew Cask or download the signed disk image
          directly. The app auto-updates festival data daily; nothing else
          phones home.
        </p>

        <Card className="mt-10 text-left shadow-none">
          <CardContent>
            <div className="flex items-center gap-2 text-[10px] uppercase tracking-widest text-muted-foreground">
              <HugeiconsIcon icon={CommandIcon} size={12} />
              <span>Terminal</span>
            </div>
            <pre className="mt-3 font-mono text-[13px] leading-6 overflow-x-auto text-foreground">
              <span className="text-muted-foreground">$ </span>
              brew install --cask nepali-calendar
            </pre>
          </CardContent>
        </Card>

        <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
          <Button asChild size="lg">
            <a href="#">
              <Apple className="w-4 h-4" />
              Download .dmg
            </a>
          </Button>
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
    <footer className="px-6 py-10 border-t border-border text-xs text-muted-foreground">
      <div className="mx-auto max-w-6xl flex flex-wrap items-center justify-between gap-3">
        <span>Made by Nabin Khair. MIT licensed.</span>
        <span>© {new Date().getFullYear()}</span>
      </div>
    </footer>
  );
}
