# PHComponents import

Imported from [PhanithNY/PHComponents](https://github.com/PhanithNY/PHComponents/tree/0c670ab906d18ec4a8c96061a689675cec8b1dc0/Sources/PHComponents),
revision `0c670ab906d18ec4a8c96061a689675cec8b1dc0`.
Original author headers are retained. The upstream repository did not include a license file
at this revision; this import does not introduce a new license for that source.

EasyAnchor is consumed as a package dependency, not copied. Its source and MIT license are
available in [PhanithNY/EasyAnchor](https://github.com/PhanithNY/EasyAnchor/tree/fbc2a3b5790a1a857563c0fb7d54ff3bb36cdacc).

## API and platform compatibility

- Import `SKComponentKit` instead of `PHComponents`. Existing `PH` type names are preserved.
- All six view files, four controller feature files, and supporting utility files are under
  `Sources/SKComponentKit/UIKit`, guarded with `canImport(UIKit)`.
- Minimum deployment versions remain iOS 15 and macOS 26. The imported controls are UIKit
  implementations; this migration does not convert them into AppKit views.
- `PHZigzagView` and its initializer are now public so client apps can use it.
- EasyAnchor is the sole external dependency. The optional-string helper needed from
  PHExtensions is internal to this module; existing color/string helpers are retained.
- UIKit utilities use main-actor isolation under Swift 6. `MainThread` accepts
  `@MainActor @Sendable` closures. `PHDialogueViewController.onDeinit` is `@Sendable` and
  must not directly access actor-isolated UI; schedule UI cleanup on the main actor if needed.
- Fixed layouts use EasyAnchor. Mutable button constraints remain native because EasyAnchor
  does not return constraint handles. Marquee animation and custom shape drawing still use
  frames and layers, since those are part of their animation/drawing behavior.

## Integration fixes

- QR scanning uses one EasyAnchor constraint set, updates the preview and mask on layout,
  requests camera access before configuration, and serializes session start/stop off the main
  thread. Its metadata delegate is explicitly delivered on the main queue.
- Marquee display links use a weak target and stop when detached, avoiding a retain cycle.
  Missing content and failed view copying no longer cause forced-unwrap crashes.
- Refresh-indicator tint changes replace animation layers instead of accumulating them.
- Zigzag rendering reuses its shape layer and clamps invalid line counts.
- Padding changes invalidate label sizing. Button configuration refreshes layout and accessibility
  labels, and stops the activity indicator when loading ends.
- Dialogue taps inside the content no longer invoke the outside-tap callback or cancel controls.

## Example and verification

The UIKit example contains 12 demos covering all imported view/controller features, plus the
existing playground. Component tests load every demo at phone and tablet sizes and check
layout, button state, label sizing, refresh layers, marquee lifetime, text-field rules, and QR frame
constraints. UI tests cover catalog search, preview controls, button callbacks, and dialogue dismissal.

For real scanning, a host app must include `NSCameraUsageDescription` in its Info.plist. The
example includes this key. Simulator only displays the scan frame; camera authorization,
live recognition, and hardware haptics require physical-device validation.

Preview text-size overrides help expose layout issues; they do not automatically make every
imported fixed-size control support Dynamic Type. Test components on your app's target devices.
