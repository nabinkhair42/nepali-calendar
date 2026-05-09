import Foundation
import Combine

/// Festival/holiday lookup. Two layers compose at query time:
///
///   1. **Recurring** — fixed BS-day events that repeat every year
///      (Nepali New Year on 1 Baisakh, Constitution Day on 3 Asoj, …).
///      Hard-coded since they are constant.
///   2. **Yearly** — lunar-anchored or AD-anchored events whose BS day
///      shifts each year (Dashain, Tihar, Buddha Jayanti, Holi, …).
///      Loaded from `festivals-<year>.json` via `FestivalDataSource` —
///      cache → bundle → network, in that order.
///
/// `bootstrap(years:)` runs synchronously at app launch from cache+bundle,
/// then a background `refresh(years:)` fetches fresh JSON and re-parses.
/// Because this is an `ObservableObject`, any view holding a reference will
/// redraw automatically when the table updates.
@MainActor
public final class FestivalDatabase: ObservableObject {

    public static let shared = FestivalDatabase()

    /// year → list of (month, day, festival), with multi-day events expanded.
    @Published private var yearlyTable: [Int: [DayFestival]] = [:]

    public init() {}

    // MARK: - Recurring (fixed BS-day) entries

    private static let recurring: [DayFestival] = [
        DayFestival(month: 1,  day: 1,
            festival: Festival(nameEN: "Nepali New Year",  nameNE: "नयाँ वर्ष",        category: .national,  isHoliday: true)),
        DayFestival(month: 2,  day: 15,
            festival: Festival(nameEN: "Republic Day",     nameNE: "गणतन्त्र दिवस",     category: .national,  isHoliday: true)),
        DayFestival(month: 6,  day: 3,
            festival: Festival(nameEN: "Constitution Day", nameNE: "संविधान दिवस",       category: .national,  isHoliday: true)),
        DayFestival(month: 10, day: 1,
            festival: Festival(nameEN: "Maghe Sankranti",  nameNE: "माघे संक्रान्ति",   category: .religious, isHoliday: true)),
        DayFestival(month: 10, day: 16,
            festival: Festival(nameEN: "Martyrs' Day",     nameNE: "शहीद दिवस",          category: .national,  isHoliday: true)),
        DayFestival(month: 11, day: 7,
            festival: Festival(nameEN: "Democracy Day",    nameNE: "प्रजातन्त्र दिवस",  category: .national,  isHoliday: true)),
    ]

    // MARK: - Bootstrap & refresh

    /// Populate the table for the given years from cache + bundle. Synchronous
    /// because the app needs festival data on first frame; both sources are
    /// local file reads.
    public func bootstrap(years: [Int]) {
        for year in years {
            if let data = FestivalDataSource.loadCachedOrBundled(year: year),
               let entries = Self.parse(data: data, forYear: year) {
                yearlyTable[year] = entries
            }
        }
    }

    /// Pull fresh JSON from the network for each year. Updates the table
    /// (and triggers a redraw) only for years whose bytes actually changed.
    public func refresh(years: [Int]) async {
        for year in years {
            if let data = await FestivalDataSource.refresh(year: year),
               let entries = Self.parse(data: data, forYear: year) {
                yearlyTable[year] = entries
            }
        }
    }

    // MARK: - Query API

    /// All festivals on a given date (recurring + yearly merged). May contain
    /// multiple entries when several events share a day.
    public func festivals(on date: BSDate) -> [Festival] {
        var result: [Festival] = []
        for entry in Self.recurring where entry.month == date.month && entry.day == date.day {
            result.append(entry.festival)
        }
        if let yearly = yearlyTable[date.year] {
            for entry in yearly where entry.month == date.month && entry.day == date.day {
                result.append(entry.festival)
            }
        }
        return result
    }

    /// The "primary" festival for a day. Holiday entries take precedence over
    /// non-holiday entries; among entries of the same kind, the first
    /// encountered (recurring layer first) wins.
    public func primary(on date: BSDate) -> Festival? {
        let all = festivals(on: date)
        return all.first { $0.isHoliday } ?? all.first
    }

    /// Returns true if any festival on this date is a public holiday.
    public func isHoliday(_ date: BSDate) -> Bool {
        festivals(on: date).contains { $0.isHoliday }
    }

    /// All days in the given BS month that have at least one festival,
    /// ordered by day.
    public func festivalsByDay(forYear year: Int, month: Int) -> [(date: BSDate, festivals: [Festival])] {
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

    // MARK: - Parsing

    private struct DayFestival {
        let month: Int
        let day: Int
        let festival: Festival
    }

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

    private static func parse(data: Data, forYear year: Int) -> [DayFestival]? {
        guard let decoded = try? JSONDecoder().decode(YearFile.self, from: data) else {
            return nil
        }
        var expanded: [DayFestival] = []
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
            // Walk forward, rolling into the next month when needed.
            while true {
                expanded.append(DayFestival(month: m, day: d, festival: festival))
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
}
