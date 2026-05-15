import Foundation

/// Mirror of the JSON produced by `app/release.sh` and served by the web
/// at GET /api/app/update. Decoded with default JSONDecoder (snake_case keys
/// aren't used; release.sh writes camelCase).
struct UpdateManifest: Codable, Equatable {
    let name: String
    let version: String
    let build: String
    let artifact: String
    let downloadUrl: String
    let githubReleaseUrl: String
    let sha256: String
    let sizeBytes: Int
    let createdAt: String

    /// Present when fetched via /api/app/update (the server computed it for us).
    /// Absent when fetched as the raw static /downloads/latest.json file.
    let updateAvailable: Bool?
}
