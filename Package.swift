// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "NetworkKit", targets: ["NetworkKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/vmanot/API.git", .branch("master")),
        .package(url: "https://github.com/vmanot/Merge.git", .branch("master")),
        .package(url: "https://github.com/vmanot/Swallow.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                "API",
                "Merge",
                "Swallow"
            ],
            path: "Sources"
        ),
    ]
)
