import SwiftUI
import AppKit
import BSCore

@main
struct NepaliCalendarApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        MenuBarExtra {
            PopoverRootView()
                .environmentObject(state)
                .frame(width: 320)
        } label: {
            MenuBarLabelView(today: state.today, locale: state.localeMode)
        }
        .menuBarExtraStyle(.window)
    }
}
