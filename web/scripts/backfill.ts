#!/usr/bin/env tsx
// One-shot backfill: scrape every BS year we can get from Ashesh and push
// it into Cloudflare KV. Idempotent — re-running only writes years whose
// hash actually changed.
//
// Usage:
//   pnpm backfill                          # 2073 .. (current+1)
//   pnpm backfill -- --from 2080 --to 2085 # explicit range
//   pnpm backfill -- --year 2083           # single year (may repeat)
//
// Requires CF_ACCOUNT_ID, CF_KV_NAMESPACE_ID, CF_API_TOKEN in environment.

import "./_env";
import { scrapeYear } from "../src/lib/scraper/ashesh";
import type { YearFile } from "../src/lib/scraper/types";
import {
  kvPutIfChanged,
  kvPut,
  isConfigured,
  KV_KEYS,
  type FestivalsMeta,
} from "../src/lib/kv";

const SCRAPER_VERSION = "1";
const SOURCE = "ashesh.com.np";
const DEFAULT_FROM = 2073;

interface Args {
  from: number;
  to: number;
  years: number[]; // overrides from/to when present
}

function currentBSYear(): number {
  const today = new Date();
  const Y = today.getUTCFullYear();
  const apr14 = Date.UTC(Y, 3, 14);
  return today.getTime() >= apr14 ? Y - 2026 + 2083 : Y - 2026 + 2082;
}

function parseArgs(argv: string[]): Args {
  let from = DEFAULT_FROM;
  let to = currentBSYear() + 1;
  const years: number[] = [];
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--from" && argv[i + 1]) from = parseInt(argv[++i], 10);
    else if (argv[i] === "--to" && argv[i + 1]) to = parseInt(argv[++i], 10);
    else if (argv[i] === "--year" && argv[i + 1]) years.push(parseInt(argv[++i], 10));
  }
  return { from, to, years };
}

function buildFile(year: number, festivals: YearFile["festivals"]): YearFile {
  festivals.sort((a, b) => {
    if (a.month !== b.month) return a.month - b.month;
    if (a.day !== b.day) return a.day - b.day;
    return a.nameNE.localeCompare(b.nameNE);
  });
  return {
    year,
    festivals,
    _meta: {
      generatedAt: new Date().toISOString(),
      source: SOURCE,
      scraperVersion: SCRAPER_VERSION,
    },
  };
}

async function backfillYear(year: number): Promise<"written" | "unchanged" | "skipped" | "error"> {
  process.stdout.write(`→ ${year} `);
  let festivals: YearFile["festivals"];
  try {
    festivals = await scrapeYear(year);
  } catch (err) {
    console.log(`✗ scrape failed (${err instanceof Error ? err.message : String(err)})`);
    return "skipped";
  }
  if (festivals.length === 0) {
    console.log("✗ empty (Ashesh likely hasn't published this year)");
    return "skipped";
  }
  const file = buildFile(year, festivals);
  // Hash on festivals only — _meta has a timestamp that would always differ.
  const result = await kvPutIfChanged(KV_KEYS.festivalsYear(year), file, {
    year: file.year,
    festivals: file.festivals,
  });
  console.log(`${result.status} (${festivals.length} entries)`);
  return result.status;
}

async function main() {
  if (!isConfigured()) {
    console.error("✗ KV not configured. Set CF_ACCOUNT_ID, CF_KV_NAMESPACE_ID, CF_API_TOKEN.");
    process.exit(1);
  }

  const args = parseArgs(process.argv.slice(2));
  const range: number[] =
    args.years.length > 0
      ? args.years
      : Array.from({ length: args.to - args.from + 1 }, (_, i) => args.from + i);

  console.log(`Backfilling years ${range[0]}..${range[range.length - 1]} → KV`);
  console.log("");

  const written: number[] = [];
  const unchanged: number[] = [];
  const skipped: number[] = [];

  for (const year of range) {
    const result = await backfillYear(year);
    if (result === "written") written.push(year);
    else if (result === "unchanged") unchanged.push(year);
    else skipped.push(year);
    // Polite pause so we don't hammer Ashesh during the long backfill.
    await new Promise((r) => setTimeout(r, 1000));
  }

  // Update meta key with current state of the world.
  const meta: FestivalsMeta = {
    lastSyncAt: Date.now(),
    liveWindow: [currentBSYear() - 1, currentBSYear(), currentBSYear() + 1],
    changedYears: written,
    scraperVersion: SCRAPER_VERSION,
  };
  await kvPut(KV_KEYS.festivalsMeta, meta);

  console.log("");
  console.log(`Done. written=${written.length} unchanged=${unchanged.length} skipped=${skipped.length}`);
  if (written.length) console.log(`  written: ${written.join(", ")}`);
  if (skipped.length) console.log(`  skipped: ${skipped.join(", ")}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
