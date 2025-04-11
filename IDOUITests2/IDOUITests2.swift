//
//  IDOUITests2.swift
//  IDOUITests2
//
//  Created by George Zorakis on 11/4/25.
//

import XCTest

@MainActor
final class IDOUITests2: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
 
    }

    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"/*, "SIGNED_IN"*/]
        app.launch()
        
        // WelcomeView
        app.buttons["Get Started"].tap()
        
        // OnboardingIntroView
        app.buttons["Continue"].tap()
        
        // OnboardingInfoView
        app.staticTexts["Groom"].tap()
        let field = app.textFields["Name"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("George")
        app.datePickers.firstMatch.tap()
        app.buttons["DatePicker.NextMonth"].tap()
        sleep(1)
        app.staticTexts["31"].tap()
        let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        coordinate.tap()
        app.buttons["Continue"].tap()
        
        // OnboardingCompletedView
        app.buttons["Let's get started!"].tap()
        
        let categoriesExists = app.navigationBars["Categories"].exists
        XCTAssertTrue(categoriesExists)
    }
}
