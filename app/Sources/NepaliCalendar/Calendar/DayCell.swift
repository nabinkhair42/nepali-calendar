import SwiftUI
import BSCore
struct DayCell: View {
    struct ViewState: Equatable {
        var bsDay: Int
        var adDay: Int
        var isToday: Bool
        var isSelected: Bool
        var isWeekend: Bool
        var isHoliday: Bool
        var isSaait: Bool
        var eventDotColors: [Color]
    }

    let state: ViewState
    let locale: Locale_
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            cellContent
        }
        .buttonStyle(DayCellButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(accessibilityLabel)
    }

    private var cellContent: some View {
        ZStack {
            if state.isSelected {
                RoundedRectangle(cornerRadius: Metrics.radiusDayCell, style: .continuous)
                    .fill(Color.accentSelectedFill)
            }

            VStack(spacing: 0) {
                Text(NepaliFormatter.dayString(state.bsDay, locale: locale))
                    .font(.cellNumeral(isToday: state.isToday))
                    .monospacedDigit()
                    .foregroundStyle(numeralColor)
                    .padding(.top, 8)
                Spacer(minLength: 0)
                Text("\(state.adDay)")
                    .font(.cellSubNumeral)
                    .monospacedDigit()
                    .foregroundStyle(adColor)
                    .padding(.bottom, 6)
            }

            if state.isHoliday {
                dot(.accentHoliday, size: 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 6)
                    .padding(.trailing, 6)
            }

            if state.isSaait {
                dot(.accentSaait, size: 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.bottom, 6)
                    .padding(.trailing, 6)
            }

            if !state.eventDotColors.isEmpty {
                HStack(spacing: 2) {
                    ForEach(state.eventDotColors.prefix(3).indices, id: \.self) { i in
                        Circle()
                            .fill(state.eventDotColors[i])
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 3)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: Metrics.dayCellHeight)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func dot(_ color: Color, size: CGFloat) -> some View {
        Circle().fill(color).frame(width: size, height: size)
    }

    private var numeralColor: Color {
        if state.isToday { return .accentToday }
        if state.isWeekend { return .fgWeekend }
        return .fgPrimary
    }

    private var adColor: Color {
        if state.isToday { return Color.accentToday.opacity(0.65) }
        return Color.fgPrimary.opacity(state.isSelected ? 0.55 : 0.4)
    }

    private var accessibilityLabel: String {
        var parts: [String] = []
        parts.append("BS \(state.bsDay)")
        parts.append("AD \(state.adDay)")
        if state.isToday    { parts.append("Today") }
        if state.isSelected { parts.append("Selected") }
        if state.isHoliday  { parts.append("Holiday") }
        if state.isSaait    { parts.append("Auspicious") }
        return parts.joined(separator: ", ")
    }
}

private struct DayCellButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(
                configuration.isPressed && !reduceMotion ? Metrics.pressScale : 1
            )
            .animation(
                reduceMotion ? nil : .easeOut(duration: 0.08),
                value: configuration.isPressed
            )
    }
}
