import SwiftUI
import BSCore

/// Compact label that sits in the menu bar. Just the BS month and day —
/// e.g. `बैशाख २६` or `Baisakh 26`. Time and AD secondary info live in
/// the popover, never the bar.
struct MenuBarLabel: View {
    let today: BSDate
    let locale: Locale_

    var body: some View {
        Text(NepaliFormatter.menuBarLabel(today, locale: locale))
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .monospacedDigit()
    }
}
