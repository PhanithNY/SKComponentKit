#if canImport(UIKit)
import BlurUIKit
import UIKit

/// A viewport-pinned blur for controllers that cannot inherit from `SKViewController`.
/// Retain one instance per controller, install after layout, and call `updateLayout()`
/// from `viewDidLayoutSubviews()`. Call `remove()` when the effect is no longer needed.
@MainActor
public final class SKTopScrollEdgeEffect {

  /// Matches the iOS 27+ behavior from the original app. Older SDK builds are a no-op.
  public static var isSupported: Bool {
    #if compiler(>=6.2)
    if #available(iOS 27.0, *) { return true }
    #endif
    return false
  }

  private weak var viewController: UIViewController?
  private weak var scrollView: UIScrollView?
  private var effectView: VariableBlurView?
  private var heightConstraint: NSLayoutConstraint?
  private var restoreSystemEffects: (() -> Void)?

  public init() {}

  /// Finds a root scroll view or the first direct child that fills the available height.
  /// Does not load the controller's view or search inside child view controllers.
  public func installIfNeeded(in viewController: UIViewController) {
    guard Self.isSupported, let view = viewController.viewIfLoaded else { return }

    if let scrollView = view as? UIScrollView {
      installIfNeeded(on: scrollView, in: viewController)
      return
    }

    let availableHeight = view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
    guard availableHeight > 0,
          let scrollView = view.subviews.compactMap({ $0 as? UIScrollView }).first(where: {
            !$0.isHidden && ($0.bounds.height >= availableHeight || $0.contentSize.height >= availableHeight)
          }) else {
      remove()
      return
    }
    installIfNeeded(on: scrollView, in: viewController)
  }

  /// Selects an explicit scroll view, including a nested table or collection view.
  /// Repeated calls are safe; changing the target restores the old target's system effects.
  public func installIfNeeded(on scrollView: UIScrollView, in viewController: UIViewController) {
    #if compiler(>=6.2)
    guard #available(iOS 27.0, *), let view = viewController.viewIfLoaded else { return }
    guard scrollView === view || scrollView.isDescendant(of: view) else {
      remove()
      return
    }

    if self.viewController === viewController, self.scrollView === scrollView,
       effectView?.superview === view {
      updateLayout()
      return
    }
    remove()

    let effectView = VariableBlurView()
    effectView.dimmingTintColor = UIColor.systemBackground.withAlphaComponent(0.7)
    effectView.dimmingOvershoot = .relative(fraction: 0.25)
    effectView.dimmingAlpha = .interfaceStyle(lightModeAlpha: 1, darkModeAlpha: 1)
    effectView.direction = .down
    effectView.isUserInteractionEnabled = false
    effectView.accessibilityElementsHidden = true
    effectView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(effectView)

    // A root scroll view's bounds move with its content; the frame guide stays in the viewport.
    let topAnchor = view === scrollView ? scrollView.frameLayoutGuide.topAnchor : view.topAnchor
    let leadingAnchor = view === scrollView ? scrollView.frameLayoutGuide.leadingAnchor : view.leadingAnchor
    let trailingAnchor = view === scrollView ? scrollView.frameLayoutGuide.trailingAnchor : view.trailingAnchor
    let heightConstraint = effectView.heightAnchor.constraint(equalToConstant: 0)
    NSLayoutConstraint.activate([
      effectView.topAnchor.constraint(equalTo: topAnchor),
      effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
      effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
      heightConstraint,
    ])

    let originalTopStyle = scrollView.topEdgeEffect.style
    let originalBottomStyle = scrollView.bottomEdgeEffect.style
    let originalTopIsHidden = scrollView.topEdgeEffect.isHidden
    restoreSystemEffects = { [weak scrollView] in
      scrollView?.topEdgeEffect.style = originalTopStyle
      scrollView?.bottomEdgeEffect.style = originalBottomStyle
      scrollView?.topEdgeEffect.isHidden = originalTopIsHidden
    }
    self.viewController = viewController
    self.scrollView = scrollView
    self.effectView = effectView
    self.heightConstraint = heightConstraint

    scrollView.topEdgeEffect.style = .soft
    scrollView.bottomEdgeEffect.style = .soft
    updateLayout()
    #endif
  }

  /// Updates safe-area coverage and yields to UIKit when the navigation bar prefers large titles.
  public func updateLayout() {
    guard let viewController, let view = viewController.viewIfLoaded,
          let scrollView, let effectView, let heightConstraint else { return }
    guard effectView.superview === view,
          scrollView === view || scrollView.isDescendant(of: view) else {
      remove()
      return
    }

    #if compiler(>=6.2)
    if #available(iOS 27.0, *) {
      let usesSystemEffect = viewController.navigationController?.navigationBar.prefersLargeTitles == true
      effectView.isHidden = usesSystemEffect
      scrollView.topEdgeEffect.isHidden = !usesSystemEffect
      if usesSystemEffect { return }
    }
    #endif

    let height = view === scrollView
      ? view.safeAreaInsets.top
      : view.readableContentGuide.layoutFrame.minY - view.bounds.minY
    let resolvedHeight = max(0, height)
    if heightConstraint.constant != resolvedHeight {
      heightConstraint.constant = resolvedHeight
    }
    if view.subviews.last !== effectView {
      view.bringSubviewToFront(effectView)
    }
  }

  /// Removes the overlay and restores the system edge settings captured at installation.
  public func remove() {
    restoreSystemEffects?()
    restoreSystemEffects = nil
    heightConstraint?.isActive = false
    effectView?.removeFromSuperview()
    heightConstraint = nil
    effectView = nil
    scrollView = nil
    viewController = nil
  }
}
#endif
