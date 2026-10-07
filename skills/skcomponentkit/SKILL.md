---
name: skcomponentkit
description: "Develop, review, test, or integrate the SKComponentKit Swift package and its UIKit components. Use for changes in the SKComponentKit repository, adopting its controls or automatic top scroll-edge effect in an app, and migrating PHComponents clients."
---

# SKComponentKit

Work from the actual package revision used by the task. This skill supports library maintenance
and client-app integration; choose the relevant workflow without changing unrelated apps.

## Locate the source of truth

- In the library checkout, read `Package.swift`, `README.md`, and the affected source under
  `Sources/SKComponentKit/`. Use `MIGRATION.md` when the task involves imported PHComponents APIs.
- In a client app, inspect its package reference and `Package.resolved` first. A remote dependency
  may lag behind this checkout. Resolve the installed package source before relying on a newer API;
  do not silently replace the app's dependency with a machine-specific local path.
- Repository: `https://github.com/PhanithNY/SKComponentKit`. The package and product are both
  `SKComponentKit`. This skill's repository copy lives at `skills/skcomponentkit/`; an installed
  copy may be elsewhere. Do not assume the working directory is the library root.

## Pick the workflow

- **Change or review the library:** read [Library development](references/development.md).
  It covers source placement, external API access, example registration, and meaningful validation.
- **Use it in another app:** read [App integration](references/integration.md).
  It covers package wiring, controller adoption, and top scroll-edge lifecycle behavior.
- **Change a public API used by an app:** use both, checking the consuming call sites before
  renaming or changing defaults.

## Preserve the package contract

- Current baseline: Swift tools 6.0, iOS 15+, and macOS 26+. Confirm in `Package.swift` before
  editing; a newer SDK feature does not justify raising every client's deployment target.
- The current reusable UI is UIKit. A successful macOS build does not validate UIKit code:
  those sources are excluded by `#if canImport(UIKit)`. Keep platform imports inside the guard.
- Export reusable types with the project's `SK` prefix. `public` permits client access;
  `open` is required for classes and members intentionally overridden outside the module.
- Keep app-specific localization, status-bar policy, and business behavior in the client.
  Preserve the caller's lifecycle by calling `super` from overridden controller methods.
- Follow neighboring Swift formatting. EasyAnchor is the existing layout dependency; native
  constraints are appropriate when retaining mutable constraint handles. Do not add another
  layout framework for a routine component.
- Maintain UIKit/main-actor isolation under Swift 6. Follow existing isolation and callback
  conventions instead of silencing diagnostics with broad unchecked annotations.

## Focus the result

Explain the resulting public behavior, client adoption steps, and checks actually run. Distinguish
simulator correctness from physical-device performance or camera validation. Keep this skill's
references aligned when a change alters the library's build workflow or integration contract.
