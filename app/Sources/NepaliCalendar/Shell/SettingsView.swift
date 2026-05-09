import SwiftUI
import AppKit
import BSCore

/// Single settings panel — owns language, the keyboard-shortcuts cheatsheet,
/// and about/quit. Replaces the popover's calendar content in-place; the X
/// button (or Esc, or ⌘,) returns to the calendar.
struct SettingsView: View {
    @EnvironmentObject var state: AppState
    let onClose: () -> Void

    private let shortcutRows: [(label: String, keys: [String])] = [
        ("Previous month",      ["⌘", "←"]),
        ("Next month",          ["⌘", "→"]),
        ("Jump to today",       ["⌘", "T"]),
        ("Toggle language",     ["⌘", "L"]),
        ("Show settings",       ["⌘", ","]),
        ("Quit",                ["⌘", "Q"]),
    ]

    private var versionString: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(v) (\(b))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Divider().opacity(0.2)

            VStack(alignment: .leading, spacing: 16) {
                languageSection
                shortcutsSection
                aboutSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider().opacity(0.2)

            footer
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 15, weight: .semibold))
            Spacer()
            Button(action: onClose) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 22, height: 22)
                    .background(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Color.primary.opacity(0.07))
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.escape, modifiers: [])
            .help("Back to calendar · Esc")
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
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

    private var shortcutsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                    .padding(.vertical, 5)
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

    private var footer: some View {
        HStack {
            Spacer()
            Button {
                NSApp.terminate(nil)
            } label: {
                HStack(spacing: 6) {
                    Text("Quit")
                        .font(.system(size: 12, weight: .medium))
                    HStack(spacing: 3) {
                        KeyCap(text: "⌘")
                        KeyCap(text: "Q")
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.primary.opacity(0.07))
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Pieces

private struct SectionTitle: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

private struct KeyCap: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .frame(minWidth: 18, minHeight: 18)
            .padding(.horizontal, 3)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.primary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
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
                        .fill(isSelected ? Color.primary.opacity(0.10) : Color.clear)
                        .padding(2)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
