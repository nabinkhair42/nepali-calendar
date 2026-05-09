import SwiftUI
import BSCore

/// Month title + AD subtitle on the left; chevron pill (prev / today / next)
/// on the right. Three nav buttons live in a single rounded container with
/// hairline dividers between them, matching reference patro UIs.
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
                    .fontWeight(.bold)
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
        HStack(spacing: 0) {
            NavButton(system: "chevron.left", action: onPrev)
                .keyboardShortcut(.leftArrow, modifiers: .command)
                .help("Previous month (⌘←)")
            HairLine()
            NavButton(system: "scope", action: onToday)
                .keyboardShortcut("t", modifiers: .command)
                .help("Today (⌘T)")
            HairLine()
            NavButton(system: "chevron.right", action: onNext)
                .keyboardShortcut(.rightArrow, modifiers: .command)
                .help("Next month (⌘→)")
        }
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

private struct HairLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.14))
            .frame(width: 1, height: 14)
    }
}

private struct NavButton: View {
    let system: String
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 28, height: 24)
                .background(hovered ? Color.primary.opacity(0.08) : Color.clear)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}
