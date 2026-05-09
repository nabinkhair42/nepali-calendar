import Foundation

/// Festival/holiday lookup. Two layers compose at query time:
///
///   1. **Recurring** — fixed BS-day events that repeat every year
///      (Nepali New Year on 1 Baisakh, Constitution Day on 3 Asoj, …).
///      Hard-coded since they are constant.
///   2. **Yearly** — lunar-anchored or AD-anchored events whose BS day
///      shifts each year (Dashain, Tihar, Buddha Jayanti, Holi, …).
///      Loaded from `festivals-<year>.json` in BSCore's resource bundle.
///
/// To add a new BS year of data, drop `festivals-<year>.json` into
/// `Sources/BSCore/Resources/` and add the year to `loadedYears`.
public enum FestivalDatabase {

    // MARK: - Recurring (fixed BS-day) entries

    private static let recurring: [(month: Int, day: Int, festival: Festival)] = [
        (1, 1,
         Festival(nameEN: "Nepali New Year",  nameNE: "नयाँ वर्ष",        category: .national, isHoliday: true)),
        (2, 15,
         Festival(nameEN: "Republic Day",     nameNE: "गणतन्त्र दिवस",     category: .national, isHoliday: true)),
        (6, 3,
         Festival(nameEN: "Constitution Day", nameNE: "संविधान दिवस",       category: .national, isHoliday: true)),
        (10, 1,
         Festival(nameEN: "Maghe Sankranti",  nameNE: "माघे संक्रान्ति",   category: .religious, isHoliday: true)),
        (10, 16,
         Festival(nameEN: "Martyrs' Day",     nameNE: "शहीद दिवस",          category: .national, isHoliday: true)),
        (11, 7,
         Festival(nameEN: "Democracy Day",    nameNE: "प्रजातन्त्र दिवस",  category: .national, isHoliday: true)),
    ]

    // MARK: - Yearly (JSON-backed) entries

    /// Years for which a `festivals-<year>.json` file is shipped.
    private static let loadedYears: [Int] = [2083]

    /// Loaded once on first access. Maps BS year → list of (month, day, festival).
    private static let yearlyTable: [Int: [(month: Int, day: Int, festival: Festival)]] = {
        var result: [Int: [(Int, Int, Festival)]] = [:]
        for year in loadedYears {
            if let list = loadYear(year) {
                result[year] = list
            }
        }
        return result
    }()

    private struct YearFile: Decodable {
        let year: Int
        let festivals: [Entry]

        struct Entry: Decodable {
            let month: Int
            let day: Int
            let endMonth: Int?
            let endDay: Int?
            let nameEN: String
            let nameNE: String
            let category: Festival.Category
            let isHoliday: Bool
        }
    }

    private static func loadYear(_ year: Int) -> [(Int, Int, Festival)]? {
        guard let url = Bundle.module.url(forResource: "festivals-\(year)", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(YearFile.self, from: data) else {
            return nil
        }
        var expanded: [(Int, Int, Festival)] = []
        for entry in decoded.festivals {
            let festival = Festival(
                nameEN: entry.nameEN,
                nameNE: entry.nameNE,
                category: entry.category,
                isHoliday: entry.isHoliday
            )
            let endMonth = entry.endMonth ?? entry.month
            let endDay = entry.endDay ?? entry.day
            var (m, d) = (entry.month, entry.day)
            // Walk forward across days, rolling into the next month when needed.
            while true {
                expanded.append((m, d, festival))
                if m == endMonth && d == endDay { break }
                d += 1
                if let lengths = BSData.monthLengths(forYear: year), d > lengths[m - 1] {
                    m += 1
                    d = 1
                    if m > 12 { break }
                }
            }
        }
        return expanded
    }

    // MARK: - Query API

    /// All festivals on a given date (recurring + yearly merged). May
    /// contain multiple entries when several events share a day.
    public static func festivals(on date: BSDate) -> [Festival] {
        var result: [Festival] = []
        for (m, d, f) in recurring where m == date.month && d == date.day {
            result.append(f)
        }
        if let yearly = yearlyTable[date.year] {
            for (m, d, f) in yearly where m == date.month && d == date.day {
                result.append(f)
            }
        }
        return result
    }

    /// The "primary" festival for a day. Holiday entries take precedence
    /// over non-holiday entries; among entries of the same kind, the first
    /// encountered (recurring layer first) wins.
    public static func primary(on date: BSDate) -> Festival? {
        let all = festivals(on: date)
        return all.first { $0.isHoliday } ?? all.first
    }

    /// Returns true if any festival on this date is a public holiday.
    public static func isHoliday(_ date: BSDate) -> Bool {
        festivals(on: date).contains { $0.isHoliday }
    }

    /// All days in the given BS month that have at least one festival,
    /// ordered by day.
    public static func festivalsByDay(forYear year: Int, month: Int) -> [(date: BSDate, festivals: [Festival])] {
        guard let lengths = BSData.monthLengths(forYear: year),
              (1...12).contains(month) else { return [] }
        var result: [(BSDate, [Festival])] = []
        for d in 1...lengths[month - 1] {
            let day = BSDate(year: year, month: month, day: d)
            let fs = festivals(on: day)
            if !fs.isEmpty {
                result.append((day, fs))
            }
        }
        return result
    }
}
