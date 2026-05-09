import Foundation

public enum Locale_ {
    case english
    case nepali
}

public enum NepaliFormatter {
    public static let monthsEN: [String] = [
        "Baisakh", "Jestha", "Asar", "Shrawan", "Bhadra", "Ashwin",
        "Kartik", "Mangsir", "Poush", "Magh", "Falgun", "Chaitra"
    ]
    public static let monthsEN_short: [String] = [
        "Bai", "Jes", "Asa", "Shr", "Bha", "Ash",
        "Kar", "Man", "Pou", "Mag", "Fal", "Cha"
    ]
    public static let monthsNE: [String] = [
        "बैशाख", "जेठ", "असार", "साउन", "भदौ", "असोज",
        "कार्तिक", "मंसिर", "पुष", "माघ", "फाल्गुण", "चैत"
    ]
    public static let monthsNE_short: [String] = [
        "बै", "जे", "अ", "सा", "भ", "अ",
        "का", "मं", "पु", "मा", "फा", "चै"
    ]

    public static let weekdaysEN: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    public static let weekdaysNE: [String] = ["आइत", "सोम", "मंगल", "बुध", "बिहि", "शुक्र", "शनि"]
    public static let weekdaysEN_full: [String] = [
        "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
    ]

    private static let nepaliDigits: [Character] = ["०", "१", "२", "३", "४", "५", "६", "७", "८", "९"]

    public static func toNepaliDigits(_ n: Int) -> String {
        String(String(n).map { ch -> Character in
            guard let d = ch.wholeNumberValue, (0...9).contains(d) else { return ch }
            return nepaliDigits[d]
        })
    }

    public static func monthName(_ m: Int, locale: Locale_, short: Bool = false) -> String {
        let i = max(0, min(11, m - 1))
        switch (locale, short) {
        case (.english, false): return monthsEN[i]
        case (.english, true):  return monthsEN_short[i]
        case (.nepali, false):  return monthsNE[i]
        case (.nepali, true):   return monthsNE_short[i]
        }
    }

    public static func dayString(_ d: Int, locale: Locale_) -> String {
        locale == .nepali ? toNepaliDigits(d) : String(d)
    }

    public static func yearString(_ y: Int, locale: Locale_) -> String {
        locale == .nepali ? toNepaliDigits(y) : String(y)
    }

    /// Compact label for the menu bar: "Jes 26" / "जेठ २६".
    public static func menuBarLabel(_ bs: BSDate, locale: Locale_) -> String {
        let m = monthName(bs.month, locale: locale, short: locale == .english)
        let d = dayString(bs.day, locale: locale)
        return "\(m) \(d)"
    }

    /// Header label for popover: "Jestha 2082" / "जेठ २०८२".
    public static func headerLabel(_ bs: BSDate, locale: Locale_) -> String {
        "\(monthName(bs.month, locale: locale)) \(yearString(bs.year, locale: locale))"
    }

    /// AD subtitle: "May–Jun 2026" or "May 2026" if month doesn't span.
    public static func adSubtitle(forBSMonth bs: BSDate) -> String {
        guard let firstAD = try? BSConverter.toAD(BSDate(year: bs.year, month: bs.month, day: 1)),
              let lengths = BSData.monthLengths(forYear: bs.year) else { return "" }
        let last = BSDate(year: bs.year, month: bs.month, day: lengths[bs.month - 1])
        guard let lastAD = try? BSConverter.toAD(last) else { return "" }

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let f = DateFormatter()
        f.timeZone = cal.timeZone
        f.dateFormat = "LLL"
        let m1 = f.string(from: firstAD)
        let m2 = f.string(from: lastAD)
        f.dateFormat = "yyyy"
        let y1 = f.string(from: firstAD)
        let y2 = f.string(from: lastAD)
        if m1 == m2 && y1 == y2 { return "\(m1) \(y1)" }
        if y1 == y2 { return "\(m1)–\(m2) \(y2)" }
        return "\(m1) \(y1) – \(m2) \(y2)"
    }
}
