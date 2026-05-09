import SwiftUI
import BSCore

struct MenuBarLabelView: View {
    let today: BSDate
    let locale: Locale_

    var body: some View {
        Text(NepaliFormatter.menuBarLabel(today, locale: locale))
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .monospacedDigit()
    }
}
