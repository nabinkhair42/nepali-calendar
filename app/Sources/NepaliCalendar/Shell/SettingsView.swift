import SwiftUI
import AppKit
import BSCore

/// Single settings panel — owns language, login behavior, the keyboard-
/// shortcuts cheatsheet, and about/quit. Replaces the popover's calendar
/// content in-place; the back button (or Esc, or ⌘,) returns to the calendar.
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

            Divider().opacity(0.18)

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

            Divider().opacity(0.18)

            footer
        }
        .onAppear { loginManager.refresh() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 8) {
            BackButton(action: onClose)
                .keyboardShortcut(.escape, modifiers: [])
                .help("Back to calendar · Esc")

            Text("Settings")
                .font(.system(size: 14, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    // MARK: - Sections

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

    /// Appears only when a second copy of the app exists on disk. The
    /// auto-updater only knows how to replace the currently-running bundle,
    /// so any other install paths (manual drag-installs, leftover dev
    /// builds, etc.) survive forever and show up alongside the real app
    /// in Spotlight/Launchpad. This section lets the user clean them out.
    private var duplicatesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionTitle("Installation")
            VStack(alignment: .leading, spacing: 8) {
                Text(installation.duplicates.count == 1
                     ? "Found another copy of Nepali Calendar on this Mac."
                     : "Found \(installation.duplicates.count) other copies of Nepali Calendar on this Mac.")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(installation.duplicates, id: \.self) { url in
                    DuplicateRow(url: url) {
                        installation.removeDuplicate(at: url)
                    }
                }

                if let error = installation.lastError {
                    Text(error)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.accentHoliday)
                        .padding(.top, 2)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
            )
        }
    }

    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionTitle("Shortcuts")
            VStack(spacing: 0) {
                ForEach(shortcutRows.indices, id: \.self) { i in
                    HStack {
                        Text(shortcutRows[i].label)
                            .font(.system(size: 12))
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
                        Divider().opacity(0.10)
                    }
                }
            }
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionTitle("About")
            Text("Nepali Calendar")
                .font(.system(size: 12, weight: .semibold))
            Text("Version \(versionString)")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Spacer()
            QuitButton()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

// MARK: - Pieces

private struct SectionTitle: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
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
                    .font(.system(size: 12, weight: .medium))
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 11))
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
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .frame(minWidth: 20, minHeight: 20)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.primary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.10), lineWidth: 0.5)
            )
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
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
    }

    private func segment(label: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            Text(label)
                .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(isSelected ? Color.primary.opacity(0.12) : Color.clear)
                        .padding(2)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct DuplicateRow: View {
    let url: URL
    let onTrash: () -> Void
    @State private var hovered = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.on.doc")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.secondary)
                .frame(width: 14)
            VStack(alignment: .leading, spacing: 1) {
                Text(url.lastPathComponent)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(url.deletingLastPathComponent().path)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer(minLength: 6)
            Button(action: onTrash) {
                Text("Move to Trash")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(hovered ? Color.accentHoliday : Color.fgSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(hovered ? Color.accentHoliday.opacity(0.10) : Color.primary.opacity(0.05))
                    )
                    .contentShape(Rectangle())
                    .animation(.easeOut(duration: 0.12), value: hovered)
            }
            .buttonStyle(.plain)
            .onHover { hovered = $0 }
            .help("Move \(url.path) to Trash")
        }
    }
}

/// Back-to-calendar arrow used in the Settings header. Flat at rest, soft
/// hover; matches the macOS toolbar-button idiom.
private struct BackButton: View {
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(hovered ? Color.fgPrimary : Color.fgSecondary)
                .frame(width: 26, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(hovered ? Color.primary.opacity(0.08) : Color.clear)
                )
                .contentShape(Rectangle())
                .animation(.easeOut(duration: 0.12), value: hovered)
        }
        .buttonStyle(.plain)
    }
}

/// Quit action shown bottom-right of Settings. Matches the rest of the
/// app's toolbar-button idiom — flat at rest, neutral soft hover. The ⌘Q
/// shortcut is documented in the Shortcuts list above and in the tooltip.
private struct QuitButton: View {
    @State private var hovered = false

    var body: some View {
        Button {
            NSApp.terminate(nil)
        } label: {
            Text("Quit")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(hovered ? Color.fgPrimary : Color.fgSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(hovered ? Color.primary.opacity(0.08) : Color.clear)
                )
                .contentShape(Rectangle())
                .animation(.easeOut(duration: 0.12), value: hovered)
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
        .help("Quit Nepali Calendar · ⌘Q")
    }
}
