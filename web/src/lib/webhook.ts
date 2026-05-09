// Optional change-notification webhook. POSTs a JSON payload to
// CHANGE_WEBHOOK_URL whenever the daily sync detects a non-empty diff for
// a year in the live window.
//
// The payload is generic enough to plug into Discord, Slack, or any
// catch-all endpoint (Zapier, IFTTT) without provider-specific shaping.
// If you need Discord-flavored markdown, point CHANGE_WEBHOOK_URL at a
// Cloudflare Worker / Vercel Function that re-shapes from this neutral
// schema — keeps the core logic provider-agnostic.

import type { FestivalDiff } from "./scraper/diff";
import { summarize } from "./scraper/diff";

interface ChangePayload {
  year: number;
  summary: string;
  added: { month: number; day: number; nameNE: string; nameEN: string }[];
  removed: { month: number; day: number; nameNE: string; nameEN: string }[];
  modified: { month: number; day: number; nameNE: string }[];
  source: "ashesh.com.np";
  detectedAt: string;
}

/**
 * Best-effort POST. Never throws, never blocks the caller longer than the
 * 5-second timeout. Returns true on a 2xx response, false otherwise.
 */
export async function notifyChange(year: number, diff: FestivalDiff): Promise<boolean> {
  const url = process.env.CHANGE_WEBHOOK_URL;
  if (!url) return false;
  if (diff.added.length === 0 && diff.removed.length === 0 && diff.modified.length === 0) {
    return false;
  }

  const payload: ChangePayload = {
    year,
    summary: summarize(year, diff),
    added: diff.added.map((e) => ({ month: e.month, day: e.day, nameNE: e.nameNE, nameEN: e.nameEN })),
    removed: diff.removed.map((e) => ({ month: e.month, day: e.day, nameNE: e.nameNE, nameEN: e.nameEN })),
    modified: diff.modified.map((m) => ({ month: m.after.month, day: m.after.day, nameNE: m.after.nameNE })),
    source: "ashesh.com.np",
    detectedAt: new Date().toISOString(),
  };

  try {
    const r = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
      signal: AbortSignal.timeout(5_000),
    });
    return r.ok;
  } catch {
    return false;
  }
}
