import Foundation

public struct BSDate: Equatable, Hashable, Codable, Sendable {
    public var year: Int
    public var month: Int
    public var day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public func isValid() -> Bool {
        guard let lengths = BSData.monthLengths(forYear: year) else { return false }
        guard (1...12).contains(month) else { return false }
        return (1...lengths[month - 1]).contains(day)
    }

    public func startOfMonth() -> BSDate { BSDate(year: year, month: month, day: 1) }

    public func daysInMonth() -> Int? {
        BSData.monthLengths(forYear: year).map { $0[month - 1] }
    }

    public func adding(months delta: Int) -> BSDate {
        let total = year * 12 + (month - 1) + delta
        let newYear = total / 12
        let newMonth = total % 12 + 1
        let lengths = BSData.monthLengths(forYear: newYear) ?? Array(repeating: 30, count: 12)
        let clampedDay = min(day, lengths[newMonth - 1])
        return BSDate(year: newYear, month: newMonth, day: clampedDay)
    }
}
