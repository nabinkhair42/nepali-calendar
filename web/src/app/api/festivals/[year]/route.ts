// GET /api/festivals/<year>
//
// Read-mostly. KV is the source of truth — populated lazily on first
// request and proactively kept fresh for the live window by the daily
// `/api/admin/sync` cron.
//
// Cold cache:  scrape Ashesh, write to KV, return.
// Warm cache:  serve from KV.
//
// Cache headers differ by year semantics:
//   - Past years            → immutable (1 year edge cache)
//   - Live window (curr±1)  → short s-maxage + long stale-while-revalidate
//
// `pnpm backfill` is now optional — useful for batch seeding before launch
// or to refresh historical data after a known Ashesh correction, but no
// longer required for correctness.

import { NextRequest, NextResponse } from "next/server";
import { scrapeYear } from "@/lib/scraper/ashesh";
import type { YearFile } from "@/lib/scraper/types";
import { kvGet, kvPutIfChanged, isConfigured, KV_KEYS } from "@/lib/kv";

export const runtime = "nodejs";
export const maxDuration = 60;

const MIN_BS_YEAR = 1975;
const MAX_BS_YEAR = 2099;

function currentBSYear(): number {
  const today = new Date();
  const Y = today.getUTCFullYear();
  const apr14 = Date.UTC(Y, 3, 14);
  return today.getTime() >= apr14 ? Y - 2026 + 2083 : Y - 2026 + 2082;
}

function inLiveWindow(year: number): boolean {
  const c = currentBSYear();
  return year >= c - 1 && year <= c + 1;
}

export async function GET(
  _req: NextRequest,
  ctx: { params: Promise<{ year: string }> },
): Promise<NextResponse> {
  const { year: yearStr } = await ctx.params;
  const year = parseInt(yearStr, 10);

  if (!Number.isFinite(year) || year < MIN_BS_YEAR || year > MAX_BS_YEAR) {
    return NextResponse.json(
      { error: `year out of range; expected ${MIN_BS_YEAR}–${MAX_BS_YEAR}` },
      { status: 400 },
    );
  }

  const live = inLiveWindow(year);
  const key = KV_KEYS.festivalsYear(year);

  // 1. KV lookup
  const cached = await kvGet<YearFile>(key);
  if (cached) {
    return jsonResponse(cached.value, "kv", live);
  }

  // 2. Cold KV — scrape, write back, serve. Same path for past and live;
  //    only the cache header differs.
  let scraped: YearFile;
  try {
    const festivals = await scrapeYear(year);
    if (festivals.length === 0) {
      return NextResponse.json(
        { error: "ashesh has not published this year yet" },
        { status: 404 },
      );
    }
    festivals.sort((a, b) => {
      if (a.month !== b.month) return a.month - b.month;
      if (a.day !== b.day) return a.day - b.day;
      return a.nameNE.localeCompare(b.nameNE);
    });
    scraped = {
      year,
      festivals,
      _meta: {
        generatedAt: new Date().toISOString(),
        source: "ashesh.com.np",
        scraperVersion: "1",
      },
    };
  } catch (err) {
    return NextResponse.json(
      { error: "scrape failed", message: err instanceof Error ? err.message : String(err) },
      { status: 502 },
    );
  }

  // 3. Write back to KV. We await rather than fire-and-forget because
  //    serverless platforms can freeze a function the moment it returns,
  //    losing in-flight requests. The added ~50–200 ms is invisible against
  //    the ~8 s cold scrape we just did, and guarantees the next request
  //    serves from KV.
  if (isConfigured()) {
    await kvPutIfChanged(key, scraped, { year: scraped.year, festivals: scraped.festivals });
  }

  return jsonResponse(scraped, "scrape", live);
}

function jsonResponse(
  body: YearFile,
  source: "kv" | "scrape",
  live: boolean,
): NextResponse {
  const cacheControl = live
    ? // Live window: short edge cache, generous stale-while-revalidate so
      // edge nodes self-heal off the next cron without user-visible latency.
      "public, s-maxage=3600, stale-while-revalidate=604800"
    : // Past years are immutable — let the edge keep them effectively forever.
      "public, s-maxage=31536000, immutable";
  return NextResponse.json(body, {
    headers: {
      "Cache-Control": cacheControl,
      "X-Cache-Source": source,
      "X-Year-Live": live ? "1" : "0",
    },
  });
}
