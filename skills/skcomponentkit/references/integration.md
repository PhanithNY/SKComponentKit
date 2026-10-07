# App integration

## Package setup

Inspect the app's existing dependency configuration before adding anything. The repository is
`https://github.com/PhanithNY/SKComponentKit.git`; both the library product and Swift module are
`SKComponentKit`. Follow the app's current version/revision policy and confirm the desired API
exists at its resolved revision. This repository currently documents tracking `main`.

For a SwiftPM consumer, the package declaration and target dependency are:

```swift
.package(url: "https://github.com/PhanithNY/SKComponentKit.git", branch: "main")
.product(name: "SKComponentKit", package: "SKComponentKit")
```

These entries belong in their respective dependency arrays, not one combined list. In an Xcode
app, attach the product to the consuming target. Prefer the app's existing remote dependency;
the repository's example intentionally uses a local package for library development.

Import `SKComponentKit` to use the components. UIKit components require an iOS target even
though the package also builds on macOS. If the client directly calls EasyAnchor APIs, configure
and import EasyAnchor as the app's own dependency rather than relying on a transitive import.

Use `README.md` for the current component catalog and inspect source for exact signatures.
For PHComponents migration, read `MIGRATION.md`; the module and exported type names changed.
Do not guess SwiftUI equivalents or rename existing public API spellings as part of adoption.

## Automatic top scroll-edge behavior

For apps with a shared `UIViewController` base, change that base to `SKViewController`:

```swift
import SKComponentKit

open class AppViewController: SKViewController {
    // Preserve the app's localization and status-bar behavior here.
}
```

`SKScrollViewController` already inherits from `SKViewController`. Importing the module alone
does not change other controllers; there is no global swizzling. Subclasses must continue to
call `super` in lifecycle overrides.

The custom effect currently activates on iOS 27+ when compiled with Swift 6.2+ / Xcode 26+.
Older runtime/compiler combinations are a no-op. Verify this against the resolved source;
the package still supports iOS 15 overall.

Default discovery selects a root `UIScrollView`, table, or collection, or a visible direct child
whose frame or content height fills the available height. It does not recursively discover
nested lists. For nested layouts or multiple candidates, override explicitly:

```swift
override var scrollViewForTopEdgeEffect: UIScrollView? {
    contentScrollView // The app's existing scroll view.
}
```

Opt a screen out by overriding `preferredCustomTopEdgeEffectOverSystemProvidedComponent` to
return `false`. After dynamically changing that preference or the explicit target, call
`updateTopScrollEdgeEffect()`.

The effect yields to UIKit when the navigation bar's `prefersLargeTitles` is true. This is the
bar's preference, not detection of whether a large title is currently expanded. Preserve that
distinction when diagnosing why a custom overlay is hidden.

The scroll content must extend beneath the top safe area to pass behind the blur. With
`SKScrollViewController`, override `ignoredSafeArea` to return `true` when that layout is desired.
Do not remove safe-area constraints from unrelated client screens merely to enable an effect.

## Controllers with another superclass

For `UITableViewController`, `UICollectionViewController`, or a third-party base controller,
retain a helper rather than changing the superclass hierarchy:

```swift
private let topEdgeEffect = SKTopScrollEdgeEffect()

override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    topEdgeEffect.installIfNeeded(on: tableView, in: self)
}
```

Replace `tableView` with the actual scroll view. Installation also updates layout and can be
repeated; use one helper for the controller/target, not a fresh helper per layout pass.
Call `remove()` when detaching or disabling it while the view survives. Simply dropping the
helper does not restore UIKit settings or remove the attached overlay. If removal happens on
disappearance, ensure subsequent layout/appearance reinstalls it as intended.

The helper sets top and bottom system-edge styles to `.soft` and manages top-edge visibility.
Removal restores values captured at installation; coordinate any app code that also changes
those properties. The custom rendering uses BlurUIKit. Do not describe it as guaranteed
App Store-safe or performance-neutral; respect the user's chosen tradeoff and scope.

## Verify in the consuming app

Build the actual app target against its resolved package, not just the library checkout. For
controller adoption, verify appearance/disappearance, scrolling, rotation or safe-area changes,
large-title configuration, and an older-OS fallback relevant to the app. Retain app-specific
RTL/status-bar overrides and existing keyboard handling. Add focused tests where lifecycle or
layout behavior changes; do not copy the entire library test suite into a client.
