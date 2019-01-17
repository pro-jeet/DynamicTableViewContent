//
//  DynamicTableViewContentUITests.swift
//  DynamicTableViewContentUITests
//
//  Created by Jitesh Sharma on 14/01/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import XCTest

class DynamicTableViewContentUITests: XCTestCase {
    
    let errorTitle: String = "ERROR !"
    let errorMessageForNoInternet: String = "⚠️ No Internet Connection"
    let errorMessageForNoServiceFailure: String = "⚠️ Something Went Wrong!"
    let errorMessageForNoData: String = "⚠️ No Data Available!"
    let okTitle = "OK"
    
    var app: XCUIApplication!
    let controllerMock = UIViewController()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAlertPresenter() {
        
        let presenter = AlertPresenter(
            alertMessage: errorMessageForNoServiceFailure,
            alertTitle: errorTitle
        )
        presenter.displaAlert(in: controllerMock)
        XCTAssertTrue(app.alerts.element.exists)
        
        app.alerts.element.buttons[okTitle].tap()
        XCTAssertFalse(app.alerts.element.exists)
    }
    
}
