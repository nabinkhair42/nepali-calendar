import Foundation
import SwiftUI
import Combine
import AppKit
import BSCore

@MainActor
final class AppState: ObservableObject {
    @Published var today: BSDate
    @Published var viewing: BSDate           // first-of-month being shown
    @Published var selected: BSDate          // currently selected day in viewing month
    @Published var localeMode: Locale_

    private var midnightTimer: Timer?
    private var heartbeatTimer: Timer?
    private var wakeObserver: NSObjectProtocol?
    private var sleepObserver: NSObjectProtocol?

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
        scheduleHeartbeat()
        observeSystemPower()
    }

    deinit {
        midnightTimer?.invalidate()
        heartbeatTimer?.invalidate()
        let nc = NSWorkspace.shared.notificationCenter
        if let wakeObserver { nc.removeObserver(wakeObserver) }
        if let sleepObserver { nc.removeObserver(sleepObserver) }
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

    /// Recompute `today` from wall-clock now. Cheap (no I/O), idempotent —
    /// safe to call from any of the refresh paths (midnight, wake, popover,
    /// heartbeat). Only assigns when the day actually flipped so `@Published`
    /// doesn't churn views every minute.
    func refreshToday() {
        guard let bs = try? BSConverter.toBS(Date(), in: .current) else { return }
        if bs != today {
            today = bs
        }
    }

    /// Refresh `today` at the next local midnight so the highlighted cell stays current.
    /// On its own this is fragile — `Timer` doesn't fire while the Mac is asleep, so we
    /// also wire wake + heartbeat + popover-open as backstops (see issue #1).
    private func scheduleMidnightTick() {
        let cal = Calendar.current
        let now = Date()
        guard let nextMidnight = cal.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 5), matchingPolicy: .nextTime) else { return }
        let interval = nextMidnight.timeIntervalSince(now)
        midnightTimer?.invalidate()
        midnightTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.refreshToday()
                self.scheduleMidnightTick()
            }
        }
    }

    /// 60-second backstop. After a sleep, `Timer` will start firing again on
    /// wake; the first tick catches any missed midnight transition. Cheap
    /// enough to run forever — a single date-components diff + array walk.
    private func scheduleHeartbeat() {
        heartbeatTimer?.invalidate()
        let timer = Timer(timeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshToday()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        heartbeatTimer = timer
    }

    /// Sleep/wake observers. Apple DTS pattern for time-sensitive timers:
    /// invalidate before sleep so the timer can't fire with a stale schedule
    /// on wake, then recompute + reschedule on wake. Timer-based deadlines
    /// rely on Mach absolute time, which pauses during system sleep.
    private func observeSystemPower() {
        let nc = NSWorkspace.shared.notificationCenter
        sleepObserver = nc.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.midnightTimer?.invalidate()
                self?.midnightTimer = nil
            }
        }
        wakeObserver = nc.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.refreshToday()
                self.scheduleMidnightTick()
            }
        }
    }
}
