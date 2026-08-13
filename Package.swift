// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WidgieClock",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "WidgieClock", targets: ["WidgieClock"])
    ],
    targets: [
        .executableTarget(name: "WidgieClock"),
        .testTarget(name: "WidgieClockTests", dependencies: ["WidgieClock"])
    ]
)
