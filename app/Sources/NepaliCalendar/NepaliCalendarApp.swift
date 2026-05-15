import SwiftUI
import AppKit
import BSCore

@main
struct NepaliCalendarApp: App {
    @StateObject private var state = AppState()
    @StateObject private var festivalDB = FestivalDatabase.shared
    @StateObject private var updateChecker = UpdateChecker()
    @StateObject private var installation = InstallationManager()

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
        // Wrapped in a dedicated Scene struct with @ObservedObject so the
        // MenuBarExtra label and content actually re-render when AppState
        // changes. Declaring MenuBarExtra directly here against a Scene-level
        // @StateObject hits a SwiftUI bug where the label closure is not
        // invalidated on @Published mutations — see MenuBarLabel.
        MenuBarScene(
            state: state,
            festivalDB: festivalDB,
            updateChecker: updateChecker,
            installation: installation
        )
    }

    /// Years we keep loaded — current ± 1 so navigating into prev/next month
    /// at year boundaries shows the right festivals without re-fetching.
    private static func relevantYears() -> [Int] {
        let bs = (try? BSConverter.toBS(Date(), in: .autoupdatingCurrent)) ?? BSDate(year: 2083, month: 1, day: 1)
        return [bs.year - 1, bs.year, bs.year + 1]
    }
}

private struct MenuBarScene: Scene {
    @ObservedObject var state: AppState
    @ObservedObject var festivalDB: FestivalDatabase
    @ObservedObject var updateChecker: UpdateChecker
    @ObservedObject var installation: InstallationManager

    var body: some Scene {
        MenuBarExtra {
            PopoverRoot()
                .environmentObject(state)
                .environmentObject(festivalDB)
                .environmentObject(updateChecker)
                .environmentObject(installation)
                .frame(width: 360)
                .onAppear {
                    updateChecker.start()
                    installation.scan()
                }
        } label: {
            MenuBarLabel(state: state)
        }
        .menuBarExtraStyle(.window)
    }
}
