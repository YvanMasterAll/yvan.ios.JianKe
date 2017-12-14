//
//  Protocol.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/12.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation

public enum Result {
    case ok(message: String)
    case empty
    case failed(message: String)
}

extension Result {
    var isVaild: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}
