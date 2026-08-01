import SwiftUI

extension Color {
    static let fgPrimary   = Color.primary
    static let fgSecondary = Color.secondary
    static let fgWeekend   = Color(hex: 0xFF6B6B).opacity(0.7)

    static let accentToday        = Color(hex: 0xFF453A)
    static let accentSelected     = Color(hex: 0x0A84FF)
    static let accentSelectedFill   = Color.primary.opacity(0.10)
    static let accentHoliday      = Color(hex: 0xFF9F0A)
    static let accentSaait          = Color(hex: 0x30D158).opacity(0.3)
    static let accentSuccess      = Color(hex: 0x30D158)

    static let dividerSubtle  = Color.primary.opacity(0.08)
    static let surfaceElevated = Color.primary.opacity(0.05)
    static let surfaceHover   = Color.primary.opacity(0.07)
    static let surfacePressed = Color.primary.opacity(0.12)

    static let opacityMuted   = Color.primary.opacity(0.45)
    static let opacitySubtle  = Color.primary.opacity(0.55)
    static let opacityFaint   = Color.primary.opacity(0.40)

    fileprivate init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
