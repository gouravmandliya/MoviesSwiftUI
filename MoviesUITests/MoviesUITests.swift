//
//  MoviesUITests.swift
//  MoviesUITests
//
//  Created by Gourav Mandliya on 10/12/25.
//

import XCTest

final class MoviesUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testMoviesAppUI() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for content
        let listScroll = app.scrollViews["movieList.scroll"]
    
        // Wait for list content to appear
        XCTAssertTrue(listScroll.waitForExistence(timeout: 10), "List content will take time to appear")

        // Find a row using identifier pattern movieList.row.<id>
        // Search across all element types and wait for it to appear to avoid flakiness.
        let firstRow = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH 'movieList.row.'"))
            .element(boundBy: 0)

        if firstRow.waitForExistence(timeout: 10) {
            firstRow.tap()
        } else {
            // No rows available (e.g., offline). Verify error view instead and exit early.
            XCTAssertTrue(app.otherElements["movieList.error"].exists, "Expected error view if no rows are available")
            return
        }

        // Now on detail view, wait for either loading or content
        let detailScroll = app.scrollViews["movieDetail.scroll"]

        // Wait for detail content to appear
        XCTAssertTrue(detailScroll.waitForExistence(timeout: 10), "Detail content will take time to appear")

        // Assert key elements exist by identifiers
        let title = app.staticTexts["movieDetail.titleText"]
        XCTAssertTrue(title.exists)

        let rating = app.staticTexts["movieDetail.ratingText"]
        XCTAssertTrue(rating.exists)

        let runtime = app.staticTexts["movieDetail.runtimeText"]
        XCTAssertTrue(runtime.exists)

        let overviewHeader = app.staticTexts["movieDetail.overviewHeader"]
        XCTAssertTrue(overviewHeader.exists)
        
        let overviewText = app.staticTexts["movieDetail.overviewText"]
        XCTAssertTrue(overviewText.exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

