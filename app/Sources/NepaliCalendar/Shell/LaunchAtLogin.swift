import Foundation
import ServiceManagement

/// Tracks and toggles the macOS "open at login" state via SMAppService —
/// the framework Apple introduced in macOS 13 that replaced the old login
/// items database. The status comes straight from the system, so it stays
/// in sync if the user disables the login item from System Settings.
@MainActor
final class LaunchAtLoginManager: ObservableObject {
    static let shared = LaunchAtLoginManager()

    @Published private(set) var isEnabled: Bool

    private init() {
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }

    /// Flip the registration state. Best-effort: errors leave us in the
    /// last-known state and the next refresh corrects the published value.
    func toggle() {
        do {
            if isEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSLog("LaunchAtLogin toggle failed: \(error.localizedDescription)")
        }
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    /// Re-read system state. Useful when the popover opens, in case the
    /// user toggled the login item externally.
    func refresh() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }
}
