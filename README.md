# Nepali Calendar

A clean, native macOS menu bar app that keeps the Bikram Sambat calendar a glance away.

This repo contains:

- **`app/`** — the SwiftUI menu bar app (macOS 14+)
- **`web/`** — the Next.js distribution site

| | |
|---|---|
| **Platform** | macOS 14+ (Sonoma, Sequoia, Tahoe) |
| **Stack** | SwiftUI · `MenuBarExtra` · Liquid Glass materials |
| **Bundle size** | ~376 KB |
| **Date range** | 1975 BS – 2099 BS (1918 AD – 2042 AD) |
| **License** | MIT |

## Features (v1)

- Today's BS date in the menu bar (e.g. `Jes 26` / `जेठ २६`)
- Full-month grid in a `.ultraThinMaterial` popover with today and Saturday highlighted
- AD subtitle for orientation (e.g. `May–Jun 2026`)
- One-click toggle between English and Devanagari script
- Quit + month navigation (prev / today / next)

## Build the app

```bash
cd app
swift build -c release       # compile
./build.sh                   # bundle into NepaliCalendar.app
open build/NepaliCalendar.app
```

Run the verification suite (no Xcode required):

```bash
cd app
swift run NepaliCalendarVerify
```

## Run the landing page

```bash
cd web
pnpm install
pnpm dev
```

## Acknowledgements

The Bikram Sambat month-length lookup table is ported from
[`remotemerge/nepali-date-converter`](https://github.com/remotemerge/nepali-date-converter) (MIT).
