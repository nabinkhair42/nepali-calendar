import SwiftUI
import BSCore

/// One day in the month grid. State is composed externally — this view is
/// pure presentational so the grid can drive it from any source (events,
/// EventKit overlay, festivals layer, panchanga layer).
///
/// Visual semantics:
///   - Today           → BS numeral in `accentToday` (red), semibold weight
///   - Selected        → soft blue-tinted pill, primary numerals
///   - Today + Selected → pill + red numeral (color signal survives the fill)
///   - Holiday         → amber dot, top-right
///   - Saait           → soft green dot, bottom-right
///   - Weekend column  → muted weekend foreground (NOT alert red); today's
///                       red overrides the weekend hue so weekends-that-are-
///                       today still read as today first.
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
            // Selected fill — soft tint pill, sits beneath the numerals.
            // Today no longer adds a ring on top; today's identity is now
            // carried by the numeral color + weight so the cell stays clean
            // whether or not it's also the selected day.
            if state.isSelected {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentSelectedFill)
            }

            VStack(spacing: 0) {
                Text(NepaliFormatter.dayString(state.bsDay, locale: locale))
                    .font(numeralFont)
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
        // Today owns the red — wins over weekend tint and the selected fill.
        if state.isToday { return .accentToday }
        if state.isWeekend { return .fgWeekend }
        return .fgPrimary
    }

    private var numeralFont: Font {
        // Bump today to semibold; everything else stays at the regular
        // weight defined by `.cellNumeral`.
        state.isToday
            ? Font.system(size: 18, weight: .semibold, design: .rounded)
            : .cellNumeral
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
