// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v6)
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
        .package(url: "https://github.com/vmanot/Merge.git", branch: "master"),
        .package(url: "https://github.com/vmanot/Swallow.git", branch: "master"),
        .package(url: "https://github.com/vmanot/SwiftAPI.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                "Merge",
                "Swallow",
                "SwiftAPI",
            ],
            path: "Sources"
        ),
    ]
)
