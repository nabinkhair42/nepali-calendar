import SwiftUI
import BSCore

struct MonthGridView: View {
    @EnvironmentObject var state: AppState

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    private var monthDays: [BSDate?] {
        let viewing = state.viewing
        guard let total = BSDate(year: viewing.year, month: viewing.month, day: 1).daysInMonth() else { return [] }
        let firstWeekday = BSConverter.weekday(BSDate(year: viewing.year, month: viewing.month, day: 1)) // 1=Sun
        let leading = firstWeekday - 1
        var slots: [BSDate?] = Array(repeating: nil, count: leading)
        for d in 1...total {
            slots.append(BSDate(year: viewing.year, month: viewing.month, day: d))
        }
        while slots.count % 7 != 0 { slots.append(nil) }
        return slots
    }

    var body: some View {
        VStack(spacing: 6) {
            // Weekday header row
            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { i in
                    Text(state.localeMode == .english ? NepaliFormatter.weekdaysEN[i] : NepaliFormatter.weekdaysNE[i])
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(i == 6 ? Color.accentColor : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            // Day cells
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(monthDays.enumerated()), id: \.offset) { idx, day in
                    if let day = day {
                        DayCellView(day: day, isToday: day == state.today, isWeekend: idx % 7 == 6)
                    } else {
                        Color.clear.frame(height: 38)
                    }
                }
            }
        }
    }
}
