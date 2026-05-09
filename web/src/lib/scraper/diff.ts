// Structured diff between two festival lists. Used by sync logging so
// changes show up as readable lines in Vercel logs (not opaque "year 2083
// changed").

import type { FestivalEntry } from "./types";

export interface FestivalDiff {
  added: FestivalEntry[];
  removed: FestivalEntry[];
  modified: { before: FestivalEntry; after: FestivalEntry }[];
}

/** Identity for matching across versions: month+day+nameNE survives most edits. */
function key(e: FestivalEntry): string {
  return `${e.month}-${e.day}-${e.nameNE}`;
}

export function diffFestivals(
  before: FestivalEntry[],
  after: FestivalEntry[],
): FestivalDiff {
  const beforeMap = new Map(before.map((e) => [key(e), e] as const));
  const afterMap = new Map(after.map((e) => [key(e), e] as const));

  const added: FestivalEntry[] = [];
  const removed: FestivalEntry[] = [];
  const modified: { before: FestivalEntry; after: FestivalEntry }[] = [];

  for (const [k, a] of afterMap) {
    const b = beforeMap.get(k);
    if (!b) {
      added.push(a);
    } else if (
      b.nameEN !== a.nameEN ||
      b.category !== a.category ||
      b.isHoliday !== a.isHoliday ||
      b.endMonth !== a.endMonth ||
      b.endDay !== a.endDay
    ) {
      modified.push({ before: b, after: a });
    }
  }
  for (const [k, b] of beforeMap) {
    if (!afterMap.has(k)) removed.push(b);
  }
  return { added, removed, modified };
}

export function isEmpty(d: FestivalDiff): boolean {
  return d.added.length === 0 && d.removed.length === 0 && d.modified.length === 0;
}

export function summarize(year: number, d: FestivalDiff): string {
  return `[year ${year}] +${d.added.length} added, -${d.removed.length} removed, ~${d.modified.length} modified`;
}

export function logDiff(year: number, d: FestivalDiff): void {
  if (isEmpty(d)) {
    console.log(`[year ${year}] unchanged`);
    return;
  }
  console.log(summarize(year, d));
  for (const e of d.added) {
    console.log(`  + ${e.month}/${e.day} ${e.nameNE} (${e.category}${e.isHoliday ? ", holiday" : ""})`);
  }
  for (const e of d.removed) {
    console.log(`  - ${e.month}/${e.day} ${e.nameNE}`);
  }
  for (const { before, after } of d.modified) {
    const fields: string[] = [];
    if (before.nameEN !== after.nameEN) fields.push(`nameEN "${before.nameEN}"→"${after.nameEN}"`);
    if (before.category !== after.category) fields.push(`category ${before.category}→${after.category}`);
    if (before.isHoliday !== after.isHoliday) fields.push(`isHoliday ${before.isHoliday}→${after.isHoliday}`);
    console.log(`  ~ ${after.month}/${after.day} ${after.nameNE} (${fields.join(", ")})`);
  }
}
