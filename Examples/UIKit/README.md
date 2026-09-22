# UIKit Example

A programmatic UIKit app for trying SKComponentKit components on iPhone and iPad, starting
with iOS 15. It imports the local package at `../..`; no remote dependency is used.

## Run

1. Open `SKComponentKitExample.xcodeproj` in Xcode 16 or later.
2. Select the **SKComponentKitExample** scheme and an iOS simulator.
3. Run with **Command-R**.

To run on a physical device, select your development team in **Signing & Capabilities** and
choose a unique bundle identifier if needed. The repository does not set a development team.

From the repository root, build without signing:

```sh
xcodebuild -project Examples/UIKit/SKComponentKitExample.xcodeproj \
    -scheme SKComponentKitExample \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath .build/example \
    CODE_SIGNING_ALLOWED=NO build
```

## Add a component demo

1. Implement the public UIKit component under `Sources/SKComponentKit`, inside a
   `#if canImport(UIKit)` guard.
2. Create a `UIViewController` under `Demos`, import `SKComponentKit`, and lay out the
   component. Include useful states such as enabled, disabled, loading, and long content.
3. Add a descriptor to `ComponentRegistry.components` in `Catalog/ComponentDemo.swift`:

```swift
// After implementing ExampleButtonViewController:
ComponentDemo(
    title: "Example Button",
    summary: "Button styles and interaction states.",
    symbolName: "rectangle.and.hand.point.up.left",
    makeViewController: { ExampleButtonViewController() }
)
```

4. Regenerate the project when adding or removing source files:

```sh
# From the repository root, with XcodeGen 2.44+ installed:
xcodegen generate --spec Examples/UIKit/project.yml
```

Commit the new source files and regenerated `.xcodeproj` together. The committed project
and shared scheme allow everyone else, including CI, to build without XcodeGen.
Change project settings in `project.yml` before regenerating; direct project edits may be overwritten.

The catalog automatically includes registered demos in search. Each demo opens in
`DemoHostViewController`; its **Preview** menu overrides appearance and text size for that
demo only. UIKit sheets presented separately may need their own trait configuration.
Dynamic Type support still depends on the component using scalable fonts and flexible layout.

## Manual checks for each component

Run tests with **Command-U** in Xcode. Component tests load all 12 demos at phone and tablet
sizes and check layout and lifecycle behavior. UI tests verify catalog search, navigation,
button callbacks, dialogue dismissal, and preview controls. GitHub Actions runs these checks as well.

- Interact with the demo and verify its state changes.
- Check light and dark appearances.
- Check default text and Accessibility XXXL, including scrolling and truncation.
- Run on iPhone and iPad, in portrait and landscape.
- Check VoiceOver and the oldest supported iOS version when that runtime or device is available.

The UIKit playground is example-only code, not a public SKComponentKit component.
The component catalog contains the imported PHComponents views and controllers. Use the QR
Scanner demo on a physical device for camera testing; Simulator displays the frame only.
AppKit components need a native macOS example app; this project does not use Mac Catalyst.
