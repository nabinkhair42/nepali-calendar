import SwiftUI
import BSCore

/// आइत / सोम / मंगल / बुध / बिहि / शुक्र / शनि — or Sun / Mon / … / Sat.
/// Sun + Sat columns render in `Color.fgWeekend` (muted, NOT alert red).
struct WeekdayHeader: View {
    let locale: Locale_

    /// Per Cabinet decision Chaitra 23 2082 BS (Apr 6 2026), Sun + Sat are
    /// official off-days for government offices and schools.
    private static let weekendIndices: Set<Int> = [0, 6]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { i in
                Text(label(at: i))
                    .font(.label)
                    .tracking(0.4)
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
