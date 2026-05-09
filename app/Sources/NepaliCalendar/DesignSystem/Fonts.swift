import SwiftUI

// Typography scale per v2 spec.
//
// `displayNumeral` and `titleNumeral` are intended to use the bundled
// Tiro Devanagari Hindi face once the TTF lands in Resources/Fonts.
// `uiText` slots are intended for Mukta. For now we fall back to the
// system rounded design so the layout is correct; switch to
// `Font.custom("…", size: …)` after the fonts are bundled and registered
// in `Info.plist` (`ATSApplicationFontsPath = Fonts`).

extension Font {
    /// 32pt — month title numerals (e.g., "बैशाख २०८३").
    static let display = Font.system(size: 32, weight: .regular, design: .rounded)
    /// 22pt — section headers, BS day in detail panel.
    static let title = Font.system(size: 22, weight: .semibold, design: .rounded)
    /// 16pt — body copy in detail panel.
    static let bodyText = Font.system(size: 16, weight: .regular)
    /// 13pt — labels, weekday header.
    static let label = Font.system(size: 13, weight: .medium)
    /// 11pt — captions, AD numerals beneath BS, accessibility hints.
    static let caption = Font.system(size: 11, weight: .regular)

    /// Cell BS numeral — tuned to render Devanagari and Latin numerals
    /// with similar visual weight inside a 52×52 cell.
    static let cellNumeral = Font.system(size: 17, weight: .medium, design: .rounded)
    /// Cell AD subscript.
    static let cellSubNumeral = Font.system(size: 10, weight: .regular, design: .rounded)
}
