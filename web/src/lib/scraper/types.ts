// Wire shape of a year's festival JSON. MUST stay in sync with
// app/Sources/BSCore/FestivalDatabase.swift's YearFile decoder.

export type Category =
  | "national"
  | "regional"
  | "religious"
  | "cultural"
  | "international";

export interface FestivalEntry {
  month: number;
  day: number;
  endMonth?: number;
  endDay?: number;
  nameEN: string;
  nameNE: string;
  category: Category;
  isHoliday: boolean;
}

export interface YearFile {
  year: number;
  festivals: FestivalEntry[];
  _meta?: {
    generatedAt: string;
    source: string;
    scraperVersion: string;
  };
}

// Slugs Ashesh actually accepts in `?month=` — verified by probing each
// candidate. `Ashadh` (not `Asar`) is the canonical slug for month 3,
// which silently returns a partial page if the wrong slug is used.
export const ASHESH_BS_MONTHS = [
  "Baishakh",
  "Jestha",
  "Ashadh",
  "Shrawan",
  "Bhadra",
  "Ashwin",
  "Kartik",
  "Mangsir",
  "Poush",
  "Magh",
  "Falgun",
  "Chaitra",
] as const;
