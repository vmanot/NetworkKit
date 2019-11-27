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
        .package(url: "git@github.com:vmanot/API.git", .branch("master")),
        .package(url: "git@github.com:vmanot/CombineX.git", .branch("master"))
    ],
    targets: [
        .target(name: "Network", dependencies: ["API", "CombineX"], path: "Sources"),
    ],
    swiftLanguageVersions: [
        .version("5.1")
    ]
)
