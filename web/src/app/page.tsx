import Image from "next/image";
import { ShellWrapper } from "@/components/layouts/shell-wrapper";
import { Button } from "@/components/ui/button";
import { Kbd } from "@/components/ui/kbd";
import { CopyCommand } from "@/components/copy-command";
import { Apple } from "@/components/apple-icons";
import { Swift } from "@/components/swift-icon";
import { HugeiconsIcon } from "@hugeicons/react";
import { Calendar03Icon, EyeIcon } from "@hugeicons/core-free-icons";

export default function Page() {
  return (
    <div className="flex flex-col gap-12 py-8">
      <Hero />
      <Features />
      <Install />
    </div>
  );
}

/* -------------------------------------------------------------------------- */
/*  Hero                                                                      */
/* -------------------------------------------------------------------------- */

function Hero() {
  return (
    <ShellWrapper>
      <div className="flex flex-col gap-3 p-2 md:flex-row">
        <div className="relative size-28 shrink-0 self-start md:mt-2.5 md:size-32">
          <Image
            src="/icon.svg"
            alt="Nepali Calendar app icon"
            fill
            sizes="(min-width: 768px) 128px, 112px"
            priority
            className="object-cover"
          />
        </div>

        <div className="space-y-2">
          <div className="space-y-1">
            <h1 className="text-3xl font-medium tracking-tight md:text-4xl">
              Nepali Calendar
            </h1>
            <p className="text-sm tracking-[0.2em] text-muted-foreground">
              MENU&nbsp;BAR&nbsp;APP · MACOS
            </p>
          </div>

          <p className="text-base leading-relaxed text-muted-foreground">
            Bikram Sambat in your menu bar. Festivals, public holidays, and
            observances at a glance — native, fast, and quietly out of the
            way until you need it.
          </p>

          <div className="flex flex-wrap items-center gap-2 pt-2">
            <Button asChild>
              <a href="/downloads/NepaliCalendar.dmg" download>
                <Apple className="size-4" />
                Download
                <Kbd>D</Kbd>
              </a>
            </Button>
            <Button asChild size="sm" variant="outline">
              <a href="#install">
                Install via terminal
                <Kbd>I</Kbd>
              </a>
            </Button>
          </div>
        </div>
      </div>
    </ShellWrapper>
  );
}

/* -------------------------------------------------------------------------- */
/*  Features                                                                  */
/* -------------------------------------------------------------------------- */

function Features() {
  const items: Array<{
    icon: React.ReactNode;
    title: string;
    tagline: string;
  }> = [
    {
      icon: <HugeiconsIcon icon={EyeIcon} size={18} strokeWidth={1.6} />,
      title: "One click away",
      tagline: "Lives in your menu bar. Click anywhere else to dismiss.",
    },
    {
      icon: <HugeiconsIcon icon={Calendar03Icon} size={18} strokeWidth={1.6} />,
      title: "Festivals you celebrate",
      tagline: "Public holidays and observances, color-coded by category.",
    },
    {
      icon: <Swift className="size-5" />,
      title: "Native, private, free",
      tagline: "Built in Swift. No accounts, no telemetry.",
    },
  ];

  return (
    <ShellWrapper>
      <section className="space-y-3 p-2">
        <header className="space-y-2">
          <p className="text-sm tracking-[0.2em] text-muted-foreground">
            WHAT YOU GET
          </p>
          <h2 className="text-3xl font-medium tracking-tight md:text-4xl">
            Built for daily glances
          </h2>
          <p className="text-base leading-relaxed text-muted-foreground">
            Three things, done well.
          </p>
        </header>

        <div className="flex flex-col">
          {items.map((item, idx) => (
            <div
              key={item.title}
              className={
                "flex items-start gap-3 py-4" +
                (idx < items.length - 1 ? " border-b border-border" : "")
              }
            >
              <span className="flex size-10 shrink-0 items-center justify-center rounded-md border bg-card text-foreground">
                {item.icon}
              </span>
              <div className="space-y-0.5 pt-0.5">
                <h3 className="text-lg font-medium md:text-xl">{item.title}</h3>
                <p className="text-sm text-muted-foreground">{item.tagline}</p>
              </div>
            </div>
          ))}
        </div>
      </section>
    </ShellWrapper>
  );
}

/* -------------------------------------------------------------------------- */
/*  Install                                                                   */
/* -------------------------------------------------------------------------- */

function Install() {
  return (
    <ShellWrapper>
      <section id="install" className="space-y-3 p-2 scroll-mt-20">
        <header className="space-y-2">
          <p className="text-sm tracking-[0.2em] text-muted-foreground">
            INSTALL
          </p>
          <h2 className="text-3xl font-medium tracking-tight md:text-4xl">
            One command and you&rsquo;re set
          </h2>
          <p className="text-base leading-relaxed text-muted-foreground">
            Paste, run, done. The script downloads the disk image, copies the
            app into Applications, and tells macOS you trust the source.
          </p>
        </header>

        <CopyCommand
          command="curl -fsSL https://calendar.nabinkhair.com.np/install.sh | bash"
          shortcut="I"
        />
      </section>
    </ShellWrapper>
  );
}
