//
//  DebateAnswerAddNewViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2018/2/12.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public struct DebateAnswerAddNewViewModelInput {
    var sendTap: PublishSubject<(Int, String, AnswerSide)>
}
public struct DebateAnswerAddNewViewModelOutput {
    var sendResult: Variable<Result2>
}
public class DebateAnswerAddNewViewModel {
    fileprivate struct DebateAnswerAddNewModel {
        var disposeBag: DisposeBag
    }
    
    fileprivate let answerAddNew: DebateAnswerAddNewModel!
    fileprivate let service = DebateService.instance
    open var inputs: DebateAnswerAddNewViewModelInput! = {
        return DebateAnswerAddNewViewModelInput(sendTap: PublishSubject<(Int, String, AnswerSide)>())
    }()
    open var outputs: DebateAnswerAddNewViewModelOutput! = {
        return DebateAnswerAddNewViewModelOutput(sendResult: Variable<Result2>(.none))
    }()
    
    init(disposeBag: DisposeBag) {
        self.answerAddNew = DebateAnswerAddNewModel(disposeBag: disposeBag)
        //Rx
        self.inputs.sendTap
            .asObserver()
            .subscribe(onNext: { (topicid, viewpoint, side) in
                self.service.answerAdd(topicid, side, viewpoint)
                    .asObservable()
                    .subscribe(onNext: { result in
                        self.outputs.sendResult.value = result
                    })
                    .disposed(by: self.answerAddNew.disposeBag)
            })
            .disposed(by: self.answerAddNew.disposeBag)
    }
}
