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
                Divider()
                    .opacity(0.18)
                    .padding(.top, 8)
                    .padding(.bottom, 2)
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(Array(festivals.enumerated()), id: \.offset) { _, festival in
                        FestivalRow(festival: festival, locale: locale)
                    }
                }
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
        HStack(spacing: 9) {
            Circle()
                .fill(tintColor)
                .frame(width: 6, height: 6)
            Text(festival.name(locale: locale))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.fgPrimary)
                .lineLimit(1)
            Spacer(minLength: 4)
            // Only flag actual holidays — the "Observance" label that used to
            // repeat for every cultural/international row was visual noise.
            // The colored dot already carries the category signal.
            if festival.isHoliday {
                HolidayChip()
            }
        }
    }
}

/// Holiday badge. Solid amber fill + white text — readable in both light
/// and dark mode without depending on the popover surface luminance. The
/// earlier amber-on-amber-tint version had no contrast against itself.
private struct HolidayChip: View {
    var body: some View {
        Text("Holiday")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color.accentHoliday)
            )
    }
}
