// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "CollectionScanner",
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
