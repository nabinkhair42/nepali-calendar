import SwiftUI
import AppKit
import BSCore

@main
struct NepaliCalendarApp: App {
    @StateObject private var state = AppState()
    @StateObject private var festivalDB = FestivalDatabase.shared

    init() {
        // Synchronously load this year ± 1 from cache+bundle so the first
        // frame is correct, then kick off a background refresh from the
        // network. The MainActor-isolated bootstrap is safe at App.init
        // because @main entry runs on the main thread.
        let years = Self.relevantYears()
        MainActor.assumeIsolated {
            FestivalDatabase.shared.bootstrap(years: years)
        }
        Task.detached(priority: .background) {
            await FestivalDatabase.shared.refresh(years: years)
        }
    }

    var body: some Scene {
        MenuBarExtra {
            PopoverRoot()
                .environmentObject(state)
                .environmentObject(festivalDB)
                .frame(width: 360)
        } label: {
            MenuBarLabel(today: state.today, locale: state.localeMode)
        }
        .menuBarExtraStyle(.window)
    }

    /// Years we keep loaded — current ± 1 so navigating into prev/next month
    /// at year boundaries shows the right festivals without re-fetching.
    private static func relevantYears() -> [Int] {
        let bs = (try? BSConverter.toBS(Date())) ?? BSDate(year: 2083, month: 1, day: 1)
        return [bs.year - 1, bs.year, bs.year + 1]
    }
}
