import Foundation
import AppKit
import CryptoKit

/// Performs the actual download → verify → mount → swap → relaunch dance.
/// Runs off the main actor so the network I/O and shell-outs don't block UI;
/// progress is reported back via the `progress` closure on the main queue.
///
/// Failure modes are intentionally surfaced as `UpdateInstallerError` so the
/// UI layer can show a coherent message instead of a generic spinner that
/// stalls forever.
enum UpdateInstallerError: Error, LocalizedError {
    case downloadFailed(String)
    case checksumMismatch(expected: String, actual: String)
    case mountFailed(String)
    case appNotFoundInDMG
    case swapHelperFailed(String)

    var errorDescription: String? {
        switch self {
        case .downloadFailed(let msg):          return "Download failed: \(msg)"
        case .checksumMismatch(let e, let a):   return "Checksum mismatch (expected \(e.prefix(8))…, got \(a.prefix(8))…)"
        case .mountFailed(let msg):             return "Could not mount disk image: \(msg)"
        case .appNotFoundInDMG:                 return "Update package did not contain the expected app bundle"
        case .swapHelperFailed(let msg):        return "Install helper failed: \(msg)"
        }
    }
}

struct UpdateInstaller {
    /// Download the DMG referenced by the manifest, verify its sha256, and
    /// arrange for it to replace the current bundle. On success this function
    /// returns just before `NSApp.terminate(_:)` is called — control rarely
    /// reaches the caller after that.
    ///
    /// - Parameters:
    ///   - manifest: parsed update manifest (gives URL + expected sha256)
    ///   - progress: 0.0...1.0 progress callback, invoked on the main queue
    static func install(
        manifest: UpdateManifest,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        guard let url = URL(string: manifest.downloadUrl) else {
            throw UpdateInstallerError.downloadFailed("invalid downloadUrl")
        }

        // 1. Download to temp
        let tmpDMG = try await download(from: url, progress: progress)

        // 2. Verify sha256
        let actual = try sha256(of: tmpDMG)
        guard actual.caseInsensitiveCompare(manifest.sha256) == .orderedSame else {
            try? FileManager.default.removeItem(at: tmpDMG)
            throw UpdateInstallerError.checksumMismatch(expected: manifest.sha256, actual: actual)
        }

        // 3. Mount
        let mountPoint = try mount(dmg: tmpDMG)

        // 4. Locate .app inside the DMG
        guard let mountedApp = locateApp(at: mountPoint) else {
            try? detach(mountPoint: mountPoint)
            throw UpdateInstallerError.appNotFoundInDMG
        }

        // 5. Stage swap-and-relaunch helper, then terminate ourselves so the
        //    helper can replace our bundle without "Resource busy".
        try await scheduleSwap(
            mountedApp: mountedApp,
            mountPoint: mountPoint,
            tmpDMG: tmpDMG
        )
    }

    // MARK: - Download

