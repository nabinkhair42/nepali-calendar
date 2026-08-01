import SwiftUI
import BSCore
struct MonthHeader: View {
    let viewing: BSDate
    let locale: Locale_
    let onPrev: () -> Void
    let onNext: () -> Void
    let onToday: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(NepaliFormatter.headerLabel(viewing, locale: locale))
                    .font(.display)
                    .headingStyle()
                    .foregroundStyle(Color.fgPrimary)
                Text(NepaliFormatter.adSubtitle(forBSMonth: viewing))
                    .font(.label)
                    .foregroundStyle(Color.fgSecondary)
            }
            Spacer(minLength: 8)
            NavPill(onPrev: onPrev, onToday: onToday, onNext: onNext)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
}

private struct NavPill: View {
    let onPrev: () -> Void
    let onToday: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            NavButton(system: "chevron.left", action: onPrev)
                .keyboardShortcut(.leftArrow, modifiers: .command)
                .help("Previous month (⌘←)")
            NavButton(system: "scope", action: onToday)
                .keyboardShortcut("t", modifiers: .command)
                .help("Today (⌘T)")
            NavButton(system: "chevron.right", action: onNext)
                .keyboardShortcut(.rightArrow, modifiers: .command)
                .help("Next month (⌘→)")
        }
    }
}

private struct NavButton: View {
    let system: String
    let action: () -> Void
    @State private var hovered = false

    private var isChevron: Bool {
        system.hasPrefix("chevron")
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.button)
                .offset(x: isChevron ? -0.5 : 0)
                .foregroundStyle(hovered ? Color.fgPrimary : Color.fgSecondary)
                .frame(
                    width: Metrics.hitAreaMin,
                    height: Metrics.hitAreaMin
                )
                .background(
                    RoundedRectangle(cornerRadius: Metrics.radiusControl, style: .continuous)
                        .fill(hovered ? Color.surfaceHover : Color.clear)
                )
                .contentShape(Rectangle())
                .animation(.easeOut(duration: 0.12), value: hovered)
        }
        .buttonStyle(ToolbarButtonStyle())
        .onHover { hovered = $0 }
    }
}
