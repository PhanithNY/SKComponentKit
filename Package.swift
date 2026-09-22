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
    dependencies: [
        .package(
            url: "https://github.com/PhanithNY/EasyAnchor.git",
            revision: "fbc2a3b5790a1a857563c0fb7d54ff3bb36cdacc"
        ),
    ],
    targets: [
        .target(
            name: "SKComponentKit",
            dependencies: [.product(name: "EasyAnchor", package: "EasyAnchor")]
        ),
    ]
)
