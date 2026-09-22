import XCTest

final class CatalogSmokeTests: XCTestCase {
    @MainActor
    func testPlaygroundAndPreviewControls() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()

        let playground = app.cells["demo.UIKit Playground"].firstMatch
        XCTAssertTrue(playground.waitForExistence(timeout: 10))
        playground.tap()

        let interaction = app.buttons["playgroundButton"]
        XCTAssertTrue(interaction.waitForExistence(timeout: 5))
        interaction.tap()
        XCTAssertEqual(app.staticTexts["tapCount"].label, "Button tapped 1 time")

        let preview = app.buttons["previewSettings"]
        preview.tap()
        let dark = app.buttons["Dark"].firstMatch
        XCTAssertTrue(dark.waitForExistence(timeout: 5))
        dark.tap()

        preview.tap()
        let largeText = app.buttons["Accessibility XXXL"].firstMatch
        XCTAssertTrue(largeText.waitForExistence(timeout: 5))
        largeText.tap()

        // The demo remains reachable and scrollable at accessibility text sizes.
        for _ in 0..<5 where !interaction.isHittable {
            app.scrollViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(interaction.isHittable)
        interaction.tap()
        XCTAssertEqual(app.staticTexts["tapCount"].label, "Button tapped 2 times")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(playground.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSearchFiltersCatalog() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 10))
        XCTAssertTrue(app.cells["demo.UIKit Playground"].exists)
        search.tap()
        search.typeText("no-such-component")
        XCTAssertFalse(app.cells["demo.UIKit Playground"].exists)
    }
}
