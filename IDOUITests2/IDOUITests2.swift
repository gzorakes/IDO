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
        
        // CategoriesView
        let categoriesExists = app.navigationBars["Categories"].exists
        XCTAssertTrue(categoriesExists)
    }
    
    
    func testTabBarFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()
        
        // CategoriesView
        let categoriesExists = app.navigationBars["Categories"].exists
        XCTAssertTrue(categoriesExists)
        
        app.buttons["person"].tap()
        let profileExists = app.navigationBars["Account"].exists
        XCTAssertTrue(profileExists)
        
        app.buttons["list.clipboard"].tap()
        XCTAssertTrue(categoriesExists)
        
        app.images["eventhall2"].tap()
        
        let categoriesButton = app.buttons["Categories"]
        categoriesButton.tap()
        app.images["church2"].tap()
        categoriesButton.tap()
        app.images["guests2"].tap()
        categoriesButton.tap()
    }
    
    
    func testAddingItem() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()
        
        // CategoriesView
        let categoriesExists = app.navigationBars["Categories"].exists
        XCTAssertTrue(categoriesExists)
        
        app.images["eventhall2"].tap()
        app.buttons["square.and.pencil"].tap()
        app.navigationBars["Add Note"].tap()
        
        let field = app.textFields["Type..."]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("Adding a note")
        
        app.buttons["square.and.arrow.down"].tap()
        
        let firstCell = app.cells.firstMatch
//        XCTAssertTrue(firstCell.waitForExistence(timeout: 3))
        
        firstCell.swipeLeft()
        
        let deleteButton = app.buttons["Delete"]
//        XCTAssertTrue(deleteButton.waitForExistence(timeout: 3))
        deleteButton.tap()
    }
    
    
    func testSignOutFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()
        
        // CategoriesView
        let categoriesExists = app.navigationBars["Categories"].exists
        XCTAssertTrue(categoriesExists)
        
        app.buttons["person"].tap()
        let accountExists = app.navigationBars["Account"].exists
        XCTAssertTrue(accountExists)
        
        app.buttons["Account"].tap()
        app.buttons["Sign Out"].tap()
        
        let startButton = app.buttons["Get Started"].waitForExistence(timeout: 2)
        XCTAssertTrue(startButton)
    }
}
