// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Network", targets: ["Network"])
    ],
    dependencies: [
        .package(path: "../Data"),
        .package(path: "../Swallow")
    ],
    targets: [
        .target(name: "Network", dependencies: ["Data", "Swallow"], path: "Sources"),
        .testTarget(name: "NetworkTests", dependencies: ["Network"], path: "Tests")
    ],
    swiftLanguageVersions: [
        .version("5.1")
    ]
)
