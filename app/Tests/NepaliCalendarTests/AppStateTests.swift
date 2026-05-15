import XCTest
import BSCore
@testable import NepaliCalendar

@MainActor
final class AppStateTests: XCTestCase {
    func testRefreshAdvancesSelectedDayAndVisibleMonthWhenTrackingToday() throws {
        var now = date(year: 2026, month: 5, day: 10, hour: 18)
        let state = testState(now: { now })
        let initialToday = try BSConverter.toBS(now, in: nepalTimeZone)

        XCTAssertEqual(state.today, initialToday)
        XCTAssertEqual(state.selected, initialToday)
        XCTAssertEqual(state.viewing, monthStart(initialToday))

        now = date(year: 2026, month: 5, day: 10, hour: 18, minute: 30)
        let refreshedToday = try BSConverter.toBS(now, in: nepalTimeZone)
        XCTAssertNotEqual(refreshedToday, initialToday)

        state.refreshToday()

        XCTAssertEqual(state.today, refreshedToday)
        XCTAssertEqual(state.selected, refreshedToday)
        XCTAssertEqual(state.viewing, monthStart(refreshedToday))
    }

    func testRefreshPreservesManualSelectionAfterMidnight() throws {
        var now = date(year: 2026, month: 5, day: 10, hour: 18)
        let state = testState(now: { now })

        state.goPrev()
        let manuallyViewedMonth = state.viewing
        let manuallySelectedDay = state.selected

        now = date(year: 2026, month: 5, day: 10, hour: 18, minute: 30)
        let refreshedToday = try BSConverter.toBS(now, in: nepalTimeZone)

        state.refreshToday()

        XCTAssertEqual(state.today, refreshedToday)
        XCTAssertEqual(state.viewing, manuallyViewedMonth)
        XCTAssertEqual(state.selected, manuallySelectedDay)
    }

    func testJumpingBackToTodayReEnablesAutomaticTracking() throws {
        var now = date(year: 2026, month: 5, day: 10, hour: 18)
        let state = testState(now: { now })

        state.goPrev()
        state.goToday()

        now = date(year: 2026, month: 5, day: 10, hour: 18, minute: 30)
        let refreshedToday = try BSConverter.toBS(now, in: nepalTimeZone)

        state.refreshToday()

        XCTAssertEqual(state.today, refreshedToday)
        XCTAssertEqual(state.selected, refreshedToday)
        XCTAssertEqual(state.viewing, monthStart(refreshedToday))
    }

    func testRefreshUsesLocalCalendarDayInsteadOfUTCDefault() throws {
        var now = date(year: 2026, month: 5, day: 10, hour: 18, minute: 30)
        let state = testState(now: { now })
        let initialToday = try BSConverter.toBS(now, in: nepalTimeZone)

        XCTAssertNotEqual(initialToday, try BSConverter.toBS(now))
        XCTAssertEqual(state.today, initialToday)

        now = date(year: 2026, month: 5, day: 11, hour: 18, minute: 30)
        let refreshedToday = try BSConverter.toBS(now, in: nepalTimeZone)
        XCTAssertNotEqual(refreshedToday, initialToday)

        state.refreshToday()

        XCTAssertEqual(state.today, refreshedToday)
        XCTAssertEqual(state.selected, refreshedToday)
    }

    private var nepalTimeZone: TimeZone {
        TimeZone(identifier: "Asia/Kathmandu")!
    }

    private func testState(now: @escaping () -> Date) -> AppState {
        AppState(
            dateProvider: now,
            timeZoneProvider: { self.nepalTimeZone },
            startAutomaticRefresh: false
        )
    }

    private func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int = 0
    ) -> Date {
        var components = DateComponents()
        components.timeZone = TimeZone(identifier: "UTC")!
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: components)!
    }

    private func monthStart(_ date: BSDate) -> BSDate {
        BSDate(year: date.year, month: date.month, day: 1)
    }
}
