import Foundation

/// Two-tier loader for `festivals-<year>.json`:
///
///   1. **Cache** — `~/Library/Application Support/NepaliCalendar/cache/`
///   2. **Network** — `https://calendar.nabinkhair.com.np/api/festivals/<year>`.
///      The route fronts a Cloudflare-KV-backed live scrape of ashesh.com.np
///      so any BS year resolves on demand without a redeploy.
///
/// `loadCached` is synchronous and used at boot. `refresh` runs in the
/// background and writes to cache; the caller decides when to re-parse.
///
/// First launch with no internet shows only the hard-coded recurring
/// national days (6 entries). Any successful refresh fills the cache, so
/// every subsequent launch — online or off — sees the full festival list.
public enum FestivalDataSource {

    /// Base URL for the festivals API. The route validates BS year range,
    /// reads from KV, and falls back to a fresh scrape on cold cache.
    public static let baseURL = URL(string: "https://calendar.nabinkhair.com.np/api/festivals/")!

    private static let cacheDir: URL = {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appendingPathComponent("NepaliCalendar/cache", isDirectory: true)
    }()

    /// Bytes from the on-disk cache, or nil if no prior refresh has succeeded.
    public static func loadCached(year: Int) -> Data? {
        let url = cacheDir.appendingPathComponent("festivals-\(year).json")
        return try? Data(contentsOf: url)
    }

    /// Fetch fresh JSON from the network and write it to cache. Returns the
    /// new bytes if they differ from what was cached, otherwise nil. Network
    /// errors and non-200 responses also return nil — callers should treat
    /// nil as "nothing changed, keep using current data."
    public static func refresh(year: Int) async -> Data? {
        let url = baseURL.appendingPathComponent("\(year)")
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

    /// Minimal shape for validation only — full parse happens in FestivalDatabase.
    private struct MinimalYearFile: Decodable {
        let year: Int
        let festivals: [Stub]
        struct Stub: Decodable { let month: Int; let day: Int; let nameNE: String }
    }
}
