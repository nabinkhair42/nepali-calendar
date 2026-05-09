// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "NepaliCalendar",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "NepaliCalendar", targets: ["NepaliCalendar"]),
        .executable(name: "NepaliCalendarVerify", targets: ["NepaliCalendarVerify"]),
        .library(name: "BSCore", targets: ["BSCore"])
    ],
    targets: [
        .target(
            name: "BSCore",
            path: "Sources/BSCore"
        ),
        .executableTarget(
            name: "NepaliCalendar",
            dependencies: ["BSCore"],
            path: "Sources/NepaliCalendar"
        ),
        .executableTarget(
            name: "NepaliCalendarVerify",
            dependencies: ["BSCore"],
            path: "Sources/NepaliCalendarVerify"
        )
    ]
)
