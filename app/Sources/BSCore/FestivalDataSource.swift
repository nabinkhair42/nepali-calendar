import Foundation

/// Three-tier loader for `festivals-<year>.json`:
///
///   1. **Cache** — `~/Library/Application Support/NepaliCalendar/cache/`
///   2. **Bundle** — frozen snapshot shipped with the app (offline first-run)
///   3. **Network** — `https://nepali-calendar.app/data/festivals-<year>.json`,
///      kept fresh by `.github/workflows/scrape-festivals.yml`
///
/// `loadCachedOrBundled` is synchronous and used at boot. `refresh` runs in
/// the background and writes to cache; the caller decides when to re-parse.
public enum FestivalDataSource {

    /// Where the GitHub-Actions-scraped JSON is published. The web project
    /// auto-deploys to Vercel on every push, so commits made by the workflow
    /// reach this URL within ~30s of the cron run.
    public static let baseURL = URL(string: "https://nepali-calendar.app/data/")!

    private static let cacheDir: URL = {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appendingPathComponent("NepaliCalendar/cache", isDirectory: true)
    }()

    /// Best bytes available without touching the network. Tries cache first
    /// (which wins if any prior launch has refreshed), then falls back to
    /// the bundled resource. Returns nil only if neither exists.
    public static func loadCachedOrBundled(year: Int) -> Data? {
        if let cached = readCache(year: year) { return cached }
        return readBundled(year: year)
    }

    /// Fetch fresh JSON from the network and write it to cache. Returns the
    /// new bytes if they differ from what was cached, otherwise nil. Network
    /// errors and non-200 responses also return nil — callers should treat
    /// nil as "nothing changed, keep using current data."
    public static func refresh(year: Int) async -> Data? {
        let url = baseURL.appendingPathComponent("festivals-\(year).json")
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("NepaliCalendar/1.0 (macOS)", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return nil
            }
            // Sanity check: must be parseable as our YearFile shape before we
            // overwrite a working cache.
            guard (try? JSONDecoder().decode(MinimalYearFile.self, from: data)) != nil else {
                return nil
            }
            try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
            let cacheFile = cacheDir.appendingPathComponent("festivals-\(year).json")
            if let existing = try? Data(contentsOf: cacheFile), existing == data {
                return nil
            }
            try data.write(to: cacheFile, options: .atomic)
            return data
        } catch {
            return nil
        }
    }

    // MARK: - Internals

    private static func readCache(year: Int) -> Data? {
        let url = cacheDir.appendingPathComponent("festivals-\(year).json")
        return try? Data(contentsOf: url)
    }

    private static func readBundled(year: Int) -> Data? {
        guard let url = Bundle.module.url(forResource: "festivals-\(year)", withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    /// Minimal shape for validation only — full parse happens in FestivalDatabase.
    private struct MinimalYearFile: Decodable {
        let year: Int
        let festivals: [Stub]
        struct Stub: Decodable { let month: Int; let day: Int; let nameNE: String }
    }
}
