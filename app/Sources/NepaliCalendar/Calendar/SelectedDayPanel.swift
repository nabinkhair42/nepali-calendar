import SwiftUI
import BSCore

/// Detail panel for the currently-selected day. Shows weekday name +
/// full BS/AD date and any festivals/observances that fall on this date.
///
/// Reserved rows for Tithi / Nakshatra / Yog / Karana, Saait status, and
/// EventKit-overlay events render as soon as their data layers ship
/// (Tier 1.2, 1.5, and 2.12 respectively).
struct SelectedDayPanel: View {
    let date: BSDate
    let locale: Locale_

    @EnvironmentObject private var festivalDB: FestivalDatabase

    private var weekdayName: String {
        let idx = BSConverter.weekday(date) - 1
        return locale == .nepali
            ? NepaliFormatter.weekdaysNE_full[idx]
            : NepaliFormatter.weekdaysEN_full[idx]
    }

    private var bsDateString: String {
        let day = NepaliFormatter.dayString(date.day, locale: locale)
        let month = NepaliFormatter.monthName(date.month, locale: locale)
        let year = NepaliFormatter.yearString(date.year, locale: locale)
        return "\(day) \(month) \(year)"
    }

    private var adDateString: String {
        guard let ad = try? BSConverter.toAD(date) else { return "" }
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: ad)
    }

    private var festivals: [Festival] { festivalDB.festivals(on: date) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(weekdayName)
                    .font(.title)
                    .foregroundStyle(Color.fgPrimary)
                Spacer(minLength: 4)
                Text(adDateString)
                    .font(.label)
                    .monospacedDigit()
                    .foregroundStyle(Color.fgSecondary)
            }
            Text(bsDateString)
                .font(.bodyText)
                .foregroundStyle(Color.fgSecondary)
                .padding(.top, -2)

            if !festivals.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(festivals.enumerated()), id: \.offset) { _, festival in
                        FestivalRow(festival: festival, locale: locale)
                    }
                }
                .padding(.top, 6)
            }
        }
    }
}

private struct FestivalRow: View {
    let festival: Festival
    let locale: Locale_

    private var tintColor: Color {
        festival.isHoliday ? Color.accentHoliday : festival.category.observanceDotColor
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(tintColor)
                .frame(width: 7, height: 7)
            Text(festival.name(locale: locale))
                .font(.label)
                .foregroundStyle(Color.fgPrimary)
                .lineLimit(1)
            Spacer(minLength: 4)
            TagChip(
                text: festival.isHoliday ? "Holiday" : "Observance",
                tint: tintColor
            )
        }
    }
}

private struct TagChip: View {
    let text: String
    let tint: Color
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(tint)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(tint.opacity(0.10))
            )
            .overlay(
                Capsule()
                    .strokeBorder(tint.opacity(0.18), lineWidth: 0.5)
            )
    }
}
