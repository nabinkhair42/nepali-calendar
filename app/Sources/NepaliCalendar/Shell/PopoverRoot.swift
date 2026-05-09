import SwiftUI
import AppKit
import BSCore

/// Root composition for the popover content. Order:
///   MonthHeader → MonthGrid → SelectedDayPanel → FooterBar
/// Material is applied here. Width is fixed at 360pt per v2 spec.
///
/// Keyboard shortcuts (active while the popover is the key window):
///   ⌘← / ⌘→  prev / next month         (NavPill buttons)
///   ⌘T       jump to today              (NavPill scope button)
///   ⌘Q       quit Nepali Calendar       (hidden binding here)
///   ⌘K       command palette            (Tier 1.7 — disabled stub)
///   ⌘,       settings                   (Tier 2.11 — disabled stub)
struct PopoverRoot: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            MonthHeader(
                viewing: state.viewing,
                locale: state.localeMode,
                onPrev:  { state.goPrev() },
                onNext:  { state.goNext() },
                onToday: { state.goToday() }
            )

            MonthGrid(
                viewing: state.viewing,
                today: state.today,
                selected: state.selected,
                locale: state.localeMode,
                onSelect: { state.select($0) }
            )
            .padding(.horizontal, 14)
            .padding(.bottom, 12)

            Divider().opacity(0.2)

            SelectedDayPanel(
                date: state.selected,
                today: state.today,
                locale: state.localeMode
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().opacity(0.2)

            FooterBar()
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
        )
        .preferredColorScheme(nil)
        .background(KeyboardShortcuts())
    }
}

/// Bottom row: locale toggle (transitional — moves to Settings when that
/// ships), placeholders for ⌘K and ⌘, that read as disabled with help
/// text until the underlying features land.
private struct FooterBar: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        HStack(spacing: 6) {
            LocaleToggle()
            Spacer()
            FooterIconButton(systemName: "command", isDisabled: true)
                .help("Command palette · ⌘K (coming soon)")
            FooterIconButton(systemName: "gearshape", isDisabled: true)
                .help("Settings · ⌘, (coming soon)")
        }
    }
}

private struct LocaleToggle: View {
    @EnvironmentObject var state: AppState
    @State private var hovered = false

    var body: some View {
        Button {
            state.toggleLocale()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "character.book.closed")
                    .font(.system(size: 11, weight: .semibold))
                Text(state.localeMode == .nepali ? "ने" : "EN")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(hovered ? Color.primary.opacity(0.12) : Color.primary.opacity(0.07))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .help(state.localeMode == .nepali ? "Switch to English" : "Switch to Nepali")
    }
}

private struct FooterIconButton: View {
    let systemName: String
    var action: (() -> Void)? = nil
    var isDisabled: Bool = false
    @State private var hovered = false

    var body: some View {
        Button {
            action?()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 26, height: 22)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                            isDisabled
                                ? Color.primary.opacity(0.04)
                                : (hovered ? Color.primary.opacity(0.12) : Color.primary.opacity(0.07))
                        )
                )
                .opacity(isDisabled ? 0.4 : 1)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .onHover { if !isDisabled { hovered = $0 } }
    }
}

/// Hidden, zero-sized buttons that own keyboard shortcuts the visible UI
/// doesn't expose (⌘Q, plus stubs for ⌘K / ⌘, that just no-op for now).
private struct KeyboardShortcuts: View {
    var body: some View {
        ZStack {
            Button("Quit") { NSApp.terminate(nil) }
                .keyboardShortcut("q", modifiers: .command)
            Button("Command palette") { /* Tier 1.7 */ }
                .keyboardShortcut("k", modifiers: .command)
            Button("Settings") { /* Tier 2.11 */ }
                .keyboardShortcut(",", modifiers: .command)
        }
        .opacity(0)
        .frame(width: 0, height: 0)
        .accessibilityHidden(true)
    }
}
