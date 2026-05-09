import SwiftUI
import BSCore

/// 7-column × 6-row month grid for a single BS month. Renders the weekday
/// header followed by 42 cells; trailing nil slots become invisible
/// spacers so the grid height is stable across 28/29/30/31/32-day months.
///
/// Pure: receives `viewing`, `today`, `selected`, `locale`, and emits a
/// selection callback. Holds no state of its own — the popover wires it
/// to the app-level state.
struct MonthGrid: View {
    let viewing: BSDate
    let today: BSDate
    let selected: BSDate?
    let locale: Locale_
    let onSelect: (BSDate) -> Void

    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private static let weekendIndices: Set<Int> = [0, 6]

    private var slots: [BSDate?] {
        guard let total = BSDate(year: viewing.year, month: viewing.month, day: 1).daysInMonth() else { return [] }
        let firstWeekday = BSConverter.weekday(BSDate(year: viewing.year, month: viewing.month, day: 1))
        let leading = firstWeekday - 1
        var arr: [BSDate?] = Array(repeating: nil, count: leading)
        for d in 1...total {
            arr.append(BSDate(year: viewing.year, month: viewing.month, day: d))
        }
        while arr.count < 42 { arr.append(nil) }
        return arr
    }

    var body: some View {
        VStack(spacing: 8) {
            WeekdayHeader(locale: locale)
            LazyVGrid(columns: Self.columns, spacing: 4) {
                ForEach(Array(slots.enumerated()), id: \.offset) { idx, day in
                    if let day = day {
                        DayCell(
                            state: viewState(for: day, columnIndex: idx % 7),
                            locale: locale,
                            onTap: { onSelect(day) }
                        )
                    } else {
                        Color.clear.frame(height: 52)
                    }
                }
            }
        }
    }

    private func viewState(for day: BSDate, columnIndex: Int) -> DayCell.ViewState {
        let festivals = FestivalDatabase.festivals(on: day)
        let isHoliday = festivals.contains { $0.isHoliday }
        let observanceColors = festivals
            .filter { !$0.isHoliday }
            .prefix(3)
            .map(\.category.observanceDotColor)
        let adDay: Int = {
            guard let ad = try? BSConverter.toAD(day) else { return 0 }
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(identifier: "UTC")!
            return cal.component(.day, from: ad)
        }()
        return DayCell.ViewState(
            bsDay: day.day,
            adDay: adDay,
            isToday: day == today,
            isSelected: selected == day,
            isWeekend: Self.weekendIndices.contains(columnIndex),
            isHoliday: isHoliday,
            isSaait: false,                 // wired in Tier 1.5 (SaaitCalculator)
            eventDotColors: Array(observanceColors)
        )
    }
}
