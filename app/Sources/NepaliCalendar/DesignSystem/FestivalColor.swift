import SwiftUI
import BSCore

/// View-side color mapping for festival dot indicators. Lives in
/// DesignSystem so BSCore stays UI-free.
extension Festival.Category {
    /// Color for the bottom-row observance dot in a `DayCell`.
    /// Holiday entries take precedence and render as the top-right
    /// amber dot via `accentHoliday`; this mapping covers the
    /// non-holiday side.
    var observanceDotColor: Color {
        switch self {
        case .national, .religious: return .accentHoliday.opacity(0.55)
        case .regional:             return .accentSelected.opacity(0.6)
        case .cultural:             return .accentSaait
        case .international:        return Color.fgPrimary.opacity(0.45)
        }
    }
}
