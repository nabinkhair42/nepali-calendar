import SwiftUI
import BSCore

/// Compact label that sits in the menu bar. Just the BS month and day —
/// e.g. `बैशाख २६` or `Baisakh 26`. Time and AD secondary info live in
/// the popover, never the bar.
///
/// Observes `AppState` directly via `@ObservedObject` instead of taking
/// values like `today: BSDate` from the Scene closure. Why: SwiftUI's
/// MenuBarExtra has a known bug (FB13683957 / forums thread 720625)
/// where the label closure does not reliably re-render when an
/// App-scene-level @StateObject mutates — symptoms: the BS day appears
/// stuck until app relaunch, even though the model updated. Letting the
/// label View own the observation forces the redraw at the View layer,
/// which works.
struct MenuBarLabel: View {
    @ObservedObject var state: AppState

    var body: some View {
        Text(NepaliFormatter.menuBarLabel(state.today, locale: state.localeMode))
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .monospacedDigit()
    }
}
