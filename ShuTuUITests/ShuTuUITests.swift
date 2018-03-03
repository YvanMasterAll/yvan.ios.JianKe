//
//  ShuTuUITests.swift
//  ShuTuUITests
//
//  Created by yiqiang on 2018/2/26.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import XCTest
@testable import ShuTu

///参考 https://github.com/joemasilotti/UI-Testing-Cheat-Sheet#pull-to-refresh

class ShuTuUITests: XCTestCase {
    
    ///测试话题关注
    func testFollow() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.tables.element(boundBy: 1).cells.staticTexts["举报作弊我错了吗"].exists)
        app.tables.element(boundBy: 1).cells.staticTexts["举报作弊我错了吗"].tap()
        app.buttons["关注"].tap()
        XCTAssertTrue(app.staticTexts["关注成功"].exists)
    }
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
