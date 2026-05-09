#!/usr/bin/env tsx
// Daily festival scraper. Writes web/public/data/festivals-<year>.json.
//
//   pnpm scrape                # current BS year
//   pnpm scrape -- --year 2083 # explicit
//   pnpm scrape -- --year 2083 --year 2084
//
// Run by .github/workflows/scrape-festivals.yml on cron + manual dispatch.

import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { scrapeYear } from "../src/lib/scraper/ashesh";
import type { YearFile } from "../src/lib/scraper/types";

const SCRAPER_VERSION = "1";
const SOURCE = "ashesh.com.np";

function currentBSYear(): number {
  // Lightweight estimate: 1 Baisakh 2083 = 14 Apr 2026. The scraper can run
  // ~year-around so we choose the BS year whose Baisakh-1 has already passed.
  const today = new Date();
  const Y = today.getUTCFullYear();
  const apr14 = Date.UTC(Y, 3, 14);
  const bs = today.getTime() >= apr14 ? Y - 2026 + 2083 : Y - 2026 + 2082;
  return bs;
}

function parseArgs(argv: string[]): { years: number[] } {
  const years: number[] = [];
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--year" && argv[i + 1]) {
      years.push(parseInt(argv[++i], 10));
    }
  }
  if (!years.length) years.push(currentBSYear());
  return { years };
}

async function main() {
  const { years } = parseArgs(process.argv.slice(2));
  const outDir = path.resolve(process.cwd(), "public/data");
  await mkdir(outDir, { recursive: true });

  for (const year of years) {
    console.log(`\n→ Scraping BS ${year} from ${SOURCE} …`);
    const festivals = await scrapeYear(year);

    // Deterministic order: month, day, then name. Helps git diffs stay clean.
    festivals.sort((a, b) => {
      if (a.month !== b.month) return a.month - b.month;
      if (a.day !== b.day) return a.day - b.day;
      return a.nameNE.localeCompare(b.nameNE);
    });

    const file: YearFile = {
      year,
      festivals,
      _meta: {
        generatedAt: new Date().toISOString(),
        source: SOURCE,
        scraperVersion: SCRAPER_VERSION,
      },
    };
    const outPath = path.join(outDir, `festivals-${year}.json`);
    // Stable formatting: 2-space indent, sorted keys not enforced (already sorted above)
    await writeFile(outPath, JSON.stringify(file, null, 2) + "\n", "utf8");
    console.log(`✓ wrote ${festivals.length} entries to ${outPath}`);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
