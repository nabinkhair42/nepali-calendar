// GET /api/festivals/<year>
//
// Read-mostly. KV is the source of truth — populated lazily on first
// request and re-scraped daily for the current BS year by the cron.
//
// Cold cache:  scrape Ashesh, write to KV, return.
// Warm cache:  serve from KV (or in-memory bridge during the 60 s after a
//              fresh write, while CF KV's edge cache still holds the prior
//              null).
//
// Cache headers differ by year semantics:
//   - Current year   → short s-maxage + long stale-while-revalidate
//   - Other years    → immutable (scraped once, never re-fetched)

import { NextRequest, NextResponse } from "next/server";
import type { YearFile } from "@/lib/scraper/types";
import { kvGet, isConfigured, KV_KEYS } from "@/lib/kv";
import { scrapeAndPersist, currentBSYear } from "@/lib/festivals";

export const runtime = "nodejs";
export const maxDuration = 60;

const MIN_BS_YEAR = 1975;
const MAX_BS_YEAR = 2099;

// Cloudflare KV's REST API caches GET responses (including 404s) at the
// edge data center for 60 s. After a cold scrape + KV write, the next
// request from the same edge will still see the cached null until the TTL
// expires. In production this is invisible (different users hit different
// edges); in dev it shows up as "scraped twice in a row." This module-level
// map bridges the gap by holding writes in-process for 90 s.
const recentWrites = new Map<string, { value: YearFile; until: number }>();
const BRIDGE_TTL_MS = 90 * 1000;

function bridgeGet(key: string): YearFile | null {
  const entry = recentWrites.get(key);
  if (!entry) return null;
  if (entry.until <= Date.now()) {
    recentWrites.delete(key);
    return null;
  }
  return entry.value;
}

function bridgePut(key: string, value: YearFile): void {
  recentWrites.set(key, { value, until: Date.now() + BRIDGE_TTL_MS });
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

  const isCurrent = year === currentBSYear();
  const key = KV_KEYS.festivalsYear(year);

  // 1a. In-memory bridge — bypasses CF KV's 60 s edge negative-cache.
  const bridged = bridgeGet(key);
  if (bridged) return jsonResponse(bridged, "memory", isCurrent);

  // 1b. KV lookup
  const cached = await kvGet<YearFile>(key);
  if (cached) return jsonResponse(cached.value, "kv", isCurrent);

  // 2. Cold KV — scrape, write back, serve.
  const outcome = await scrapeAndPersist(year);
  if (outcome.status === "error") {
    return NextResponse.json(
      { error: "scrape failed", message: outcome.message },
      { status: 502 },
    );
  }
  if (outcome.status === "skipped" || !outcome.file) {
    return NextResponse.json(
      { error: outcome.message ?? "Ashesh has not published this year yet" },
      { status: 404 },
    );
  }

  if (isConfigured() && (outcome.status === "written" || outcome.status === "unchanged")) {
    bridgePut(key, outcome.file);
  }

  return jsonResponse(outcome.file, "scrape", isCurrent);
}

function jsonResponse(
  body: YearFile,
  source: "kv" | "scrape" | "memory",
  isCurrent: boolean,
): NextResponse {
  const cacheControl = isCurrent
    ? "public, s-maxage=3600, stale-while-revalidate=604800"
    : "public, s-maxage=31536000, immutable";
  return NextResponse.json(body, {
    headers: {
      "Cache-Control": cacheControl,
      "X-Cache-Source": source,
    },
  });
}
