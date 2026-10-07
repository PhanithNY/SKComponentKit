#if canImport(UIKit)
import UIKit

/// A base controller that automatically maintains a top scroll-edge blur on iOS 27+.
/// Subclasses overriding lifecycle methods must call `super`.
open class SKViewController: UIViewController {

  /// Override to opt a screen out of the custom effect.
  open var preferredCustomTopEdgeEffectOverSystemProvidedComponent: Bool {
    SKTopScrollEdgeEffect.isSupported
  }

  /// Override for a nested scroll view or a screen with multiple scroll views.
  /// Returning nil uses automatic discovery of the root or a full-height direct child.
  open var scrollViewForTopEdgeEffect: UIScrollView? { nil }

  private let topScrollEdgeEffect = SKTopScrollEdgeEffect()

  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateTopScrollEdgeEffect()
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateTopScrollEdgeEffect()
  }

  /// Refresh after changing the opt-out preference or the target scroll view.
  public func updateTopScrollEdgeEffect() {
    guard preferredCustomTopEdgeEffectOverSystemProvidedComponent else {
      topScrollEdgeEffect.remove()
      return
    }

    if let scrollView = scrollViewForTopEdgeEffect {
      topScrollEdgeEffect.installIfNeeded(on: scrollView, in: self)
    } else {
      topScrollEdgeEffect.installIfNeeded(in: self)
    }
  }
}
#endif
