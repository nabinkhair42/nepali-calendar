import SwiftUI
import AppKit
import BSCore

struct PopoverRootView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            PopoverHeader()
            Divider().opacity(0.25)
            MonthGridView()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            Divider().opacity(0.25)
            PopoverFooter()
        }
        .background(.ultraThinMaterial)
        .preferredColorScheme(nil)
    }
}

struct PopoverHeader: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(NepaliFormatter.headerLabel(state.viewing, locale: state.localeMode))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(NepaliFormatter.adSubtitle(forBSMonth: state.viewing))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            HStack(spacing: 2) {
                NavButton(system: "chevron.left") { state.goPrev() }
                NavButton(system: "circle.fill", small: true) { state.goToday() }
                    .help("Jump to today")
                NavButton(system: "chevron.right") { state.goNext() }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }
}

private struct NavButton: View {
    let system: String
    var small: Bool = false
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: small ? 7 : 11, weight: .semibold))
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(hovered ? Color.primary.opacity(0.10) : Color.clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}

struct PopoverFooter: View {
    @EnvironmentObject var state: AppState

    private var todayADString: String {
        guard let ad = try? BSConverter.toAD(state.today) else { return "" }
        let f = DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "EEEE, MMM d, yyyy"
        return f.string(from: ad)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(todayADString)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Spacer()
            Button {
                state.toggleLocale()
            } label: {
                Text(state.localeMode == .english ? "EN" : "ने")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .frame(minWidth: 26, minHeight: 20)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.primary.opacity(0.07))
                    )
            }
            .buttonStyle(.plain)
            .help("Toggle script")

            Button {
                NSApp.terminate(nil)
            } label: {
                Image(systemName: "power")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 24, height: 22)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.primary.opacity(0.07))
                    )
            }
            .buttonStyle(.plain)
            .help("Quit Nepali Calendar")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
