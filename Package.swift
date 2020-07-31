// swift-tools-version:5.1

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
        .package(url: "git@github.com:vmanot/API.git", .branch("master")),
        .package(url: "git@github.com:vmanot/Merge.git", .branch("master")),
        .package(url: "git@github.com:vmanot/Task.git", .branch("master"))
    ],
    targets: [
        .target(name: "NetworkKit", dependencies: ["API", "Merge", "Task"], path: "Sources"),
    ],
    swiftLanguageVersions: [
        .version("5.1")
    ]
)
