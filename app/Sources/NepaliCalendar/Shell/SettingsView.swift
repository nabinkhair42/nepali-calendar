import SwiftUI
import AppKit
import BSCore

struct SettingsView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var updateChecker: UpdateChecker
    @EnvironmentObject var installation: InstallationManager
    @StateObject private var loginManager = LaunchAtLoginManager.shared
    let onClose: () -> Void

    private let shortcutRows: [(label: String, keys: [String])] = [
        ("Previous month",  ["⌘", "←"]),
        ("Next month",      ["⌘", "→"]),
        ("Jump to today",   ["⌘", "T"]),
        ("Toggle language", ["⌘", "L"]),
        ("Quit",            ["⌘", "Q"]),
    ]

    private var versionString: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(v) (\(b))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Divider().overlay(Color.dividerSubtle)

            VStack(alignment: .leading, spacing: 18) {
                languageSection
                generalSection
                if !installation.duplicates.isEmpty {
                    duplicatesSection
                }
                shortcutsSection
                aboutSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            Divider().overlay(Color.dividerSubtle)

            footer
        }
        .onAppear { loginManager.refresh() }
    }

    private var header: some View {
        HStack(spacing: 8) {
            BackButton(action: onClose)
                .keyboardShortcut(.escape, modifiers: [])
                .help("Back to calendar · Esc")

            Text("Settings")
                .font(.heading)
                .headingStyle()
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle("Language")
            LanguageSegmented(value: state.localeMode) { newValue in
                if newValue != state.localeMode { state.toggleLocale() }
            }
        }
    }

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionTitle("General")
            SwitchRow(
                title: "Open at login",
                subtitle: "Start Nepali Calendar automatically when you sign in.",
                isOn: loginManager.isEnabled,
                onToggle: { loginManager.toggle() }
            )
            SwitchRow(
                title: "Automatically check for updates",
                subtitle: "Look for new releases on launch and every few hours.",
                isOn: updateChecker.automaticChecksEnabled,
                onToggle: { updateChecker.automaticChecksEnabled.toggle() }
            )
        }
    }

    private var duplicatesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionTitle("Installation")
            VStack(alignment: .leading, spacing: 8) {
                Text(installation.duplicates.count == 1
                     ? "Found another copy of Nepali Calendar on this Mac."
                     : "Found \(installation.duplicates.count) other copies of Nepali Calendar on this Mac.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(installation.duplicates, id: \.self) { url in
                    DuplicateRow(url: url) {
                        installation.removeDuplicate(at: url)
                    }
                }

                if let error = installation.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color.accentHoliday)
                        .padding(.top, 2)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: Metrics.radiusCard, style: .continuous)
                    .fill(Color.surfaceElevated)
            )
            .cardShadow()
        }
    }

    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionTitle("Shortcuts")
            VStack(spacing: 0) {
                ForEach(shortcutRows.indices, id: \.self) { i in
                    HStack {
                        Text(shortcutRows[i].label)
                            .font(.button)
                            .foregroundStyle(.primary)
                        Spacer()
                        HStack(spacing: 3) {
                            ForEach(shortcutRows[i].keys, id: \.self) { key in
                                KeyCap(text: key)
                            }
                        }
                    }
                    .padding(.vertical, 7)
                    if i < shortcutRows.count - 1 {
                        Divider().overlay(Color.dividerSubtle)
                    }
                }
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionTitle("About")
            Text("Nepali Calendar")
                .font(.button.weight(.semibold))
            Text("Version \(versionString)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var footer: some View {
        HStack {
            Spacer()
            QuitButton()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

private struct SectionTitle: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.badge)
            .foregroundStyle(.secondary)
    }
}

private struct SwitchRow: View {
    let title: String
    let subtitle: String?
    let isOn: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.button)
                if let sub = subtitle {
                    Text(sub)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.small)
        }
        .padding(.vertical, 6)
    }
}

private struct KeyCap: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.badge)
            .frame(minWidth: 20, minHeight: 20)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.surfaceHover)
            )
            .cardShadow()
            .foregroundStyle(.primary)
    }
}

private struct LanguageSegmented: View {
    let value: Locale_
    let onChange: (Locale_) -> Void

    var body: some View {
        HStack(spacing: 0) {
            segment(label: "नेपाली", isSelected: value == .nepali) { onChange(.nepali) }
            segment(label: "English", isSelected: value == .english) { onChange(.english) }
        }
        .background(
            RoundedRectangle(cornerRadius: Metrics.radiusCard, style: .continuous)
                .fill(Color.surfaceElevated)
        )
        .cardShadow()
    }

    private func segment(label: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            Text(label)
                .font(isSelected ? .button.weight(.semibold) : .button)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: Metrics.radiusControl, style: .continuous)
                        .fill(isSelected ? Color.surfacePressed : Color.clear)
                        .padding(2)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(ToolbarButtonStyle())
    }
}

private struct DuplicateRow: View {
    let url: URL
    let onTrash: () -> Void
    @State private var hovered = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.on.doc")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 14)
            VStack(alignment: .leading, spacing: 1) {
                Text(url.lastPathComponent)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(url.deletingLastPathComponent().path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer(minLength: 6)
            Button(action: onTrash) {
                Text("Move to Trash")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(hovered ? Color.accentHoliday : Color.fgSecondary)
                    .padding(.horizontal, 8)
                    .frame(minHeight: Metrics.hitAreaMin)
                    .background(
                        RoundedRectangle(cornerRadius: Metrics.radiusControl, style: .continuous)
                            .fill(hovered ? Color.accentHoliday.opacity(0.10) : Color.surfaceHover)
                    )
                    .contentShape(Rectangle())
                    .animation(.easeOut(duration: 0.12), value: hovered)
            }
            .buttonStyle(ToolbarButtonStyle())
            .onHover { hovered = $0 }
            .help("Move \(url.path) to Trash")
        }
    }
}

private struct BackButton: View {
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.button)
                .foregroundStyle(hovered ? Color.fgPrimary : Color.fgSecondary)
                .frame(width: Metrics.hitAreaMin, height: Metrics.hitAreaMin)
                .background(
                    RoundedRectangle(cornerRadius: Metrics.radiusControl, style: .continuous)
                        .fill(hovered ? Color.surfaceHover : Color.clear)
                )
                .contentShape(Rectangle())
                .animation(.easeOut(duration: 0.12), value: hovered)
        }
        .buttonStyle(ToolbarButtonStyle())
        .onHover { hovered = $0 }
    }
}

private struct QuitButton: View {
    @State private var hovered = false

    var body: some View {
        Button {
            NSApp.terminate(nil)
        } label: {
            Text("Quit")
                .font(.button)
                .foregroundStyle(hovered ? Color.fgPrimary : Color.fgSecondary)
                .padding(.horizontal, 12)
                .frame(minWidth: Metrics.hitAreaMin, minHeight: Metrics.hitAreaMin)
                .background(
                    RoundedRectangle(cornerRadius: Metrics.radiusControl + 1, style: .continuous)
                        .fill(hovered ? Color.surfaceHover : Color.clear)
                )
                .contentShape(Rectangle())
                .animation(.easeOut(duration: 0.12), value: hovered)
        }
        .buttonStyle(ToolbarButtonStyle())
        .onHover { hovered = $0 }
        .help("Quit Nepali Calendar · ⌘Q")
    }
}
