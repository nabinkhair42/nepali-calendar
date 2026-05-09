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
    }

    private var calendarBody: some View {
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

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "gearshape")
                    .font(.system(size: 11, weight: .semibold))
                Text("Settings")
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(hovered ? Color.primary.opacity(0.12) : Color.primary.opacity(0.07))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
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
