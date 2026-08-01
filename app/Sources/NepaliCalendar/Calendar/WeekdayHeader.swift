import SwiftUI
import BSCore
struct WeekdayHeader: View {
    let locale: Locale_

    private static let weekendIndices: Set<Int> = [0, 6]

    var body: some View {
        HStack(spacing: Metrics.gridSpacing) {
            ForEach(0..<7, id: \.self) { i in
                Text(label(at: i))
                    .font(.label)
                    .labelStyle()
                    .foregroundStyle(
                        Self.weekendIndices.contains(i) ? Color.fgWeekend : Color.fgSecondary
                    )
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func label(at index: Int) -> String {
        locale == .nepali
            ? NepaliFormatter.weekdaysNE[index]
            : NepaliFormatter.weekdaysEN[index]
    }
}
