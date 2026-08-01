import SwiftUI
import AppKit
import BSCore

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
        .clipShape(RoundedRectangle(cornerRadius: Metrics.radiusShell, style: .continuous))
        .surfaceShadow()
        .preferredColorScheme(nil)
        .background(KeyboardShortcuts(route: $route))
        .animation(.easeInOut(duration: 0.18), value: route)
        .onAppear { state.refreshToday() }
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

            Divider().overlay(Color.dividerSubtle)

            SelectedDayPanel(
                date: state.selected,
                locale: state.localeMode
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().overlay(Color.dividerSubtle)

            FooterBar(onShowSettings: { route = .settings })
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
        }
    }
}

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
            HStack(spacing: 6) {
                Image(systemName: "gearshape")
                Text("Settings")
            }
            .font(.button)
            .foregroundStyle(hovered ? Color.fgPrimary : Color.fgSecondary)
            .padding(.horizontal, 10)
            .frame(minWidth: Metrics.hitAreaMin, minHeight: Metrics.hitAreaMin)
            .background(
                RoundedRectangle(cornerRadius: Metrics.radiusControl + 1, style: .continuous)
                    .fill(hovered ? Color.surfaceHover : Color.clear)
            )
            .contentShape(Rectangle())
            .animation(.easeOut(duration: 0.12), value: hovered)
        }
        .buttonStyle(ToolbarButtonStyle())
        .onHover { hovered = $0 }
    }
}

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
