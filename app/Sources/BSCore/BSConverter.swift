import Foundation

public enum BSConverterError: Error {
    case outOfRange
}

public enum BSConverter {
    private static let utc = TimeZone(identifier: "UTC")!

    private static var epochAD: Date = {
        var c = DateComponents()
        c.year = BSData.epochComponents.year
        c.month = BSData.epochComponents.month
        c.day = BSData.epochComponents.day
        c.timeZone = utc
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = utc
        return cal.date(from: c)!
    }()

    /// Convert AD date → BS date. Pass `.current` or `.autoupdatingCurrent`
    /// so that "today" resolves to the user's local calendar day; otherwise
    /// a date sampled at local midnight (like the menu-bar refresh) collapses
    /// to the previous UTC day and returns yesterday's BS.
    public static func toBS(_ adDate: Date, in timeZone: TimeZone = TimeZone(identifier: "UTC")!) throws -> BSDate {
        // Read the calendar day in the requested zone…
        var localCal = Calendar(identifier: .gregorian)
        localCal.timeZone = timeZone
        let comps = localCal.dateComponents([.year, .month, .day], from: adDate)

        // …then anchor that day to UTC midnight so the day-count arithmetic
        // against epochAD (also UTC midnight) stays integer-clean.
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = utc
        var c = DateComponents()
        c.year = comps.year
        c.month = comps.month
        c.day = comps.day
        c.timeZone = utc
        guard let asUTC = utcCal.date(from: c) else { throw BSConverterError.outOfRange }

        let days = utcCal.dateComponents([.day], from: epochAD, to: asUTC).day ?? 0
        guard days >= 0 else { throw BSConverterError.outOfRange }

        var remaining = days
        for y in BSData.minYear...BSData.maxYear {
            let row = BSData.years[y - BSData.minYear]
            if remaining >= row[12] {
                remaining -= row[12]
                continue
            }
            for m in 0..<12 {
                if remaining >= row[m] {
                    remaining -= row[m]
                    continue
                }
                return BSDate(year: y, month: m + 1, day: remaining + 1)
            }
        }
        throw BSConverterError.outOfRange
    }

    /// Convert BS date → AD date (start of day, UTC).
    public static func toAD(_ bs: BSDate) throws -> Date {
        guard (BSData.minYear...BSData.maxYear).contains(bs.year),
              (1...12).contains(bs.month) else {
            throw BSConverterError.outOfRange
        }
        var totalDays = 0
        for y in BSData.minYear..<bs.year {
            totalDays += BSData.years[y - BSData.minYear][12]
        }
        let row = BSData.years[bs.year - BSData.minYear]
        for m in 0..<(bs.month - 1) {
            totalDays += row[m]
        }
        guard bs.day >= 1 && bs.day <= row[bs.month - 1] else {
            throw BSConverterError.outOfRange
        }
        totalDays += bs.day - 1

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = utc
        return cal.date(byAdding: .day, value: totalDays, to: epochAD)!
    }

    /// Weekday for a BS date: 1 = Sunday … 7 = Saturday.
    public static func weekday(_ bs: BSDate) -> Int {
        guard let ad = try? toAD(bs) else { return 1 }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = utc
        return cal.component(.weekday, from: ad)
    }
}
