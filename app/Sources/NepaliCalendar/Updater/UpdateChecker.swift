import Foundation
import SwiftUI
import AppKit

/// Drives the in-app update lifecycle: periodic manifest fetch, version
/// comparison, and on user confirmation the download + install flow.
///
/// State machine (mutually exclusive):
///   .idle              → app just launched, nothing checked yet
///   .checking          → manifest fetch in flight
///   .upToDate          → manifest fetched, our version is >= remote
///   .available(m)      → newer version is published, banner should appear
///   .downloading(p)    → user clicked Update, DMG is being pulled (p = 0...1)
///   .installing        → checksum + mount + swap helper running
///   .failed(message)   → most recent check or install errored out
@MainActor
final class UpdateChecker: ObservableObject {
    enum State: Equatable {
        case idle
        case checking
        case upToDate
        case available(UpdateManifest)
        case downloading(Double)
        case installing
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    /// User-facing toggle in Settings. `true` by default; persisted to
    /// UserDefaults. When `false` we still allow a manual "Check Now" but
    /// skip the launch + interval-driven checks.
    @Published var automaticChecksEnabled: Bool {
        didSet {
            UserDefaults.standard.set(automaticChecksEnabled, forKey: Self.autoCheckDefaultsKey)
            if automaticChecksEnabled {
                rescheduleTimer()
                Task { await checkForUpdates(userInitiated: false) }
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }

    private static let autoCheckDefaultsKey = "autoUpdateChecksEnabled"
    private static let checkInterval: TimeInterval = 6 * 60 * 60  // 6 hours

    /// Primary endpoint: returns the manifest plus a server-computed
    /// `updateAvailable` flag against the caller's currentVersion/Build.
    private static let feedURL = URL(string: "https://calendar.nabinkhair.com.np/api/app/update")!

    /// Fallback: the static manifest produced by `release.sh`. Used when the
    /// API endpoint isn't deployed yet, or returns a transient 5xx. Decodes
    /// into the same struct (server-only fields are optional).
    private static let fallbackFeedURL = URL(string: "https://calendar.nabinkhair.com.np/downloads/latest.json")!

    private var timer: Timer?
    private var inflight: Task<Void, Never>?

    init() {
        if UserDefaults.standard.object(forKey: Self.autoCheckDefaultsKey) == nil {
            self.automaticChecksEnabled = true
            UserDefaults.standard.set(true, forKey: Self.autoCheckDefaultsKey)
        } else {
            self.automaticChecksEnabled = UserDefaults.standard.bool(forKey: Self.autoCheckDefaultsKey)
        }
    }

    /// Call once after launch. Kicks off an immediate check (if enabled) and
    /// arms a recurring timer so a Mac left running for days still notices
    /// new releases.
    func start() {
        guard automaticChecksEnabled else { return }
        rescheduleTimer()
        Task { await checkForUpdates(userInitiated: false) }
    }

    /// Dismiss the current banner. Doesn't persist — the next check will
    /// re-surface the same version. Per the chosen UX we didn't add a
    /// "skip this version" memo.
    func dismiss() {
        if case .available = state {
            state = .upToDate
        }
    }

    /// Trigger the install path for the currently-known available update.
    /// No-op if state isn't `.available`.
    func installAvailableUpdate() {
        guard case .available(let manifest) = state else { return }
        inflight?.cancel()
        state = .downloading(0)
        inflight = Task { [weak self] in
            guard let self else { return }
            do {
                try await UpdateInstaller.install(manifest: manifest) { [weak self] p in
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        if case .downloading = self.state {
                            self.state = .downloading(p)
                        }
                    }
                }
                self.state = .installing
            } catch is CancellationError {
                self.state = .available(manifest)
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }

    /// Fetch the manifest, compare to our bundle, and update `state`.
    /// `userInitiated == true` reports `.upToDate` / `.failed` more eagerly;
    /// background checks try to stay quiet unless there's news.
    func checkForUpdates(userInitiated: Bool) async {
        if case .downloading = state { return }
        if case .installing = state { return }

        state = .checking

        let (currentVersion, currentBuild) = Self.currentVersionAndBuild()

        var components = URLComponents(url: Self.feedURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "currentVersion", value: currentVersion),
            URLQueryItem(name: "currentBuild", value: currentBuild),
        ]
        guard let url = components?.url else {
            state = userInitiated ? .failed("invalid feed URL") : .idle
            return
        }

        do {
            let manifest = try await fetchManifest(primary: url)

            let serverSaysUpdate = manifest.updateAvailable ?? false
            let localComparison = Version.compare(currentVersion, manifest.version) < 0
            if serverSaysUpdate || localComparison {
                state = .available(manifest)
            } else {
                state = .upToDate
            }
        } catch {
            state = userInitiated ? .failed(error.localizedDescription) : .idle
        }
    }

    /// Try the API endpoint first, fall back to the static manifest on 404/5xx
    /// or any networking error so users on pre-API-deploy builds still get
    /// update notifications.
    private func fetchManifest(primary: URL) async throws -> UpdateManifest {
        do {
            return try await fetchAndDecode(url: primary)
        } catch {
            return try await fetchAndDecode(url: Self.fallbackFeedURL)
        }
    }

    private func fetchAndDecode(url: URL) async throws -> UpdateManifest {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 15
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(UpdateManifest.self, from: data)
    }

    // MARK: - Internals

    private func rescheduleTimer() {
        timer?.invalidate()
        let t = Timer(timeInterval: Self.checkInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkForUpdates(userInitiated: false)
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private static func currentVersionAndBuild() -> (String, String) {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return (v, b)
    }
}
