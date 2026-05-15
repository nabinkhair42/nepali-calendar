import Foundation

/// Tiny numeric semver comparator — splits on "." and compares each component
/// as an Int (missing components treated as 0). We intentionally don't support
/// pre-release suffixes ("1.0.0-beta.1") because release.sh only ever emits
/// "X.Y.Z" from CFBundleShortVersionString.
enum Version {
    /// Compare `a` against `b`. Returns negative if a < b, 0 if equal, positive if a > b.
    static func compare(_ a: String, _ b: String) -> Int {
        let pa = parts(a)
        let pb = parts(b)
        let count = max(pa.count, pb.count)
        for i in 0..<count {
            let da = i < pa.count ? pa[i] : 0
            let db = i < pb.count ? pb[i] : 0
            if da != db { return da < db ? -1 : 1 }
        }
        return 0
    }

    private static func parts(_ s: String) -> [Int] {
        s.split(separator: ".").map { Int($0) ?? 0 }
    }
}
