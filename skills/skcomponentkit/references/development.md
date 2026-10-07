# Library development

## Repository map

| Path | Purpose |
| --- | --- |
| `Package.swift`, `Package.resolved` | Platforms, dependencies, and resolved revisions |
| `Sources/SKComponentKit/UIKit/Views/` | Reusable controls and drawing views |
| `Sources/SKComponentKit/UIKit/Features/` | Controller-based features, including `ScrollView/` |
| `Sources/SKComponentKit/UIKit/Utils/` | Shared helpers and extensions |
| `Examples/UIKit/Demos/` | Client-side examples importing the local library |
| `Examples/UIKit/Catalog/` | Demo registry and preview host |
| `Examples/UIKit/Tests/` | Component behavior and external public-API tests |
| `Examples/UIKit/UITests/` | Catalog interaction tests |
| `Examples/UIKit/project.yml` | XcodeGen source of truth for the example project |
| `.github/workflows/build.yml` | Current CI build and test commands |

## Implementing a component

Read the nearest existing component before choosing construction, naming, and layout patterns.
Keep reusable implementation under `Sources/`; example-only screen composition belongs under
`Examples/`. Preserve existing author headers when editing imported files.

Place UIKit imports and declarations inside `#if canImport(UIKit)`. Use runtime availability
checks for newer OS behavior. When an API is absent from supported older SDKs, runtime checks
alone are insufficient: use an appropriate compile-time guard or explicitly change the supported
toolchain contract as part of the requested task. The top-edge feature currently uses
`#if compiler(>=6.2)` plus an iOS 27 runtime check.

Expose the constructor and any nested configuration types needed by clients. A public class
with an internal initializer is not constructible from another app. Keep extensible controllers
and intended override points `open`; do not broaden access for unrelated internals.

EasyAnchor tracks `master`; BlurUIKit is an iOS-only dependency starting at 1.5.0. Preserve the
conditional linkage so macOS builds do not compile UIKit-only dependency code. Check resolved
revisions when diagnosing behavior; avoid unrelated package upgrades and lockfile churn.

## Demonstrating and testing

- Register reusable component demos in `ImportedComponentDemos.all`. `ComponentRegistry`
  forwards that list; the playground remains separate. Update tests or prose that assert the
  demo count when adding a demo.
- `DemoHostViewController` normally pins content to the safe area. Set a demo's
  `extendsUnderNavigationBar` when its purpose requires content beneath navigation controls.
  Scope any navigation-bar changes to the demo and restore them on exit.
- Extend `PublicAPIAvailabilityTests.swift` for exported constructors and override points.
  Keep its normal `import SKComponentKit`: `@testable` would hide public-access mistakes.
- Put behavior tests in the example test target. There is currently no SwiftPM test target;
  `swift test` is not a substitute for the iOS example tests.
- Use regression tests for meaningful contracts: repeated installation, target replacement,
  dynamic layout, teardown, or a reproduced defect. Do not treat loading a view alone as proof
  that rendered layout or performance is correct.

After adding/removing example source files or changing project configuration, regenerate:

```sh
xcodegen generate --spec Examples/UIKit/project.yml
```

Keep `project.yml` and the generated `.xcodeproj` consistent. SwiftPM automatically discovers
library source files, so adding only a library file does not require XcodeGen.

## Validation commands

Run from the library root. Choose checks appropriate to the change; documentation-only edits
do not need app builds. For shared UIKit source or public API changes, verify iOS compilation
and relevant example tests; verify macOS when imports, dependencies, or shared source change.

```sh
swift build

xcodebuild -project Examples/UIKit/SKComponentKitExample.xcodeproj \
  -scheme SKComponentKitExample \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .build/example CODE_SIGNING_ALLOWED=NO build
```

For runtime tests, choose an available simulator ID, then run:

```sh
xcodebuild -project Examples/UIKit/SKComponentKitExample.xcodeproj \
  -scheme SKComponentKitExample \
  -destination "platform=iOS Simulator,id=$SK_TEST_SIMULATOR_ID" \
  -derivedDataPath .build/example -parallel-testing-enabled NO \
  -only-testing:SKComponentKitExampleTests test
```

Select an affected test suite for narrow changes. Include relevant `SKComponentKitExampleUITests`
when navigation or user interaction changes. If XcodeBuildMCP is available, its build/test tools
are suitable equivalents; verify its session defaults before using them. Never hardcode a
developer's simulator UUID in this skill or in repository configuration.

New availability branches need both supported and fallback coverage where runtimes are available.
Report unavailable runtimes explicitly. Camera recognition and haptics need physical-device
checks; simulator tests and preview text-size overrides do not establish those behaviors.

## Scroll-edge maintenance

Keep root-scroll overlays anchored to `frameLayoutGuide`, not moving content coordinates.
Preserve idempotent installation, safe-area updates, explicit nested targets, opt-out behavior,
and restoration of original system-edge settings on `remove()`. Relevant regression tests are
`TopScrollEdgeEffectTests` and the top-edge catalog UI test.

For safety or performance reviews, inspect the resolved BlurUIKit source. Version 1.5.0 uses
undocumented filter/backdrop behavior; passing functional tests does not establish App Store
acceptance or frame-rate/battery performance. Check accessibility preferences and lifecycle
ownership when changing this feature. These are review considerations, not instructions to
replace the user's chosen blur implementation during unrelated work.
