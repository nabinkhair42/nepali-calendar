import SwiftUI
import BSCore

struct MenuBarLabel: View {
    @ObservedObject var state: AppState

    var body: some View {
        Text(NepaliFormatter.menuBarLabel(state.today, locale: state.localeMode))
            .font(.menuBar)
            .monospacedDigit()
    }
}
