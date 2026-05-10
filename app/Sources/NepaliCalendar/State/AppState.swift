import Foundation
import SwiftUI
import Combine
import BSCore

@MainActor
final class AppState: ObservableObject {
    @Published var today: BSDate
    @Published var viewing: BSDate           // first-of-month being shown
    @Published var selected: BSDate          // currently selected day in viewing month
    @Published var localeMode: Locale_

    private var tickTimer: Timer?

    init() {
        let now = Date()
        let bs = (try? BSConverter.toBS(now, in: .current)) ?? BSDate(year: 2082, month: 1, day: 1)
        self.today = bs
        self.viewing = BSDate(year: bs.year, month: bs.month, day: 1)
        self.selected = bs
        // Locale defaults to Nepali; persisted choice overrides on subsequent launches.
        if let raw = UserDefaults.standard.string(forKey: "localeMode"), raw == "english" {
            self.localeMode = .english
        } else {
            self.localeMode = .nepali
        }
        scheduleMidnightTick()
    }

    /// Move to the previous month and snap selection to its first day.
    func goPrev() {
        viewing = viewing.adding(months: -1)
        selected = BSDate(year: viewing.year, month: viewing.month, day: 1)
    }

    /// Move to the next month and snap selection to its first day.
    func goNext() {
        viewing = viewing.adding(months: 1)
        selected = BSDate(year: viewing.year, month: viewing.month, day: 1)
    }

    /// Jump to today: viewing = today's month, selected = today.
    func goToday() {
        viewing = BSDate(year: today.year, month: today.month, day: 1)
        selected = today
    }

    /// Select a specific day. The grid only emits dates inside the viewing
    /// month, so this won't push selection out of view.
    func select(_ date: BSDate) {
        selected = date
    }

    func toggleLocale() {
        localeMode = (localeMode == .english) ? .nepali : .english
        UserDefaults.standard.set(localeMode == .nepali ? "nepali" : "english", forKey: "localeMode")
    }

    /// Refresh `today` at the next local midnight so the highlighted cell stays current.
    private func scheduleMidnightTick() {
        let cal = Calendar.current
        let now = Date()
        guard let nextMidnight = cal.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 5), matchingPolicy: .nextTime) else { return }
        let interval = nextMidnight.timeIntervalSince(now)
        tickTimer?.invalidate()
        tickTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if let bs = try? BSConverter.toBS(Date(), in: .current) {
                    self.today = bs
                }
                self.scheduleMidnightTick()
            }
        }
    }
}
