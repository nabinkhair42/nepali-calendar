import type { Metadata } from "next";
import { ShellWrapper } from "@/components/layouts/shell-wrapper";

export const metadata: Metadata = {
  title: "Privacy — Nepali Calendar",
  description:
    "What Nepali Calendar collects, what it doesn't, and how it handles the data it touches.",
};

const LAST_UPDATED = "May 10, 2026";

export default function PrivacyPage() {
  return (
    <div className="py-8">
      <ShellWrapper>
        <article className="space-y-3 p-2">
          <header className="space-y-2">
            <p className="text-sm text-muted-foreground">Privacy</p>
            <h1 className="text-3xl font-medium tracking-tight md:text-4xl">
              What we keep, what we don&rsquo;t
            </h1>
            <p className="text-base leading-relaxed text-muted-foreground">
              Last updated {LAST_UPDATED}.
            </p>
          </header>

          <div className="space-y-8 pt-4">
            <Section title="The short version">
              <p>
                Nepali Calendar is a single-purpose macOS menu bar app. It has
                no accounts, no analytics SDKs, no third-party trackers. We
                don&rsquo;t know which day you opened it, and we don&rsquo;t
                want to.
              </p>
            </Section>

            <Section title="What the app does locally">
              <p>
                The app stores its festival cache on your Mac at{" "}
                <code className="rounded bg-muted px-1.5 py-0.5 font-mono text-[12.5px]">
                  ~/Library/Application Support/NepaliCalendar/cache/
                </code>
                . It also reads and writes a single key in macOS{" "}
                <code className="rounded bg-muted px-1.5 py-0.5 font-mono text-[12.5px]">
                  UserDefaults
                </code>{" "}
                to remember your language preference (Nepali / English).
                Nothing else is written to disk.
              </p>
            </Section>

            <Section title="What the app fetches">
              <p>
                Festival data comes from{" "}
                <code className="rounded bg-muted px-1.5 py-0.5 font-mono text-[12.5px]">
                  https://calendar.nabinkhair.com.np/api/festivals/&lt;year&gt;
                </code>
                . Each request includes only the BS year you&rsquo;re viewing
                and a generic User-Agent. No cookies, no client identifiers,
                no fingerprinting.
              </p>
              <p>
                The API server (hosted on Vercel) caches data in Cloudflare
                KV. Vercel writes standard HTTP access logs for operational
                reasons (debugging outages, blocking abuse). Those logs
                contain the request path and IP address, are retained for a
                short window, and are never aggregated, exported, or used for
                analytics.
              </p>
            </Section>

            <Section title="What we never collect">
              <ul className="list-disc space-y-1.5 pl-5">
                <li>Your name, email, or any account identifier</li>
                <li>Crash reports, telemetry, or usage events</li>
                <li>Cookies — the marketing site sets none</li>
                <li>Third-party tracking scripts</li>
              </ul>
            </Section>

            <Section title="Updates">
              <p>
                The app does not auto-update itself. New versions ship as a
                fresh download. When the script-based installer is rerun, it
                replaces the existing app binary.
              </p>
            </Section>

            <Section title="Contact">
              <p>
                Questions, requests, or concerns:{" "}
                <a
                  href="mailto:social@mersel.ai"
                  className="font-medium text-foreground underline underline-offset-2 transition-colors hover:text-primary"
                >
                  social@mersel.ai
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
  children: React.ReactNode;
}) {
  return (
    <section className="space-y-2">
      <h2 className="text-lg font-medium tracking-tight md:text-xl">{title}</h2>
      <div className="space-y-3 text-base leading-relaxed text-muted-foreground">
        {children}
      </div>
    </section>
  );
}
