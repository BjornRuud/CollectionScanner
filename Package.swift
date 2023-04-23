// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "CollectionScanner",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "CollectionScanner",
            targets: ["CollectionScanner"]),
    ],
    targets: [
        .target(
            name: "CollectionScanner",
            dependencies: []),
        .testTarget(
            name: "CollectionScannerTests",
            dependencies: ["CollectionScanner"]),
    ]
)
