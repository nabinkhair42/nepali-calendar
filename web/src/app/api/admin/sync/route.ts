// POST /api/admin/sync          — refresh live window (current-1, current, current+1)
// POST /api/admin/sync?year=N   — refresh exactly one year
//
// Auth: Authorization: Bearer <CRON_SECRET>. Vercel Cron sets this header
// automatically when the entry is configured in vercel.json. For manual
// runs, send the same header.
//
// Behavior: scrape, hash-diff against KV, write only on change. Past years
// outside the live window are immutable historical record — refuse to touch
// them here (use `pnpm backfill -- --year N` if a deliberate refresh is
// needed). Returns a JSON summary of what changed.

import { NextRequest, NextResponse } from "next/server";
import { scrapeYear } from "@/lib/scraper/ashesh";
import type { YearFile } from "@/lib/scraper/types";
import { diffFestivals, isEmpty, logDiff } from "@/lib/scraper/diff";
import {
  kvGet,
  kvPut,
  kvPutIfChanged,
  isConfigured,
  KV_KEYS,
  type FestivalsMeta,
} from "@/lib/kv";
import { notifyChange } from "@/lib/webhook";

export const runtime = "nodejs";
export const maxDuration = 300; // backfilling 3 years × ~6s each = ~20s, with headroom

const SCRAPER_VERSION = "1";
const SOURCE = "ashesh.com.np";

interface YearResult {
  year: number;
  status: "written" | "unchanged" | "skipped" | "error";
  added?: number;
  removed?: number;
  modified?: number;
  message?: string;
}

function currentBSYear(): number {
  const today = new Date();
  const Y = today.getUTCFullYear();
  const apr14 = Date.UTC(Y, 3, 14);
  return today.getTime() >= apr14 ? Y - 2026 + 2083 : Y - 2026 + 2082;
}

function liveWindow(): number[] {
  const c = currentBSYear();
  return [c - 1, c, c + 1];
}

function authorized(req: NextRequest): boolean {
  const secret = process.env.CRON_SECRET;
  if (!secret) {
    // No secret configured = treat the route as locked. Misconfiguration
    // should fail closed, not open.
    return false;
  }
  const header = req.headers.get("authorization") ?? "";
  return header === `Bearer ${secret}`;
}

async function syncYear(year: number, allowedYears: Set<number>): Promise<YearResult> {
  if (!allowedYears.has(year)) {
    return {
      year,
      status: "skipped",
      message: "outside live window — use `pnpm backfill -- --year N` for historical refresh",
    };
  }
  let festivals: YearFile["festivals"];
  try {
    festivals = await scrapeYear(year);
  } catch (err) {
    return { year, status: "error", message: err instanceof Error ? err.message : String(err) };
  }
  if (festivals.length === 0) {
    return { year, status: "skipped", message: "Ashesh returned no entries" };
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
      source: SOURCE,
      scraperVersion: SCRAPER_VERSION,
    },
  };

  const existing = await kvGet<YearFile>(KV_KEYS.festivalsYear(year));
  const before = existing?.value.festivals ?? [];
  const diff = diffFestivals(before, festivals);

  const result = await kvPutIfChanged(KV_KEYS.festivalsYear(year), file, {
    year: file.year,
    festivals: file.festivals,
  });

  // Always log; structured lines in Vercel logs are the audit trail.
  if (!isEmpty(diff)) logDiff(year, diff);
  else console.log(`[year ${year}] unchanged`);

  // Fire-and-forget webhook on real changes (only if KV write actually
  // succeeded — don't notify on transient errors that we'll retry tomorrow).
  if (result.status === "written" && !isEmpty(diff)) {
    void notifyChange(year, diff);
  }

  return {
    year,
    status: result.status === "error" ? "error" : result.status,
    added: diff.added.length,
    removed: diff.removed.length,
    modified: diff.modified.length,
  };
}

export async function POST(req: NextRequest): Promise<NextResponse> {
  if (!authorized(req)) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  }
  if (!isConfigured()) {
    return NextResponse.json({ error: "KV not configured" }, { status: 503 });
  }

  const url = new URL(req.url);
  const yearParam = url.searchParams.get("year");
  const window = liveWindow();
  const allowed = new Set(window);
  const years = yearParam ? [parseInt(yearParam, 10)] : window;

  const results: YearResult[] = [];
  for (const year of years) {
    if (!Number.isFinite(year)) {
      results.push({ year, status: "error", message: "invalid year" });
      continue;
    }
    results.push(await syncYear(year, allowed));
  }

  const meta: FestivalsMeta = {
    lastSyncAt: Date.now(),
    liveWindow: window,
    changedYears: results.filter((r) => r.status === "written").map((r) => r.year),
    scraperVersion: SCRAPER_VERSION,
  };
  await kvPut(KV_KEYS.festivalsMeta, meta);

  return NextResponse.json({ ok: true, results, meta });
}

// Vercel Cron sends GET to scheduled paths in some configurations; accept it.
export async function GET(req: NextRequest): Promise<NextResponse> {
  return POST(req);
}
