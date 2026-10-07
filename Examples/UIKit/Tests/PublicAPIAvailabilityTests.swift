//
//  PublicAPIAvailabilityTests.swift
//  SKComponentKit
//
//  Created by Suykorng on 23/9/26.
//

import SKComponentKit
import UIKit
import XCTest

/// This client module deliberately uses a normal import to enforce public API access.
final class PublicAPIAvailabilityTests: XCTestCase {
    @MainActor
    func testEveryComponentCanBeConstructedByAClient() {
        let views: [UIView] = [
            SKButton(),
            SKPaddingLabel(frame: .zero),
            SKMarqueeView(),
            SKRefreshingView(frame: .zero),
            SKTextField(frame: .zero),
            SKZigzagView(numberOfZigZagLines: 24),
            SKScrollView(frame: .zero),
            SKCustomIntensityVisualEffectView(effect: UIBlurEffect(style: .systemMaterial), intensity: 0.5),
            SKQRCornerRectangleView(frame: .zero),
        ]
        XCTAssertEqual(views.count, 9)
        let controllers: [UIViewController] = [
            SKViewController(),
            SKScrollViewController(),
            SKDialogueViewController(),
            SKLoadingViewController(),
            SKQRCodeScannerController(),
        ]
        XCTAssertEqual(controllers.count, 5)
        for controller in controllers {
            controller.loadViewIfNeeded()
            XCTAssertNotNil(controller.viewIfLoaded)
        }
    }

    @MainActor
    func testClientCanSubclassExtensibleComponents() {
        XCTAssertFalse(ClientViewController().preferredCustomTopEdgeEffectOverSystemProvidedComponent)
        let effect = SKTopScrollEdgeEffect()
        effect.installIfNeeded(in: ClientViewController())
        effect.updateLayout()
        effect.remove()
        XCTAssertTrue(ClientScrollController().allowedKeyboardObservation)
        XCTAssertEqual(ClientDialogueController().cornerRadius, 20)
        XCTAssertFalse(ClientScannerController().canProcessResult)
        let field = ClientTextField(frame: .zero)
        field.setMaximumAllowedCharacters(20)
        field.setPreferredInputType(.email)
        XCTAssertEqual(field.keyboardType, .emailAddress)
    }

    @MainActor
    func testPublicNetworkMonitorCanStartStopAndRestart() {
        let monitor = SKNetworkConnectivity.current
        defer { monitor.stopMonitor() }
        monitor.startMonitor()
        monitor.startMonitor()
        monitor.stopMonitor()
        XCTAssertFalse(monitor.isConnectedToInternet)
        monitor.startMonitor()
        monitor.stopMonitor()
        XCTAssertFalse(monitor.isConnectedToInternet)
    }
}

private final class ClientViewController: SKViewController {
    override var preferredCustomTopEdgeEffectOverSystemProvidedComponent: Bool { false }
}

private final class ClientScrollController: SKScrollViewController {
    override var allowedKeyboardObservation: Bool { true }
}

private final class ClientDialogueController: SKDialogueViewController {
    override var cornerRadius: CGFloat { 20 }
}

private final class ClientScannerController: SKQRCodeScannerController {
    override var canProcessResult: Bool { false }
}

private final class ClientTextField: SKTextField {}
