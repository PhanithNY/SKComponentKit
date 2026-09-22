# SKComponentKit

Reusable UI components for iOS and macOS, distributed with Swift Package Manager.

The package scaffold is ready. Components will be added over time.

## Requirements

- iOS 15.0+ or macOS 26.0+
- Swift 6.0+
- Xcode 16.0+ for iOS; Xcode 26.0+ for macOS

## Installation

In Xcode, choose **File → Add Package Dependencies** and enter:

```text
https://github.com/PhanithNY/SKComponentKit.git
```

Select the `main` branch and add the **SKComponentKit** library to your app target.
For this private repository, authenticate with a GitHub account that has access.

To use it from another Swift package, add the dependency:

```swift
dependencies: [
    .package(
        url: "https://github.com/PhanithNY/SKComponentKit.git",
        branch: "main"
    ),
]
```

Then add the product to the consuming target's dependencies:

```swift
.product(name: "SKComponentKit", package: "SKComponentKit")
```

The package currently tracks `main`; versioned releases can be added when components are ready.

## Usage

```swift
import SKComponentKit
```

There are no public components yet. Add reusable components under
`Sources/SKComponentKit/`, marking types and initializers intended for app use as `public`.
Keep shared components compatible with both supported platforms, and use conditional
compilation for platform-specific implementations.

## Development

Open `Package.swift` in Xcode, or build the library from the terminal:

```sh
swift build
```

Build for the iOS Simulator:

```sh
xcodebuild -scheme SKComponentKit \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath .build/xcode \
    CODE_SIGNING_ALLOWED=NO build
```

GitHub Actions builds the library for macOS and the iOS Simulator on pushes and pull requests.
Add a test target alongside the first testable component.
