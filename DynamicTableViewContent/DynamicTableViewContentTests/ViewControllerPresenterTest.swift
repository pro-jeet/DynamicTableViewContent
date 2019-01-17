//
//  ViewControllerPresenterTest.swift
//  DynamicTableViewContentTests
//
//  Created by Jitesh Sharma on 15/01/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import XCTest

class ViewControllerPresenterTest: XCTestCase {
    
    let emptyServiceString = ""
    let serviceStringMock = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
    let badServiceStringMock = "https://dl.dropboxusercont"
    
    
    
    let controllerMock = UIViewController()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func readDataFromMockJson() -> InfoModel? {
        
        let urlBar = Bundle.main.url(forResource: "MockInfoModelData", withExtension: "geojson")!
        
        do {
            let jsonData = try Data(contentsOf: urlBar)
            let infoModel = try? JSONDecoder().decode(InfoModel.self, from: jsonData)
            return infoModel
        } catch { XCTFail("Missing Mock Json file: MockInfoModelData.json") }
        return nil
    }
    
    func testWithValidURL() {
        
        // Initializing viewControllerPresenter with Valid URL
        let viewControllerPresenter = ViewControllerPresenter(serviceString: serviceStringMock)
        // Attaching viewControllerPresenter with Mock UIViewController
        viewControllerPresenter.attachedController(controler: controllerMock)
        viewControllerPresenter.getDataFromService(completionHandler: { (status, rows, title) in
            
            XCTAssertTrue(status)
            XCTAssertNotNil(rows)
            XCTAssertNotNil(title)
            let mockData = self.readDataFromMockJson()
            XCTAssertEqual(mockData?.title, title)
            viewControllerPresenter.detachController()
        
        })
    }
    
    func testWithBadValidURL() {
        
        // Initializing viewControllerPresenter with Valid URL
        let viewControllerPresenter = ViewControllerPresenter(serviceString: badServiceStringMock)
        // Attaching viewControllerPresenter with Mock UIViewController
        viewControllerPresenter.attachedController(controler: controllerMock)
        viewControllerPresenter.getDataFromService(completionHandler: { (status, rows, title) in
            XCTAssertFalse(status)
            viewControllerPresenter.detachController()
        })
    }
    
    func testWithEmptyValidURL() {
        
        // Initializing viewControllerPresenter with Valid URL
        let viewControllerPresenter = ViewControllerPresenter(serviceString: emptyServiceString)
        // Attaching viewControllerPresenter with Mock UIViewController
        viewControllerPresenter.attachedController(controler: controllerMock)
        viewControllerPresenter.getDataFromService(completionHandler: { (status, rows, title) in
            XCTAssertFalse(status)
            viewControllerPresenter.detachController()
        })
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
