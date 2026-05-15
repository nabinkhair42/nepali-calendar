import SwiftUI

// Semantic color tokens. Never reference raw hex from a view —
// always go through these. Spec values from the v2 brief.
//
// Foreground tokens use SwiftUI's `.primary` / `.secondary` so they
// adapt to light and dark mode automatically; the popover sits on
// `.ultraThinMaterial` (dark-mode primary) and these resolve correctly
// on both surfaces.
//
// Accent values are the saturated Apple system-intent colors and are
// stable across modes by design.

extension Color {
    // MARK: Foreground
    static let fgPrimary   = Color.primary
    static let fgSecondary = Color.secondary
    /// Muted weekend hue — distinct from `accentToday` so weekends
    /// don't read as alerts. (#FF6B6B @ 70% opacity)
    static let fgWeekend   = Color(hex: 0xFF6B6B).opacity(0.7)

    // MARK: Accents
    /// Today's-cell ring. (#FF453A)
    static let accentToday    = Color(hex: 0xFF453A)
    /// Saturated selected accent — used for festival/region tints, not the
    /// day-cell pill. The cell pill uses `accentSelectedFill` so it doesn't
    /// scream on a translucent surface. (#0A84FF)
    static let accentSelected = Color(hex: 0x0A84FF)
    /// Neutral selected-day pill. Deliberately not chromatic — leaves the
    /// color budget of the cell to the `accentToday` red numeral and the
    /// festival/saait dots, which would otherwise compete with a blue/green
    /// fill. Reads as "this is the focused day" rather than a category tint.
    static let accentSelectedFill = Color.primary.opacity(0.10)
    /// Holiday/festival dot, top-right of cell. (#FF9F0A)
    static let accentHoliday  = Color(hex: 0xFF9F0A)
    /// Saait (auspicious moment) dot, bottom-right of cell. (#30D158 @ 30%)
    static let accentSaait    = Color(hex: 0x30D158).opacity(0.3)

    // MARK: Surfaces
    /// Hairline divider — subtle on both light/dark surfaces.
    static let dividerSubtle = Color.primary.opacity(0.08)

    // MARK: - Hex helper
    /// `Color(hex: 0xFF453A)` — internal to this file.
    fileprivate init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
