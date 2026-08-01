import SwiftUI
import BSCore
struct MonthGrid: View {
    let viewing: BSDate
    let today: BSDate
    let selected: BSDate?
    let locale: Locale_
    let onSelect: (BSDate) -> Void

    @EnvironmentObject private var festivalDB: FestivalDatabase

    private static let columns = Array(
        repeating: GridItem(.flexible(), spacing: Metrics.gridSpacing),
        count: 7
    )
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

    private var monthKey: String {
        "\(viewing.year)-\(viewing.month)"
    }

    var body: some View {
        VStack(spacing: 8) {
            WeekdayHeader(locale: locale)
            LazyVGrid(columns: Self.columns, spacing: Metrics.gridSpacing) {
                ForEach(Array(slots.enumerated()), id: \.offset) { idx, day in
                    if let day = day {
                        DayCell(
                            state: viewState(for: day, columnIndex: idx % 7),
                            locale: locale,
                            onTap: { onSelect(day) }
                        )
                    } else {
                        Color.clear.frame(height: Metrics.dayCellHeight)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: monthKey)
    }

    private func viewState(for day: BSDate, columnIndex: Int) -> DayCell.ViewState {
        let festivals = festivalDB.festivals(on: day)
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
            isSaait: false,
            eventDotColors: Array(observanceColors)
        )
    }
}
