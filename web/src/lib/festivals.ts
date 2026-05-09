// Shared festival pipeline: scrape Ashesh → sort → write to KV (only when
// content actually changed via hash compare). Used by the read route's
// cold-cache fallback and the daily cron.

import { scrapeYear } from "./scraper/ashesh";
import type { YearFile } from "./scraper/types";
import { kvPutIfChanged, KV_KEYS } from "./kv";

export const SCRAPER_VERSION = "1";

export interface YearOutcome {
  year: number;
  status: "written" | "unchanged" | "skipped" | "error";
  entries: number;
  message?: string;
  /** Original scraped+sorted file when the route wants to serve it directly. */
  file?: YearFile;
}

/** Scrape one year, sort, write to KV if hash changed. */
export async function scrapeAndPersist(year: number): Promise<YearOutcome> {
  let festivals: YearFile["festivals"];
  try {
    festivals = await scrapeYear(year);
  } catch (err) {
    return {
      year,
      status: "error",
      entries: 0,
      message: err instanceof Error ? err.message : String(err),
    };
  }
  if (festivals.length === 0) {
    return { year, status: "skipped", entries: 0, message: "Ashesh has no entries for this year" };
  }

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
      scraperVersion: SCRAPER_VERSION,
    },
  };

  // Hash on festivals only — _meta has a timestamp that would always differ.
  const result = await kvPutIfChanged(KV_KEYS.festivalsYear(year), file, {
    year: file.year,
    festivals: file.festivals,
  });

  return {
    year,
    status: result.status === "error" ? "error" : result.status,
    entries: festivals.length,
    file,
  };
}

/** BS year for `now`, computed from the BS↔AD anchor (1 Baisakh 2083 = 14 Apr 2026). */
export function currentBSYear(now: Date = new Date()): number {
  const Y = now.getUTCFullYear();
  const apr14 = Date.UTC(Y, 3, 14);
  return now.getTime() >= apr14 ? Y - 2026 + 2083 : Y - 2026 + 2082;
}
