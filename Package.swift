// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .tvOS(.v14),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "NetworkKit",
            targets: [
                "NetworkKit"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/vmanot/CorePersistence.git", branch: "main"),
        .package(url: "https://github.com/vmanot/Merge.git", branch: "master"),
        .package(url: "https://github.com/vmanot/Swallow.git", branch: "master"),
        .package(url: "https://github.com/vmanot/SwiftAPI.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                "CorePersistence",
                "Merge",
                "Swallow",
                "SwiftAPI",
            ],
            path: "Sources",
            swiftSettings: []
        ),
    ]
)
