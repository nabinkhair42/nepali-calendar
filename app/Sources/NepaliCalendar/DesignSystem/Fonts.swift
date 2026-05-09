import SwiftUI

// Typography scale.
//
// Headers (display, title) use SF Pro default for an editorial feel —
// rounded was reading too "soft" at large sizes. Numerals stay on the
// rounded face so Devanagari and Latin digits visually balance inside
// the 52×52 day cells.
//
// `displayNumeral` and `titleNumeral` are intended to use the bundled
// Tiro Devanagari Hindi face once the TTF lands in Resources/Fonts.
// `uiText` slots are intended for Mukta. For now we fall back to the
// system faces so the layout is correct; switch to
// `Font.custom("…", size: …)` after the fonts are bundled.

extension Font {
    /// 28pt bold — month title (e.g., "Baisakh 2083"). Tight tracking
    /// applied at the call site for editorial feel.
    static let display = Font.system(size: 28, weight: .bold, design: .default)
    /// 19pt semibold — selected-day weekday, large numerals in panels.
    static let title = Font.system(size: 19, weight: .semibold, design: .default)
    /// 14pt — body copy in the selected-day panel.
    static let bodyText = Font.system(size: 14, weight: .regular)
    /// 13pt medium — labels, weekday header, festival names.
    static let label = Font.system(size: 13, weight: .medium)
    /// 11pt — captions, hints, secondary metadata.
    static let caption = Font.system(size: 11, weight: .regular)

    /// Cell BS numeral — rounded design keeps Devanagari and Latin digits
    /// in the same optical family. Regular weight reads cleanest at 18pt.
    static let cellNumeral = Font.system(size: 18, weight: .regular, design: .rounded)
    /// Cell AD subscript — bumped to medium so it reads as a paired
    /// secondary digit, not an afterthought.
    static let cellSubNumeral = Font.system(size: 11, weight: .medium, design: .rounded)
}
