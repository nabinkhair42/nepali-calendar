// Scrapes ashesh.com.np per BS month and returns one row per festival.
// Source HTML uses inline color #FF4D00 to mark public-holiday cells, and
// cells contain up to three event slots (event_one, rotate_left, rotate_right).

import * as cheerio from "cheerio";
import { KNOWN_NAMES } from "./known-names";
import { ASHESH_BS_MONTHS, type Category, type FestivalEntry } from "./types";

const BASE = "https://www.ashesh.com.np/nepali-calendar/";
const HOLIDAY_COLOR = "#FF4D00"; // Ashesh's red for public holidays
const OBSERVANCE_COLOR = "#89BB0E"; // green for awareness/international days

const UA = "NepaliCalendarBot/1.0 (+https://calendar.nabinkhair.com.np; once-daily)";

interface RawEvent {
  name: string;
  isHoliday: boolean;
  isObservance: boolean;
}

function fetchHTML(url: string): Promise<string> {
  return fetch(url, {
    headers: { "User-Agent": UA },
    signal: AbortSignal.timeout(15_000),
  }).then((r) => {
    if (!r.ok) throw new Error(`Ashesh ${url} → HTTP ${r.status}`);
    return r.text();
  });
}

/** Parse a single BS month page; return one FestivalEntry per event found. */
async function scrapeMonth(year: number, monthIndex0: number): Promise<FestivalEntry[]> {
  const monthName = ASHESH_BS_MONTHS[monthIndex0];
  const url = `${BASE}?year=${year}&month=${monthName}`;
  const html = await fetchHTML(url);
  const $ = cheerio.load(html);

  const entries: FestivalEntry[] = [];
  $("#calendartable td").each((_, td) => {
    const $td = $(td);
    // Skip header row + weekday row + empty leading cells
    if ($td.attr("colspan")) return;
    if ($td.find(".day_np").length) return;
    const dayStr = $td.find(".date_np").first().text().trim();
    if (!dayStr) return;
    const day = parseInt(dayStr, 10);
    if (Number.isNaN(day) || day < 1 || day > 32) return;

    const tdHoliday = ($td.attr("style") ?? "").toLowerCase().includes("color:#ff4d00");

    const rawEvents: RawEvent[] = [];
    for (const sel of [".event_one", ".rotate_left", ".rotate_right"]) {
      const $slot = $td.find(sel).first();
      const name = $slot.text().trim();
      if (!name) continue;
      const style = ($slot.attr("style") ?? "").toLowerCase();
      const isHoliday = tdHoliday || style.includes(HOLIDAY_COLOR.toLowerCase());
      const isObservance = style.includes(OBSERVANCE_COLOR.toLowerCase());
      rawEvents.push({ name, isHoliday, isObservance });
    }

    // Dedupe within a single day (Ashesh occasionally repeats names across slots)
    const seen = new Set<string>();
    for (const ev of rawEvents) {
      if (seen.has(ev.name)) continue;
      seen.add(ev.name);
      entries.push(toFestivalEntry(monthIndex0 + 1, day, ev));
    }
  });
  return entries;
}

function toFestivalEntry(month: number, day: number, ev: RawEvent): FestivalEntry {
  const known = KNOWN_NAMES[ev.name];
  const nameNE = ev.name;
  const nameEN = known?.nameEN ?? ev.name;
  const category: Category =
    known?.category ??
    (ev.isObservance ? "international" : ev.isHoliday ? "religious" : "regional");
  const isHoliday = known?.isHoliday ?? (ev.isHoliday && !ev.isObservance);

  return { month, day, nameEN, nameNE, category, isHoliday };
}

/** Scrape all 12 BS months. Sequential so we're polite to the source. */
export async function scrapeYear(year: number): Promise<FestivalEntry[]> {
  const all: FestivalEntry[] = [];
  for (let i = 0; i < 12; i++) {
    process.stdout.write(`  ${ASHESH_BS_MONTHS[i]} `);
    try {
      const month = await scrapeMonth(year, i);
      all.push(...month);
      console.log(`✓ (${month.length})`);
    } catch (err) {
      console.error(`✗ ${err instanceof Error ? err.message : err}`);
      throw err;
    }
    await new Promise((r) => setTimeout(r, 500)); // 0.5s breather between requests
  }
  return all;
}
