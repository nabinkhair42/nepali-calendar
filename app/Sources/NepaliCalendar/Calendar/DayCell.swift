import SwiftUI
import BSCore

/// One day in the month grid. State is composed externally — this view is
/// pure presentational so the grid can drive it from any source (events,
/// EventKit overlay, festivals layer, panchanga layer).
///
/// Visual semantics (per v2 spec):
///   - Today           → 1.5px red ring, no fill
///   - Selected        → solid blue pill, white numerals
///   - Today + Selected → ring composes over fill
///   - Holiday         → amber dot, top-right
///   - Saait           → soft green dot, bottom-right
///   - Weekend column  → muted weekend foreground (NOT alert red)
///   - Events          → row of small colored dots, bottom-center
struct DayCell: View {
    struct ViewState: Equatable {
        var bsDay: Int
        var adDay: Int
        var isToday: Bool
        var isSelected: Bool
        var isWeekend: Bool
        var isHoliday: Bool
        var isSaait: Bool
        /// Up to 3 user/system event colors rendered as tiny dots.
        var eventDotColors: [Color]
    }

    let state: ViewState
    let locale: Locale_
    let onTap: () -> Void

    var body: some View {
        ZStack {
            // 1. Selected fill — sits beneath everything else.
            if state.isSelected {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentSelected)
            }
            // 2. Today ring — composes over the selected fill so a
            //    today-AND-selected cell shows both signals.
            if state.isToday {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.accentToday, lineWidth: 1.5)
            }

            VStack(spacing: 0) {
                Text(NepaliFormatter.dayString(state.bsDay, locale: locale))
                    .font(.cellNumeral)
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

            // Holiday — amber dot, top-right.
            if state.isHoliday {
                dot(.accentHoliday, size: 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, 6)
                    .padding(.trailing, 6)
            }

            // Saait — soft green dot, bottom-right.
            if state.isSaait {
                dot(.accentSaait, size: 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.bottom, 6)
                    .padding(.trailing, 6)
            }

            // Event dots — bottom-center row, max 3.
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
        .frame(height: 52)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private func dot(_ color: Color, size: CGFloat) -> some View {
        Circle().fill(color).frame(width: size, height: size)
    }

    private var numeralColor: Color {
        if state.isSelected { return .white }
        if state.isWeekend  { return .fgWeekend }
        return .fgPrimary
    }

    private var adColor: Color {
        if state.isSelected { return Color.white.opacity(0.7) }
        return Color.fgPrimary.opacity(0.4)
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
