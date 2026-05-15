// Release notes data for the /changelog page.
//
// Edit this file when you cut a release — the DMG version is the source
// of truth in `app/Info.plist` / `web/public/downloads/latest.json`; this
// list adds the human-readable narrative around it.
//
// Convention: newest release first. Each entry's `kind` drives a small
// colored tag in the UI so readers can skim for the change type they care
// about.

export type ChangeKind = "feat" | "fix" | "ui" | "internal";

export type ChangelogEntry = {
  kind: ChangeKind;
  text: string;
};

export type Release = {
  version: string;
  build: string;
  /** ISO yyyy-mm-dd in the local Nepal/Asia date the release went out. */
  date: string;
  /** One-line headline shown above the bullet list. Optional. */
  highlight?: string;
  entries: ChangelogEntry[];
};

export const releases: Release[] = [
  {
    version: "0.1.3",
    build: "4",
    date: "2026-05-15",
    highlight: "Auto-update, duplicate cleanup, and a quieter UI",
    entries: [
      {
        kind: "feat",
        text:
          "Auto-update from the web. The app polls /api/app/update on launch and every 6 hours; when a newer version is published the popover shows an Update banner with one-click install — download, SHA-256 verify, swap, relaunch.",
      },
      {
        kind: "feat",
        text:
          "Settings → Installation surfaces duplicate copies of the app on this Mac with a Move to Trash button. The running install is always protected.",
      },
      {
        kind: "feat",
        text:
          "Settings → General has a new Automatically check for updates toggle (default on).",
      },
      {
        kind: "ui",
        text:
          "Today now reads as a red, semibold numeral instead of a red ring around the cell. Quieter and more legible when today is also the selected day.",
      },
      {
        kind: "ui",
        text:
          "Selected day uses a neutral soft pill instead of a saturated blue — selection and category color no longer compete.",
      },
      {
        kind: "ui",
        text:
          "Month nav, Settings, Back, and Quit buttons share one flat toolbar-button idiom: borderless at rest, soft hover, no permanently-pressed look.",
      },
      {
        kind: "ui",
        text:
          "Selected-day panel: solid amber Holiday badge with white text for readable contrast; repeated Observance chips removed in favor of the colored dot.",
      },
      {
        kind: "ui",
        text:
          "Reopening the popover snaps back to today's month — no more landing on a month you scrolled away from earlier.",
      },
      {
        kind: "internal",
        text:
          "Bumped TypeScript to 6, @types/node to 25, Tailwind to 4.3. ESLint stays on 9 until eslint-plugin-react ships ESLint 10 support.",
      },
    ],
  },
  {
    version: "0.1.2",
    build: "3",
    date: "2026-04-23",
    highlight: "Sleep, wake, and midnight reliability",
    entries: [
      {
        kind: "fix",
        text:
          "BS today heals on sleep/wake and on popover open — the highlighted day stays correct even after the Mac was asleep across midnight.",
      },
      {
        kind: "fix",
        text:
          "MenuBarExtra label re-renders on @Published mutations again (worked around a SwiftUI invalidation bug in the label closure).",
      },
      {
        kind: "internal",
        text:
          "Added the NepaliCalendarTests target with AppState tests covering midnight, manual selection, and locale-aware day math.",
      },
    ],
  },
];
