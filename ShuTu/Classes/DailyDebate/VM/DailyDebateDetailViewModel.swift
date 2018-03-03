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
}
public struct DailyDebateDetailViewModelOutput {
    var section: Observable<AnswerDetail>?
    var emptyStateObserver: Variable<EmptyViewType>
    var followResult: Variable<Result2>
    var followCheck: Variable<Result2>
}
class DailyDebateDetailViewModel {
    fileprivate struct DebateDetaillModel {
        var disposeBag: DisposeBag
        var section: Debate
    }
    //私有成员
    fileprivate var detailModel: DebateDetaillModel!
    fileprivate var service = DebateService.instance
    //inputs
    public var inputs: DailyDebateDetailViewModelInput! = {
        return DailyDebateDetailViewModelInput(refreshData: PublishSubject(), followTap: PublishSubject(), followCheck: PublishSubject())
    }()
    //outputs
    public var outputs: DailyDebateDetailViewModelOutput! = {
        return DailyDebateDetailViewModelOutput(section: nil, emptyStateObserver: Variable<EmptyViewType>(.none), followResult: Variable<Result2>(.empty), followCheck: Variable<Result2>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Debate) {
        //初始化
        self.detailModel = DebateDetaillModel(disposeBag: disposeBag, section: section)
        self.outputs.emptyStateObserver = Variable<EmptyViewType>(.none)
        //Rx
        self.inputs.followCheck.asObserver()
            .subscribe(onNext: {
                guard Environment.tokenExists  else {
                    return
                }
                self.service.followCheck(self.detailModel.section.id!).asObservable()
                    .subscribe(onNext: { result in
                        self.outputs.followCheck.value = result
                    })
                    .disposed(by: self.detailModel.disposeBag)
            })
            .disposed(by: self.detailModel.disposeBag)
        self.inputs.followTap.asObserver()
            .subscribe(onNext: { add in
                guard Environment.tokenExists  else {
                    HUD.flash(.label("请先登录"))
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
