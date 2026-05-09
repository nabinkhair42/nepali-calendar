import SwiftUI
import AppKit
import BSCore

/// Single settings panel — owns language, login behavior, the keyboard-
/// shortcuts cheatsheet, and about/quit. Replaces the popover's calendar
/// content in-place; the back button (or Esc, or ⌘,) returns to the calendar.
struct SettingsView: View {
    @EnvironmentObject var state: AppState
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
            Button(action: onClose) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.primary.opacity(0.07))
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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

private struct QuitButton: View {
    @State private var hovered = false

    var body: some View {
        Button {
            NSApp.terminate(nil)
        } label: {
            HStack(spacing: 6) {
                Text("Quit")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(hovered ? Color.accentHoliday : Color.primary)
                HStack(spacing: 3) {
                    KeyCap(text: "⌘")
                    KeyCap(text: "Q")
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(hovered
                          ? Color.accentHoliday.opacity(0.10)
                          : Color.primary.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(
                        hovered ? Color.accentHoliday.opacity(0.30) : Color.primary.opacity(0.08),
                        lineWidth: 0.5
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}
