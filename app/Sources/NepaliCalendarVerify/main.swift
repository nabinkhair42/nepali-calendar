// Self-contained correctness checks for BSCore — runs without XCTest.
//   swift run NepaliCalendarVerify

import Foundation
import BSCore

private var failures = 0
private var checks = 0

private func check(_ ok: Bool, _ msg: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    checks += 1
    if !ok {
        failures += 1
        FileHandle.standardError.write(Data("FAIL [\(file):\(line)] \(msg())\n".utf8))
    }
}

private let utc = TimeZone(identifier: "UTC")!
private var utcCal: Calendar = {
    var c = Calendar(identifier: .gregorian); c.timeZone = utc; return c
}()
private func adDate(_ y: Int, _ m: Int, _ d: Int) -> Date {
    var c = DateComponents(); c.year = y; c.month = m; c.day = d; c.timeZone = utc
    return Calendar(identifier: .gregorian).date(from: c)!
}

func testEpoch() throws {
    let bs = try BSConverter.toBS(adDate(1918, 4, 13))
    check(bs == BSDate(year: 1975, month: 1, day: 1), "epoch BS got \(bs)")
    let ad = try BSConverter.toAD(BSDate(year: 1975, month: 1, day: 1))
    check(utcCal.component(.year, from: ad) == 1918, "epoch AD year")
    check(utcCal.component(.month, from: ad) == 4, "epoch AD month")
    check(utcCal.component(.day, from: ad) == 13, "epoch AD day")
}

func testConstitutionDay() throws {
    let bs = try BSConverter.toBS(adDate(2015, 9, 20))
    check(bs == BSDate(year: 2072, month: 6, day: 3), "constitution day got \(bs)")
}

func testNewYear2080() throws {
    let ad = try BSConverter.toAD(BSDate(year: 2080, month: 1, day: 1))
    check(utcCal.component(.year, from: ad) == 2023, "2080 year")
    check(utcCal.component(.month, from: ad) == 4, "2080 month")
    check(utcCal.component(.day, from: ad) == 14, "2080 day")
}

func testRoundTripAllMonthStarts() throws {
    for y in 1975...2099 {
        for m in 1...12 {
            let bs = BSDate(year: y, month: m, day: 1)
            let ad = try BSConverter.toAD(bs)
            let back = try BSConverter.toBS(ad)
            check(bs == back, "BS round-trip \(y)-\(m)-1 -> \(back)")
        }
    }
}

func testRoundTripADRange() throws {
    for y in stride(from: 1920, through: 2042, by: 7) {
        for (m, d) in [(1, 15), (4, 1), (7, 4), (11, 30)] {
            let ad = adDate(y, m, d)
            let bs = try BSConverter.toBS(ad)
            let back = try BSConverter.toAD(bs)
            check(ad == back, "AD round-trip \(y)-\(m)-\(d)")
        }
    }
}

func testMonthLengthsTotals() {
    for y in 1975...2099 {
        let row = BSData.years[y - 1975]
        let summed = row.prefix(12).reduce(0, +)
        check(summed == row[12], "year \(y) sum \(summed) != total \(row[12])")
    }
}

func testWeekday() {
    check(BSConverter.weekday(BSDate(year: 1975, month: 1, day: 1)) == 7,
          "1 Baisakh 1975 should be Saturday")
}

func testNepaliDigits() {
    check(NepaliFormatter.toNepaliDigits(2082) == "२०८२", "2082 -> Devanagari")
    check(NepaliFormatter.toNepaliDigits(0) == "०", "0 -> Devanagari")
    check(NepaliFormatter.toNepaliDigits(123456789) == "१२३४५६७८९", "long -> Devanagari")
}

print("Running NepaliCalendar verification…")

do {
    try testEpoch()
    try testConstitutionDay()
    try testNewYear2080()
    try testRoundTripAllMonthStarts()
    try testRoundTripADRange()
    testMonthLengthsTotals()
    testWeekday()
    testNepaliDigits()
} catch {
    FileHandle.standardError.write(Data("Threw: \(error)\n".utf8))
    failures += 1
}

if failures == 0 {
    print("OK  \(checks) checks passed.")
    exit(0)
} else {
    print("FAIL  \(failures) of \(checks) checks failed.")
    exit(1)
}
