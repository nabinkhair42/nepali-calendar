// Manually-curated Devanagari → English mapping for well-known festivals.
// Anything not in this map keeps its Devanagari name as both nameNE and nameEN.
// Add entries as new festivals come up in scraper output. Match exact strings
// (after trim) returned by Ashesh.

import type { Category } from "./types";

interface KnownEntry {
  nameEN: string;
  category: Category;
  // Override the holiday flag when Ashesh's color heuristic gets it wrong.
  // Leave undefined to defer to scraper.
  isHoliday?: boolean;
}

export const KNOWN_NAMES: Record<string, KnownEntry> = {
  // National / fixed BS-day (also encoded in BSCore.recurring; keeping here
  // so they classify correctly when scraped)
  "नयाँ वर्ष":             { nameEN: "Nepali New Year",  category: "national",      isHoliday: true },
  "गणतन्त्र दिवस":          { nameEN: "Republic Day",     category: "national",      isHoliday: true },
  "संविधान दिवस":           { nameEN: "Constitution Day", category: "national",      isHoliday: true },
  "माघे संक्रान्ति":         { nameEN: "Maghe Sankranti",  category: "religious",     isHoliday: true },
  "शहीद दिवस":             { nameEN: "Martyrs' Day",     category: "national",      isHoliday: true },
  "प्रजातन्त्र दिवस":        { nameEN: "Democracy Day",    category: "national",      isHoliday: true },

  // Major lunar
  "बुद्ध जयन्ती":           { nameEN: "Buddha Jayanti",       category: "religious", isHoliday: true },
  "जनै पूर्णिमा":           { nameEN: "Janai Purnima",        category: "religious", isHoliday: true },
  "कृष्ण जन्माष्टमी":       { nameEN: "Krishna Janmashtami",  category: "religious", isHoliday: true },
  "गाईजात्रा":             { nameEN: "Gai Jatra",            category: "regional",  isHoliday: false },
  "इन्द्र जात्रा":         { nameEN: "Indra Jatra",          category: "regional",  isHoliday: false },
  "घटस्थापना":             { nameEN: "Ghatasthapana",        category: "religious", isHoliday: false },
  "विजयादशमी":             { nameEN: "Vijaya Dashami",       category: "national",  isHoliday: true },
  "लक्ष्मी पूजा":          { nameEN: "Laxmi Puja",            category: "religious", isHoliday: true },
  "भाइटीका":               { nameEN: "Bhai Tika",            category: "national",  isHoliday: true },
  "छठ पर्व":               { nameEN: "Chhath",               category: "religious", isHoliday: true },
  "महाशिवरात्री":           { nameEN: "Maha Shivaratri",      category: "religious", isHoliday: true },
  "होली":                  { nameEN: "Holi",                 category: "religious", isHoliday: true },
  "फाग पूर्णिमा":           { nameEN: "Holi (Falgun Purnima)", category: "religious", isHoliday: true },
  "घोडे जात्रा":           { nameEN: "Ghode Jatra",          category: "regional",  isHoliday: false },

  // Lhosars
  "तामु लोसार":            { nameEN: "Tamu Lhosar",          category: "religious", isHoliday: true },
  "सोनाम लोसार":           { nameEN: "Sonam Lhosar",         category: "religious", isHoliday: true },
  "ग्यालपो लोसार":          { nameEN: "Gyalpo Lhosar",        category: "religious", isHoliday: true },

  // International / AD-anchored
  "श्रमिक दिवस":           { nameEN: "Labour Day",                   category: "international", isHoliday: true },
  "क्रिसमस":               { nameEN: "Christmas",                    category: "international", isHoliday: true },
  "अन्तर्राष्ट्रिय महिला दिवस": { nameEN: "International Women's Day", category: "international", isHoliday: false },

  // Newar
  "यो मरि पुन्ही":         { nameEN: "Yomari Punhi",         category: "regional",  isHoliday: false },
};
