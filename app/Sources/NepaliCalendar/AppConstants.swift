import Foundation

/// App-identity constants. Keep these in sync with `release.config` at the
/// repo root (the shell-side source of truth) and `web/src/lib/app-constants.ts`
/// (the TS-side mirror). Any change here should land in all three.
///
/// Per-release values (version, build) are NOT here — those come from the
/// Info.plist that release.sh assembles into the .app bundle.
enum AppConstants {
    /// Bundle/folder name — must match the `name` in Package.swift's
    /// executableTarget and the .app folder produced by build.sh.
    static let bundleName = "NepaliCalendar"

    /// Human-facing name — must match Info.plist CFBundleDisplayName.
    static let displayName = "Nepali Calendar"

    /// macOS bundle identifier — must match Info.plist CFBundleIdentifier.
    static let bundleIdentifier = "app.nabinkhair.NepaliCalendar"

    /// Public website hostname (no scheme).
    static let websiteHost = "calendar.nabinkhair.com.np"

    /// GitHub repo in owner/name form.
    static let githubRepo = "nabinkhair42/nepali-calendar"

    // MARK: - Derived URLs

    static let websiteURL = URL(string: "https://\(websiteHost)")!
    static let manifestURL = URL(string: "https://\(websiteHost)/downloads/latest.json")!
    static let updateAPIURL = URL(string: "https://\(websiteHost)/api/app/update")!
    static let downloadURL = URL(string: "https://\(websiteHost)/downloads/\(bundleName).dmg")!
    static let githubReleasesURL = URL(string: "https://github.com/\(githubRepo)/releases")!
}
