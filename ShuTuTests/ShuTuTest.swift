//
//  ShuTuTest.swift
//  ShuTuTests
//
//  Created by yiqiang on 2018/2/26.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import XCTest

@testable import ShuTu
@testable import Moya

class ShuTuTest: XCTestCase {
    
    ///测试用户登录
    func testUserLogin() {
        //同步请求
        let ept = expectation(description: "")
        let timeout = 5 as TimeInterval
        let username = "18959212767"
        let password = "19920213"
        ShuTuProvider2.request(.login(username: username, password: password), completion: { result in
            switch result {
            case .failure(_):
                break
            case .success(let response):
                do {
                    let data = try response.mapJSON() as! Dictionary<String, Any>
                    let code = data["code"] as! Int
                    XCTAssertEqual(code, 0) //登录成功
                } catch {
                    
                }
            }
            ept.fulfill()//请求结束
        })
        //等待请求结束
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
