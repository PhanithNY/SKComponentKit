import SKComponentKit
import UIKit

/// Register a demo here after adding its implementation to the package.
@MainActor
struct ComponentDemo {
    let title: String
    let summary: String
    let symbolName: String
    let makeViewController: () -> UIViewController
}

@MainActor
enum ComponentRegistry {
    // Keep package demos separate from the example app's UIKit playground.
    static let components: [ComponentDemo] = []

    static let playground = ComponentDemo(
        title: "UIKit Playground",
        summary: "Check appearance, text sizes, and interaction.",
        symbolName: "slider.horizontal.3",
        makeViewController: { PlaygroundViewController() }
    )
}
