import SwiftUI

extension Font {
    static let display   = Font.system(size: 28, weight: .bold, design: .default)
    static let title     = Font.system(size: 19, weight: .semibold, design: .default)
    static let bodyText  = Font.system(size: 14, weight: .regular)
    static let label     = Font.system(size: 13, weight: .medium)
    static let caption   = Font.system(size: 11, weight: .regular)

    static let heading   = Font.system(size: 14, weight: .semibold)
    static let button    = Font.system(size: 12, weight: .medium)
    static let badge     = Font.system(size: 11, weight: .semibold)
    static let menuBar   = Font.system(size: 13, weight: .medium, design: .rounded)

    static let cellNumeral    = Font.system(size: 18, weight: .regular, design: .rounded)
    static let cellSubNumeral = Font.system(size: 11, weight: .medium, design: .rounded)

    static func cellNumeral(isToday: Bool) -> Font {
        isToday
            ? Font.system(size: 18, weight: .semibold, design: .rounded)
            : .cellNumeral
    }
}

extension View {
    func headingStyle() -> some View {
        tracking(-0.3)
    }

    func labelStyle() -> some View {
        tracking(0.4)
    }
}
