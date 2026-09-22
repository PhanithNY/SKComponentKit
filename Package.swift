// swift-tools-version: 6.0
//
//  Package.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

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
            branch: "master"
        ),
        .package(url: "https://github.com/TimOliver/BlurUIKit.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "SKComponentKit",
            dependencies: [
                .product(name: "EasyAnchor", package: "EasyAnchor"),
                .product(name: "BlurUIKit", package: "BlurUIKit", condition: .when(platforms: [.iOS])),
            ]
        ),
    ]
)
