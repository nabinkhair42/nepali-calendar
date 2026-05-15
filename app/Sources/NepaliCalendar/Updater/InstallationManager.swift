import Foundation
import AppKit

/// Detects other installed copies of this app by bundle identifier and
/// surfaces them in Settings so the user can remove duplicates.
///
/// Why this exists: the auto-updater swaps the running bundle in place at
/// `Bundle.main.bundlePath`. Any other copies installed at different paths
/// (e.g. dragged manually after the auto-installed one already lived in
/// /Applications, or a stale dev build at a different filename) are
/// untouched by updates and show up alongside the real install in Spotlight,
/// Launchpad, and "Open With" menus.
///
/// We don't delete anything automatically. The manager publishes a list of
/// duplicate URLs; the Settings UI shows them and lets the user move each
/// one to Trash via `NSWorkspace.recycle`.
@MainActor
final class InstallationManager: ObservableObject {
    @Published private(set) var duplicates: [URL] = []
    @Published private(set) var lastError: String?

    private let bundleIdentifier: String

    init(bundleIdentifier: String? = Bundle.main.bundleIdentifier) {
        self.bundleIdentifier = bundleIdentifier ?? ""
    }

    /// Recompute the duplicate list. Safe to call repeatedly; cheap because
    /// LaunchServices answers from its in-memory database.
    func scan() {
        guard !bundleIdentifier.isEmpty else {
            duplicates = []
            return
        }

        let allURLs = NSWorkspace.shared.urlsForApplications(withBundleIdentifier: bundleIdentifier)
        let ours = Bundle.main.bundleURL.resolvingSymlinksInPath().standardizedFileURL

        duplicates = allURLs
            .map { $0.resolvingSymlinksInPath().standardizedFileURL }
            .filter { $0 != ours }
            .uniqued()
    }

    /// Move a single duplicate copy to the Trash. After it lands in Trash,
    /// re-scan so the UI updates.
    func removeDuplicate(at url: URL) {
        NSWorkspace.shared.recycle([url]) { [weak self] _, error in
            Task { @MainActor in
                guard let self else { return }
                if let error = error {
                    self.lastError = error.localizedDescription
                } else {
                    self.lastError = nil
                }
                self.scan()
            }
        }
    }

    /// Move all detected duplicates to the Trash in one shot.
    func removeAllDuplicates() {
        guard !duplicates.isEmpty else { return }
        NSWorkspace.shared.recycle(duplicates) { [weak self] _, error in
            Task { @MainActor in
                guard let self else { return }
                if let error = error {
                    self.lastError = error.localizedDescription
                } else {
                    self.lastError = nil
                }
                self.scan()
            }
        }
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
