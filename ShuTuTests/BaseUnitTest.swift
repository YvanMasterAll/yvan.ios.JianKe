//
//  BaseUnitTest.swift
//  ShuTuTests
//
//  Created by yiqiang on 2018/3/21.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import XCTest
import Foundation

///单元测试帮助类

class BaseUnitTest: XCTestCase {
    
    ///睡眠
    func sleep(_ time: Double) {
        let _ = expectation(description: "")
        waitForExpectations(timeout: time as TimeInterval, handler: nil)
    }
    
}
