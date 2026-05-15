import SwiftUI
import AppKit
import BSCore

/// Root composition for the popover content. Routes between the calendar
/// and a single Settings panel that owns language, shortcuts cheatsheet,
/// and about. State-machine swaps the body in-place so we don't open
/// separate windows from a menu-bar app.
///
/// Keyboard shortcuts (active while the popover is the key window):
///   ⌘← / ⌘→  prev / next month
///   ⌘T       jump to today
///   ⌘L       toggle language
///   ⌘,       show / hide settings
///   ⌘Q       quit Nepali Calendar
///   esc      return to calendar (when on Settings)
struct PopoverRoot: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var updateChecker: UpdateChecker
    @State private var route: Route = .calendar

    enum Route: Equatable { case calendar, settings }

    var body: some View {
        Group {
            switch route {
            case .calendar: calendarBody
            case .settings: SettingsView(onClose: { route = .calendar })
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
        )
        .preferredColorScheme(nil)
        .background(KeyboardShortcuts(route: $route))
        .animation(.easeInOut(duration: 0.18), value: route)
        // Catch any midnight flip the timer missed (e.g. Mac was asleep) the
        // moment the user opens the menu — see issue #1.
        .onAppear { state.refreshToday() }
        // Each time the popover panel becomes key (i.e. the user clicks the
        // menu-bar icon to open it), snap back to today's month. The
        // SwiftUI view stays mounted across open/close so `.onAppear` only
        // fires once — relying on it would leave the calendar parked on
        // whatever month the user last navigated to.
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            state.refreshToday()
            state.goToday()
        }
    }

    private var calendarBody: some View {
        VStack(spacing: 0) {
            UpdateBanner(checker: updateChecker)

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
                locale: state.localeMode
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().opacity(0.2)

            FooterBar(onShowSettings: { route = .settings })
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
        }
    }
}

/// Bottom row of the calendar view. Single labelled Settings button
/// aligned right — owns shortcuts, language, and about behind it.
private struct FooterBar: View {
    let onShowSettings: () -> Void

    var body: some View {
        HStack {
            Spacer()
            SettingsButton(action: onShowSettings)
                .help("Settings · ⌘,")
        }
    }
}

private struct SettingsButton: View {
    let action: () -> Void
    @State private var hovered = false
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12, weight: .medium))
                Text("Settings")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(hovered ? Color.fgPrimary : Color.fgSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(backgroundFill)
            )
            .contentShape(Rectangle())
            .animation(.easeOut(duration: 0.12), value: hovered)
            .animation(.easeOut(duration: 0.08), value: pressed)
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }

    /// Flat at rest, soft hover, slightly darker on press. Mirrors the
    /// macOS toolbar-button idiom instead of looking like a permanent
    /// selection pill.
    private var backgroundFill: Color {
        if pressed { return Color.primary.opacity(0.12) }
        if hovered { return Color.primary.opacity(0.07) }
        return Color.clear
    }
}

/// Hidden, zero-sized buttons that own keyboard shortcuts the visible UI
/// doesn't expose directly.
private struct KeyboardShortcuts: View {
    @Binding var route: PopoverRoot.Route
    @EnvironmentObject var state: AppState

    var body: some View {
        ZStack {
            Button("Quit") { NSApp.terminate(nil) }
                .keyboardShortcut("q", modifiers: .command)

            Button("Show settings") {
                route = (route == .settings) ? .calendar : .settings
            }
            .keyboardShortcut(",", modifiers: .command)

            Button("Toggle language") { state.toggleLocale() }
                .keyboardShortcut("l", modifiers: .command)
        }
        .opacity(0)
        .frame(width: 0, height: 0)
        .accessibilityHidden(true)
    }
}
