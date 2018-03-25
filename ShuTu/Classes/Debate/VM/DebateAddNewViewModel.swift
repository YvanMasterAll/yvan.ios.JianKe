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
    var sendTap: PublishSubject<(String, String)>
}
public struct DebateAddNewViewModelOutput {
    var titleUsable: Observable<Bool>?
     var sendResult: Variable<ResultType>
}
public class DebateAddNewViewModel {
    fileprivate struct DebateAddNewModel {
        var disposeBag: DisposeBag
    }
    
    fileprivate let debateAddNew: DebateAddNewModel!
    fileprivate let service = DebateService.instance
    open var inputs: DebateAddNewViewModelInput! = {
        return DebateAddNewViewModelInput(title: PublishSubject<String>(), sendTap: PublishSubject<(String, String)>())
    }()
    open var outputs: DebateAddNewViewModelOutput! = {
        return DebateAddNewViewModelOutput(titleUsable: nil, sendResult: Variable<ResultType>(.none))
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
        self.inputs.sendTap
            .asObserver()
            .subscribe(onNext: { (title, content) in
                self.service.topicAdd(title, content)
                    .asObservable()
                    .subscribe(onNext: { result in
                        self.outputs.sendResult.value = result
                    })
                    .disposed(by: self.debateAddNew.disposeBag)
            })
            .disposed(by: self.debateAddNew.disposeBag)
    }
}

