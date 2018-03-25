//
//  DailyDebateDetailViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/11.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public struct DailyDebateDetailViewModelInput {
    var refreshData: PublishSubject<Void>
    var followTap: PublishSubject<Bool>
    var followCheck: PublishSubject<Void>
    var answerCheck: PublishSubject<Void>
}
public struct DailyDebateDetailViewModelOutput {
    var section: Observable<AnswerDetail>?
    var followResult: Variable<ResultType>
    var followCheck: Variable<ResultType>
    var answerCheck: Variable<ResultType>
}
class DailyDebateDetailViewModel {

    //MARK: - 私有成员
    fileprivate struct DebateDetaillModel {
        var disposeBag: DisposeBag
        var section: Debate
    }
    fileprivate var detailModel: DebateDetaillModel!
    fileprivate var service = DebateService.instance

    //MARK: - inputs
    public var inputs: DailyDebateDetailViewModelInput! = {
        return DailyDebateDetailViewModelInput(refreshData: PublishSubject(), followTap: PublishSubject(), followCheck: PublishSubject(), answerCheck: PublishSubject())
    }()
    
    //MARK: - outputs
    public var outputs: DailyDebateDetailViewModelOutput! = {
        return DailyDebateDetailViewModelOutput(section: nil, followResult: Variable<ResultType>(.empty), followCheck: Variable<ResultType>(.none), answerCheck: Variable<ResultType>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Debate) {
        self.detailModel = DebateDetaillModel(disposeBag: disposeBag, section: section)
        //Rx
        self.inputs.followCheck.asObserver()
            .subscribe(onNext: {
                guard ServiceUtil.loginCheck() else {
                    return
                }
                self.service.followCheck(self.detailModel.section.id!).asObservable()
                    .subscribe(onNext: { result in
                        self.outputs.followCheck.value = result
                    })
                    .disposed(by: self.detailModel.disposeBag)
            })
            .disposed(by: self.detailModel.disposeBag)
        self.inputs.answerCheck.asObserver()
            .subscribe(onNext: {
                guard ServiceUtil.loginCheck(true)  else {
                    return
                }
                HUD.show(.progress)
                self.service.answerCheck(self.detailModel.section.id!).asObservable()
                    .subscribe(onNext: { result in
                        HUD.hide()
                        self.outputs.answerCheck.value = result
                    })
                    .disposed(by: self.detailModel.disposeBag)
            })
            .disposed(by: self.detailModel.disposeBag)
        self.inputs.followTap.asObserver()
            .subscribe(onNext: { add in
                guard ServiceUtil.loginCheck(true)  else {
                    return
                }
                HUD.show(.progress)
                if add {
                    self.service.followAdd(self.detailModel.section.id!, Toggle.on)
                        .subscribe(onNext: { result in
                            HUD.hide()
                            self.outputs.followResult.value = result
                        })
                        .disposed(by: self.detailModel.disposeBag)
                } else {
                    self.service.followAdd(self.detailModel.section.id!, Toggle.off)
                        .subscribe(onNext: { result in
                            HUD.hide()
                            self.outputs.followResult.value = result
                        })
                        .disposed(by: self.detailModel.disposeBag)
                }
            })
            .disposed(by: self.detailModel.disposeBag)
    }
}
