import Foundation

/// A named entry on the Nepali calendar — public holiday, religious
/// observance, regional cultural day, etc. Multiple festivals can fall on
/// the same date (e.g., Buddha Jayanti + Labour Day on Baisakh 18 2083).
public struct Festival: Equatable, Hashable, Codable, Sendable {
    public enum Category: String, Codable, Sendable {
        /// Nationwide public holiday.
        case national
        /// Limited to a region or community (Kathmandu Valley, Newar, etc.).
        case regional
        /// Religious observance — may or may not be a public holiday.
        case religious
        /// Cultural/community day.
        case cultural
        /// Internationally recognized day.
        case international
    }

    public let nameEN: String
    public let nameNE: String
    public let category: Category
    /// True when public offices and schools are closed.
    public let isHoliday: Bool

    public init(nameEN: String, nameNE: String, category: Category, isHoliday: Bool) {
        self.nameEN = nameEN
        self.nameNE = nameNE
        self.category = category
        self.isHoliday = isHoliday
    }

    public func name(locale: Locale_) -> String {
        locale == .nepali ? nameNE : nameEN
    }
}
