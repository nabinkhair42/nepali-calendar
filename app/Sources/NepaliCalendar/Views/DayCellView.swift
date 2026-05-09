import SwiftUI
import BSCore

struct DayCellView: View {
    let day: BSDate
    let isToday: Bool
    let isWeekend: Bool
    @EnvironmentObject var state: AppState
    @State private var hovered = false

    private var adDay: String {
        guard let ad = try? BSConverter.toAD(day) else { return "" }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return String(cal.component(.day, from: ad))
    }

    var body: some View {
        VStack(spacing: 1) {
            Text(NepaliFormatter.dayString(day.day, locale: state.localeMode))
                .font(.system(size: 14, weight: isToday ? .bold : .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(textColor)
            Text(adDay)
                .font(.system(size: 9, weight: .regular, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(isToday ? Color.white.opacity(0.85) : .secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 38)
        .background(background)
        .overlay(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(hovered && !isToday ? Color.primary.opacity(0.18) : .clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onHover { hovered = $0 }
    }

    @ViewBuilder
    private var background: some View {
        if isToday {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color.accentColor.gradient)
                .shadow(color: Color.accentColor.opacity(0.35), radius: 6, x: 0, y: 2)
        } else if isWeekend {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color.accentColor.opacity(0.08))
        } else {
            Color.clear
        }
    }

    private var textColor: Color {
        if isToday { return .white }
        if isWeekend { return Color.accentColor }
        return .primary
    }
}
