import SKComponentKit
import UIKit
import XCTest

final class TopScrollEdgeEffectTests: XCTestCase {
    @MainActor
    func testInstallationDoesNotLoadView() {
        let controller = SKViewController()
        controller.updateTopScrollEdgeEffect()
        XCTAssertFalse(controller.isViewLoaded)
    }

    @MainActor
    func testAutomaticInstallationAndOptOut() {
        let controller = ConfigurableEdgeController()
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        let scroll = UIScrollView(frame: controller.view.bounds)
        controller.view.addSubview(scroll)
        controller.viewDidLayoutSubviews()
        let expectedCount = SKTopScrollEdgeEffect.isSupported ? 2 : 1
        XCTAssertEqual(controller.view.subviews.count, expectedCount)
        controller.viewDidAppear(false)
        controller.viewDidLayoutSubviews()
        XCTAssertEqual(controller.view.subviews.count, expectedCount, "Repeated lifecycle calls must not duplicate the overlay")
        controller.isEffectEnabled = false
        controller.updateTopScrollEdgeEffect()
        XCTAssertEqual(controller.view.subviews.count, 1)
        controller.isEffectEnabled = true
        controller.updateTopScrollEdgeEffect()
        XCTAssertEqual(controller.view.subviews.count, expectedCount)
    }

    @MainActor
    func testDiscoverySkipsShortScrollViewAndFindsFullHeightSibling() {
        let controller = SKViewController()
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        let shortScroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: 390, height: 100))
        controller.view.addSubview(shortScroll)
        controller.updateTopScrollEdgeEffect()
        XCTAssertEqual(controller.view.subviews.count, 1)
        let fullScroll = UIScrollView(frame: controller.view.bounds)
        controller.view.addSubview(fullScroll)
        controller.updateTopScrollEdgeEffect()
        XCTAssertEqual(controller.view.subviews.count, SKTopScrollEdgeEffect.isSupported ? 3 : 2)
        fullScroll.removeFromSuperview()
        controller.updateTopScrollEdgeEffect()
        XCTAssertEqual(controller.view.subviews.count, 1, "Removing the target must remove its overlay")
    }

    @MainActor
    func testExplicitNestedTargetAndReplacement() throws {
        guard SKTopScrollEdgeEffect.isSupported else { throw XCTSkip("Requires iOS 27+ and Xcode 26+") }
        let controller = ConfigurableEdgeController()
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        let container = UIView(frame: controller.view.bounds)
        let first = UIScrollView(frame: container.bounds)
        container.addSubview(first)
        controller.view.addSubview(container)
        controller.target = first
        controller.updateTopScrollEdgeEffect()
        XCTAssertEqual(controller.view.subviews.count, 2)
        let oldOverlay = controller.view.subviews.last
        let second = UIScrollView(frame: container.bounds)
        container.addSubview(second)
        controller.target = second
        controller.updateTopScrollEdgeEffect()
        XCTAssertEqual(controller.view.subviews.count, 2)
        XCTAssertNil(oldOverlay?.superview)
        XCTAssertFalse(controller.view.subviews.last === oldOverlay)
    }

    @MainActor
    func testRootScrollOverlayStaysInViewportAndUpdatesHeight() throws {
        guard SKTopScrollEdgeEffect.isSupported else { throw XCTSkip("Requires iOS 27+ and Xcode 26+") }
        let controller = UIViewController()
        let scroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        controller.view = scroll
        controller.additionalSafeAreaInsets.top = 64
        scroll.contentSize = CGSize(width: 390, height: 2000)
        let effect = SKTopScrollEdgeEffect()
        effect.installIfNeeded(in: controller)
        defer { effect.remove() }
        let overlay = try XCTUnwrap(scroll.subviews.first)
        scroll.layoutIfNeeded()
        effect.updateLayout()
        scroll.layoutIfNeeded()
        XCTAssertFalse(overlay.isUserInteractionEnabled)
        XCTAssertEqual(overlay.frame.height, scroll.safeAreaInsets.top, accuracy: 0.5)
        let originalViewportY = overlay.frame.minY - scroll.bounds.minY
        scroll.contentOffset.y = 200
        scroll.setNeedsLayout()
        scroll.layoutIfNeeded()
        XCTAssertEqual(overlay.frame.minY - scroll.bounds.minY, originalViewportY, accuracy: 0.5)
        controller.additionalSafeAreaInsets.top = 96
        scroll.setNeedsLayout()
        scroll.layoutIfNeeded()
        effect.updateLayout()
        scroll.layoutIfNeeded()
        XCTAssertEqual(overlay.frame.height, scroll.safeAreaInsets.top, accuracy: 0.5)
    }

    #if compiler(>=6.2)
    @MainActor
    func testLargeTitlesAndRemovalRestoreSystemEffects() throws {
        guard #available(iOS 27.0, *) else { throw XCTSkip("Requires iOS 27+") }
        let controller = UIViewController()
        let navigation = UINavigationController(rootViewController: controller)
        controller.loadViewIfNeeded()
        let scroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        controller.view.addSubview(scroll)
        scroll.topEdgeEffect.style = .hard
        scroll.bottomEdgeEffect.style = .automatic
        scroll.topEdgeEffect.isHidden = true
        let effect = SKTopScrollEdgeEffect()
        effect.installIfNeeded(on: scroll, in: controller)
        let overlay = try XCTUnwrap(controller.view.subviews.last)
        XCTAssertTrue(scroll.topEdgeEffect.isHidden)
        XCTAssertFalse(overlay.isHidden)
        navigation.navigationBar.prefersLargeTitles = true
        effect.updateLayout()
        XCTAssertTrue(overlay.isHidden)
        XCTAssertFalse(scroll.topEdgeEffect.isHidden)
        navigation.navigationBar.prefersLargeTitles = false
        effect.updateLayout()
        XCTAssertFalse(overlay.isHidden)
        XCTAssertTrue(scroll.topEdgeEffect.isHidden)
        effect.remove()
        XCTAssertNil(overlay.superview)
        XCTAssertEqual(scroll.topEdgeEffect.style, .hard)
        XCTAssertEqual(scroll.bottomEdgeEffect.style, .automatic)
        XCTAssertTrue(scroll.topEdgeEffect.isHidden)
    }
    #endif
}

private final class ConfigurableEdgeController: SKViewController {
    var isEffectEnabled = true
    var target: UIScrollView?
    override var preferredCustomTopEdgeEffectOverSystemProvidedComponent: Bool { isEffectEnabled }
    override var scrollViewForTopEdgeEffect: UIScrollView? { target }
}
