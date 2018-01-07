//
//  DebateAddNewViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/3.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public struct DebateAddNewViewModelInput {
    var title: PublishSubject<String>
}
public struct DebateAddNewViewModelOutput {
    var titleUsable: Observable<Bool>?
}
public class DebateAddNewViewModel {
    fileprivate struct DebateAddNewModel {
        var disposeBag: DisposeBag
    }
    
    fileprivate let debateAddNew: DebateAddNewModel!
    open var inputs: DebateAddNewViewModelInput! = {
        return DebateAddNewViewModelInput(title: PublishSubject<String>())
    }()
    open var outputs: DebateAddNewViewModelOutput! = {
        return DebateAddNewViewModelOutput(titleUsable: nil)
    }()
    
    init(disposeBag: DisposeBag) {
        self.debateAddNew = DebateAddNewModel(disposeBag: disposeBag)
        //Rx
        self.outputs.titleUsable = self.inputs.title
            .map { title -> Bool in
                if title.count > 0 {
                    return true
                } else {
                    return false
                }
            }
    }
}

