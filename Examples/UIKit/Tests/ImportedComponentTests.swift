//
//  ImportedComponentTests.swift
//  SKComponentKit
//
//  Created by Suykorng on 22/9/26.
//

import EasyAnchor
import SKComponentKit
import UIKit
import XCTest
@testable import SKComponentKitExample

final class ImportedComponentTests: XCTestCase {
    @MainActor
    func testEveryDemoLoadsAndLaysOutAtPhoneAndTabletSizes() {
        XCTAssertEqual(ImportedComponentDemos.all.count, 12)
        for demo in ImportedComponentDemos.all {
            let host = DemoHostViewController(demo: demo)
            host.loadViewIfNeeded()
            for size in [CGSize(width: 375, height: 812), CGSize(width: 1024, height: 768)] {
                host.view.frame = CGRect(origin: .zero, size: size)
                host.view.setNeedsLayout()
                host.view.layoutIfNeeded()
                XCTAssertEqual(host.children.count, 1, demo.title)
                XCTAssertFalse(host.children[0].view.hasAmbiguousLayout, demo.title)
            }
        }
    }

    @MainActor
    func testButtonSizingAndLoadingState() {
        let parent = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        let button = SKButton.primary(borderStyle: .none)
        button.setTitle("Continue")
        button.layout { parent.addSubview($0); $0.leading(16).trailing(16).centerY() }
        parent.layoutIfNeeded()
        XCTAssertEqual(button.frame.width, 288, accuracy: 0.1)
        XCTAssertEqual(button.frame.height, 52, accuracy: 0.1)
        XCTAssertEqual(button.accessibilityLabel, "Continue")
        button.showsActivityIndicator = true
        XCTAssertFalse(button.isEnabled)
        button.showsActivityIndicator = false
        XCTAssertTrue(button.isEnabled)
        button.size = .small
        button.setNeedsUpdateConfiguration()
        parent.layoutIfNeeded()
        XCTAssertEqual(button.frame.height, 44, accuracy: 0.1)
    }

    @MainActor
    func testPaddingChangesIntrinsicSize() {
        let label = SKPaddingLabel()
        label.text = "Hello"
        label.insets = .zero
        let original = label.intrinsicContentSize
        label.insets = UIEdgeInsets(top: 3, left: 5, bottom: 7, right: 11)
        XCTAssertEqual(label.intrinsicContentSize.width, original.width + 16, accuracy: 0.1)
        XCTAssertEqual(label.intrinsicContentSize.height, original.height + 10, accuracy: 0.1)
    }

    @MainActor
    func testRefreshingDoesNotAccumulateAnimationLayers() {
        let view = SKRefreshingView()
        view.startAnimating()
        XCTAssertTrue(view.isAnimating)
        let count = view.layer.sublayers?.count
        view.startAnimating()
        view.tintColor = .red
        view.tintColor = .blue
        XCTAssertEqual(view.layer.sublayers?.count, count)
        view.stopAnimating()
        XCTAssertFalse(view.isAnimating)
        XCTAssertTrue(view.isHidden)
        XCTAssertTrue(view.layer.sublayers?.isEmpty ?? true)
    }

    @MainActor
    func testZigzagAcceptsZeroAndReusesItsShapeLayer() {
        let view = SKZigzagView(numberOfZigZagLines: 0)
        view.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        for _ in 0..<3 {
            _ = renderer.image { _ in view.draw(view.bounds) }
        }
        XCTAssertEqual(view.layer.sublayers?.count, 1)
    }

    @MainActor
    func testMarqueeDoesNotRetainItselfWhileRunning() {
        weak var reference: SKMarqueeView?
        autoreleasepool {
            let marquee = SKMarqueeView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
            let label = UILabel()
            label.text = "A long marquee label for scrolling"
            marquee.contentView = label
            marquee.layoutIfNeeded()
            marquee.startMarquee()
            reference = marquee
        }
        XCTAssertNil(reference)
    }

    @MainActor
    func testTextFieldPrefixAndCharacterLimit() {
        let field = SKTextField()
        field.setMaximumAllowedCharacters(3)
        field.text = "abc"
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 3, length: 0), replacementString: "d"))
        XCTAssertTrue(field.textField(field, shouldChangeCharactersIn: NSRange(location: 2, length: 1), replacementString: ""))
        field.prefixCharacter = "$"
        field.text = "$12"
        XCTAssertEqual(field.value, "12")
        XCTAssertFalse(field.textField(field, shouldChangeCharactersIn: NSRange(location: 0, length: 1), replacementString: ""))
    }

    @MainActor
    func testScannerFrameHasSingleEasyAnchorConstraintSet() {
        let scanner = SKQRCodeScannerController()
        scanner.loadViewIfNeeded()
        scanner.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        scanner.view.layoutIfNeeded()
        XCTAssertEqual(scanner.rectView.frame.width, 275, accuracy: 0.1)
        XCTAssertEqual(scanner.rectView.frame.height, 275, accuracy: 0.1)
        scanner.view.setNeedsLayout()
        scanner.view.layoutIfNeeded()
        XCTAssertEqual(scanner.rectView.frame.midY, scanner.view.bounds.midY, accuracy: 0.5)
    }
}
