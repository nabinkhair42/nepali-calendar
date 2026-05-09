import Image from "next/image";
import Link from "next/link";
import { HugeiconsIcon } from "@hugeicons/react";
import {
  Calendar03Icon,
  EyeIcon,
  ShieldKeyIcon,
} from "@hugeicons/core-free-icons";
import { Apple } from "@/components/apple-icons";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { CopyCommand } from "@/components/copy-command";

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
          <Image
            src="/icon.svg"
            alt=""
            width={28}
            height={28}
            className="w-7 h-7 rounded-lg"
            aria-hidden
          />
          <span className="text-sm font-semibold tracking-tight">
            Nepali Calendar
          </span>
        </Link>
        <nav className="flex items-center gap-2 text-sm">
          <Button asChild size="sm">
            <a href="/downloads/NepaliCalendar.dmg" download>
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
            Festivals, holidays, weekday names — in Nepali.
          </p>
          <div className="mt-8 flex flex-wrap items-center gap-3">
            <Button asChild size="lg">
              <a href="/downloads/NepaliCalendar.dmg" download>
                <Apple className="w-4 h-4" />
                Download for macOS
              </a>
            </Button>
          </div>
          <p className="mt-5 text-xs text-muted-foreground">
            macOS 14 Sonoma or later · Apple silicon &amp; Intel · ~400 KB
          </p>
        </div>
        <HeroVisual />
      </div>
    </section>
  );
}

/* -------------------------------------------------------------------------- */
/*  Hero visual — app screenshot                                              */
/* -------------------------------------------------------------------------- */

function HeroVisual() {
  return (
    <div className="relative overflow-hidden rounded-lg border border-border ring-2 ring-foreground/5">
      <Image
        src="/demo.png"
        alt="Nepali Calendar running in the macOS menu bar"
        width={3024}
        height={1964}
        priority
        sizes="(min-width: 1024px) 50vw, 100vw"
        className="h-auto w-full"
      />
    </div>
  );
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
            body="Lives in your menu bar. Click anywhere else to dismiss."
          />
          <FeatureCard
            icon={Calendar03Icon}
            title="Festivals you celebrate"
            body="Public holidays and observances, color-coded by category."
          />
          <FeatureCard
            icon={ShieldKeyIcon}
            title="Native, private, free"
            body="Built in Swift. No accounts, no telemetry."
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
      <div className="mx-auto max-w-2xl text-center">
        <Badge variant="outline" className="text-muted-foreground">
          Install
        </Badge>
        <h2 className="mt-4 font-heading text-3xl sm:text-4xl font-semibold tracking-tight">
          One command and you&rsquo;re set.
        </h2>
        <p className="mt-4 text-muted-foreground">
          Paste, run, done.
        </p>

        <div className="mt-8">
          <CopyCommand command="curl -fsSL https://calendar.nabinkhair.com.np/install.sh | bash" />
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
        <span>Made by Nabin Khair.</span>
        <span>© {new Date().getFullYear()} · All rights reserved</span>
      </div>
    </footer>
  );
}
