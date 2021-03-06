// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Highlight",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Highlight",
            targets: ["Highlight"]),
    ],
    targets: [
        .target(
            name: "Highlight",
            dependencies: []),
        .testTarget(
            name: "HighlightTests",
            dependencies: ["Highlight"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