    private static func download(
        from url: URL,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws -> URL {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw UpdateInstallerError.downloadFailed("HTTP \((response as? HTTPURLResponse)?.statusCode ?? -1)")
        }

        let total = max(response.expectedContentLength, 1)
        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("NepaliCalendarUpdate-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        let dst = tmpDir.appendingPathComponent("NepaliCalendar.dmg")

        FileManager.default.createFile(atPath: dst.path, contents: nil)
        guard let handle = FileHandle(forWritingAtPath: dst.path) else {
            throw UpdateInstallerError.downloadFailed("could not open temp file for writing")
        }
        defer { try? handle.close() }

        var received: Int64 = 0
        var buffer = Data()
        buffer.reserveCapacity(64 * 1024)
        var lastReport: Double = -1

        for try await byte in asyncBytes {
            buffer.append(byte)
            if buffer.count >= 64 * 1024 {
                try handle.write(contentsOf: buffer)
                received += Int64(buffer.count)
                buffer.removeAll(keepingCapacity: true)
                let p = Double(received) / Double(total)
                if p - lastReport > 0.01 {
                    lastReport = p
                    let snapshot = min(p, 1.0)
                    await MainActor.run { progress(snapshot) }
                }
            }
        }
        if !buffer.isEmpty {
            try handle.write(contentsOf: buffer)
            received += Int64(buffer.count)
        }
        await MainActor.run { progress(1.0) }

        return dst
    }

    // MARK: - Checksum

    private static func sha256(of file: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: file)
        defer { try? handle.close() }
        var hasher = SHA256()
        while autoreleasepool(invoking: {
            let chunk = try? handle.read(upToCount: 1024 * 1024) ?? Data()
            guard let chunk, !chunk.isEmpty else { return false }
            hasher.update(data: chunk)
            return true
        }) {}
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - hdiutil attach / detach

    private static func mount(dmg: URL) throws -> String {
        let process = Process()
        process.launchPath = "/usr/bin/hdiutil"
        process.arguments = ["attach", "-plist", "-nobrowse", "-noverify", "-noautoopen", dmg.path]
        let out = Pipe()
        let err = Pipe()
        process.standardOutput = out
        process.standardError = err
        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let msg = String(data: err.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "exit \(process.terminationStatus)"
            throw UpdateInstallerError.mountFailed(msg)
        }

        let data = out.fileHandleForReading.readDataToEndOfFile()
        guard
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let entities = plist["system-entities"] as? [[String: Any]]
        else {
            throw UpdateInstallerError.mountFailed("unexpected hdiutil output")
        }

        for entity in entities {
            if let mp = entity["mount-point"] as? String, !mp.isEmpty {
                return mp
            }
        }
        throw UpdateInstallerError.mountFailed("no mount-point in hdiutil output")
    }

    private static func detach(mountPoint: String) throws {
        let process = Process()
        process.launchPath = "/usr/bin/hdiutil"
        process.arguments = ["detach", mountPoint, "-force"]
        try process.run()
        process.waitUntilExit()
    }

    private static func locateApp(at mountPoint: String) -> String? {
        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(atPath: mountPoint) else { return nil }
        for entry in entries where entry.hasSuffix(".app") {
            return (mountPoint as NSString).appendingPathComponent(entry)
        }
        return nil
    }

    // MARK: - Swap helper

    /// Writes a small bash script to /tmp that waits for our PID to exit, swaps
    /// the .app in place, removes the quarantine xattr, detaches the DMG, and
    /// relaunches. The script is detached via `nohup ... &` so it outlives the
    /// shell we spawn, which itself outlives us.
    private static func scheduleSwap(
        mountedApp: String,
        mountPoint: String,
        tmpDMG: URL
    ) async throws {
        let currentBundle = Bundle.main.bundlePath
        let pid = ProcessInfo.processInfo.processIdentifier
        let tmpDir = (NSTemporaryDirectory() as NSString)
        let scriptPath = tmpDir.appendingPathComponent("nepali-calendar-update-\(UUID().uuidString).sh")
        let logPath = tmpDir.appendingPathComponent("nepali-calendar-update.log")

        let q = { (s: String) -> String in
            "'" + s.replacingOccurrences(of: "'", with: "'\\''") + "'"
        }

        let script = """
        #!/bin/bash
        set -u
        LOG=\(q(logPath))
        exec >>"$LOG" 2>&1
        echo "[$(date)] update helper starting (pid $$)"

        TARGET=\(q(currentBundle))
        SOURCE=\(q(mountedApp))
        MOUNT=\(q(mountPoint))
        DMG=\(q(tmpDMG.path))
        PARENT_PID=\(pid)

        # 1. Wait for the running app to exit (max ~10s).
        for i in $(seq 1 50); do
            if ! kill -0 "$PARENT_PID" 2>/dev/null; then break; fi
            sleep 0.2
        done

        # 2. Move the old bundle aside so we can roll back if cp fails.
        BACKUP="${TARGET}.old-$$"
        if [ -d "$TARGET" ]; then
            mv "$TARGET" "$BACKUP" || { echo "mv-backup failed"; exit 1; }
        fi

        # 3. Copy the new bundle into place.
        if ! /bin/cp -R "$SOURCE" "$TARGET"; then
            echo "cp failed, rolling back"
            [ -d "$BACKUP" ] && mv "$BACKUP" "$TARGET"
            /usr/bin/hdiutil detach "$MOUNT" -force >/dev/null 2>&1 || true
            exit 1
        fi

        # 4. Strip quarantine so Gatekeeper doesn't re-prompt for an
        #    ad-hoc-signed update the user explicitly accepted.
        /usr/bin/xattr -dr com.apple.quarantine "$TARGET" >/dev/null 2>&1 || true

        # 5. Detach DMG + clean up.
        /usr/bin/hdiutil detach "$MOUNT" -force >/dev/null 2>&1 || true
        rm -rf "$BACKUP" "$DMG" "$(dirname "$DMG")" >/dev/null 2>&1 || true

        # 6. Relaunch via `open` so LaunchServices registers the new bundle.
        /usr/bin/open "$TARGET"
        echo "[$(date)] update helper done"
        """

        try script.write(toFile: scriptPath, atomically: true, encoding: .utf8)
        _ = chmod(scriptPath, 0o755)

        // Spawn the helper detached. The outer shell exits immediately; the
        // backgrounded `bash <script>` keeps running after we terminate.
        let spawner = Process()
        spawner.launchPath = "/bin/bash"
        spawner.arguments = ["-c", "nohup /bin/bash \(scriptPath) >/dev/null 2>&1 &"]
        do {
            try spawner.run()
            spawner.waitUntilExit()
        } catch {
            throw UpdateInstallerError.swapHelperFailed(error.localizedDescription)
        }

        // Give the helper a moment to start its wait loop before we exit.
        try? await Task.sleep(nanoseconds: 300_000_000)

        await MainActor.run {
            NSApp.terminate(nil)
        }
    }
}
