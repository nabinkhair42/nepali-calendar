// GET /api/cron/refresh
//
// Daily cron entrypoint. Refreshes ONLY the current BS year in KV.
//
// Past and future years are scraped lazily by the read route on first
// request and never re-fetched after that — the data doesn't change.
// The current year is the only one that grows / mutates over time
// (govt holiday additions, Ashesh corrections), so it's the only one
// that benefits from a periodic refresh.
//
// Schedule: 18:15 UTC = 00:00 NPT, configured in vercel.json.
// Auth:     Vercel Cron sends `Authorization: Bearer <CRON_SECRET>`.

import { NextRequest, NextResponse } from "next/server";
import { isConfigured } from "@/lib/kv";
import { scrapeAndPersist, currentBSYear } from "@/lib/festivals";

export const runtime = "nodejs";
export const maxDuration = 60;

function authorized(req: NextRequest): boolean {
  const secret = process.env.CRON_SECRET;
  if (!secret) return false;
  return req.headers.get("authorization") === `Bearer ${secret}`;
}

async function handle(req: NextRequest): Promise<NextResponse> {
  if (!authorized(req)) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  }
  if (!isConfigured()) {
    return NextResponse.json({ error: "KV not configured" }, { status: 503 });
  }

  const year = currentBSYear();
  const outcome = await scrapeAndPersist(year);

  return NextResponse.json({
    ok: outcome.status !== "error",
    year,
    status: outcome.status,
    entries: outcome.entries,
    message: outcome.message,
  });
}

// Vercel Cron uses GET on scheduled paths; POST kept for manual `curl -X POST`.
export const GET = handle;
export const POST = handle;
