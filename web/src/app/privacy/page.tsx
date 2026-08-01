import type { Metadata } from "next";
import Link from "next/link";
import type { ReactNode } from "react";
import { ShellWrapper } from "@/components/layouts/shell-wrapper";

export const metadata: Metadata = {
  title: "Privacy — Nepali Calendar",
  description:
    "How Nepali Calendar handles local preferences, festival data, website downloads, and installer verification.",
};

const LAST_UPDATED = "May 15, 2026";

const linkClass =
  "font-medium text-foreground underline decoration-from-font underline-offset-4 transition-colors hover:text-primary";

export default function PrivacyPage() {
  return (
    <div className="py-8">
      <ShellWrapper>
        <article className="space-y-10 p-2">
          <header className="space-y-2">
            <p className="text-sm font-medium text-muted-foreground">
              Privacy
            </p>
            <h1 className="text-balance text-4xl font-semibold leading-[1.1] tracking-[-0.025em] md:text-5xl">
              Private by default, boring on purpose
            </h1>
            <p className="max-w-2xl text-pretty text-lg leading-[1.6] text-muted-foreground">
              Last updated {LAST_UPDATED}. Nepali Calendar is a local macOS
              menu bar app with no accounts, no analytics SDKs, and no
              third-party tracking scripts.
            </p>
          </header>

          <ul className="max-w-2xl space-y-3 text-base leading-[1.6] text-muted-foreground">
            <li>
              <span className="font-medium text-foreground">No identity.</span>{" "}
              No name, email, account, advertising ID, or device profile is
              collected.
            </li>
            <li>
              <span className="font-medium text-foreground">Local settings.</span>{" "}
              The app keeps only a festival cache and your Nepali/English
              preference on your Mac.
            </li>
            <li>
              <span className="font-medium text-foreground">
                Verified installer.
              </span>{" "}
              The website installer verifies the downloaded disk image before
              copying the app.
            </li>
          </ul>

          <div className="space-y-8">
            <Section title="What stays on your Mac">
              <p>
                Nepali Calendar stores its festival cache at{" "}
                <Code>~/Library/Application Support/NepaliCalendar/cache/</Code>
                . It also stores one language preference in macOS{" "}
                <Code>UserDefaults</Code>. These values are used only to make
                the menu bar app faster and remember your display language.
              </p>
            </Section>

            <Section title="What the app fetches">
              <p>
                The app asks this website for festival data by BS year, using
                paths like{" "}
                <Code>
                  https://calendar.nabinkhair.com.np/api/festivals/&lt;year&gt;
                </Code>
                . Requests do not include cookies, client identifiers, or
                account data.
              </p>
            </Section>

            <Section title="Website and server logs">
              <p>
                The website and API are hosted on Vercel. Vercel may keep
                standard HTTP access logs for operational needs such as abuse
                prevention, debugging outages, and deployment health. Those
                logs are not used for analytics, retargeting, or profiling.
              </p>
            </Section>

            <Section title="Downloads and updates">
              <p>
                The app does not auto-update. New versions are distributed as
                a fresh disk image through the website and GitHub releases. The
                installer downloads{" "}
                <Code>/downloads/NepaliCalendar.dmg</Code>, verifies its
                SHA-256 checksum, copies it to <Code>/Applications</Code>, and
                replaces any older copy.
              </p>
              <p>
                The current public build manifest is available at{" "}
                <Link href="/downloads/latest.json" className={linkClass}>
                  /downloads/latest.json
                </Link>
                .
              </p>
            </Section>

            <Section title="What is never collected">
              <ul className="list-disc space-y-1.5 ps-5">
                <li>Account details, email addresses, or names</li>
                <li>Calendar events from your Mac</li>
                <li>Crash reports, telemetry, or usage events</li>
                <li>Cookies from the marketing website</li>
                <li>Third-party tracking or advertising pixels</li>
              </ul>
            </Section>

            <Section title="Contact">
              <p>
                Questions, requests, or concerns:{" "}
                <a href="mailto:nabinkhair12@gmail.com" className={linkClass}>
                  nabinkhair12@gmail.com
                </a>
                .
              </p>
            </Section>
          </div>
        </article>
      </ShellWrapper>
    </div>
  );
}

function Section({
  title,
  children,
}: {
  title: string;
  children: ReactNode;
}) {
  return (
    <section className="space-y-2">
      <h2 className="text-xl font-semibold leading-[1.2] tracking-[-0.015em] md:text-2xl">
        {title}
      </h2>
      <div className="max-w-2xl space-y-3 text-pretty text-base leading-[1.6] text-muted-foreground">
        {children}
      </div>
    </section>
  );
}

function Code({ children }: { children: ReactNode }) {
  return (
    <code className="break-words rounded bg-muted px-1.5 py-0.5 text-sm text-foreground">
      {children}
    </code>
  );
}
