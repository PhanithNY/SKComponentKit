// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SKComponentKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "SKComponentKit",
            targets: ["SKComponentKit"]
        ),
    ],
    targets: [
        .target(name: "SKComponentKit"),
    ]
)
