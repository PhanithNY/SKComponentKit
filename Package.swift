// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SKComponentKit",
    platforms: [
        .iOS(.v15),
        .macOS("26.0"),
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
