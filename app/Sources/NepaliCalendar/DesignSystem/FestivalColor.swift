import SwiftUI
import BSCore
extension Festival.Category {
    var observanceDotColor: Color {
        switch self {
        case .national, .religious: return .accentHoliday.opacity(0.55)
        case .regional:             return .accentSelected.opacity(0.6)
        case .cultural:             return .accentSaait
        case .international:        return .opacityMuted
        }
    }
}
