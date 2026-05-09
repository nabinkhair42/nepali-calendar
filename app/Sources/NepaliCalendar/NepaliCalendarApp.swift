import SwiftUI
import AppKit
import BSCore

@main
struct NepaliCalendarApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        MenuBarExtra {
            PopoverRoot()
                .environmentObject(state)
                .frame(width: 360)
        } label: {
            MenuBarLabel(today: state.today, locale: state.localeMode)
        }
        .menuBarExtraStyle(.window)
    }
}
