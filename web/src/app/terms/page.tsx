import type { Metadata } from "next";
import { ShellWrapper } from "@/components/layouts/shell-wrapper";

export const metadata: Metadata = {
  title: "Terms — Nepali Calendar",
  description:
    "Plain-language terms for using Nepali Calendar — what's allowed, what isn't, and what's promised.",
};

const LAST_UPDATED = "May 10, 2026";

export default function TermsPage() {
  return (
    <div className="py-8">
      <ShellWrapper>
        <article className="space-y-3 p-2">
          <header className="space-y-2">
            <p className="text-sm text-muted-foreground">Terms</p>
            <h1 className="text-3xl font-medium tracking-tight md:text-4xl">
              Plain-language terms
            </h1>
            <p className="text-base leading-relaxed text-muted-foreground">
              Last updated {LAST_UPDATED}.
            </p>
          </header>

          <div className="space-y-8 pt-4">
            <Section title="License">
              <p>
                Nepali Calendar is closed-source software. By installing and
                using it, you&rsquo;re granted a personal, non-transferable,
                non-exclusive license to run the app on Macs you control. You
                may not redistribute, repackage, decompile, reverse-engineer,
                or sell the binary or any part of it.
              </p>
            </Section>

            <Section title="Cost">
              <p>
                The app is currently free to download and use. A future Mac
                App Store release may carry a price. Existing users with the
                direct-download build retain their right to keep using it on
                the terms in effect when they downloaded.
              </p>
            </Section>

            <Section title="Festival data">
              <p>
                Festival information is best-effort and may differ from
                official government announcements, especially for newly-
                declared holidays. Use the app for at-a-glance reference, not
                for binding commitments. We make no warranty about the
                accuracy or completeness of any specific date or festival.
              </p>
            </Section>

            <Section title="Updates and availability">
              <p>
                We may publish new versions, take versions out of
                distribution, or discontinue the service hosting the
                festival API at any time. Cached data on your Mac will keep
                working offline, but new years won&rsquo;t resolve without
                the API.
              </p>
            </Section>

            <Section title="No warranty">
              <p>
                The software is provided &ldquo;as is&rdquo; without warranty
                of any kind, express or implied — including merchantability,
                fitness for a particular purpose, and non-infringement. To
                the extent permitted by law, the author is not liable for
                any direct or indirect damages arising from the use of the
                app.
              </p>
            </Section>

            <Section title="Termination">
              <p>
                If you breach these terms, the license terminates
                automatically. You can stop using the app at any time by
                deleting it from /Applications and the cache directory at{" "}
                <code className="rounded bg-muted px-1.5 py-0.5 font-mono text-[12.5px]">
                  ~/Library/Application Support/NepaliCalendar/
                </code>
                .
              </p>
            </Section>

            <Section title="Contact">
              <p>
                For licensing, security disclosures, or anything else:{" "}
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
