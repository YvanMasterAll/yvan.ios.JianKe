//
//  DebateAnswerDetailViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/28.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public struct DebateAnswerDetailViewModelInput {
    var refreshData: PublishSubject<Void>
}
public struct DebateAnswerDetailViewModelOutput {
    var section: Observable<AnswerDetail>?
    var emptyStateObserver: Variable<EmptyViewType>
}
class DebateAnswerDetailViewModel {
    fileprivate struct AnswerDetailModel {
        var disposeBag: DisposeBag
        var model: Variable<AnswerDetail>
        var section: Answer
    }
    //私有成员
    fileprivate var answerDetail: AnswerDetailModel!
    fileprivate var service = DebateService.instance
    //inputs
    public var inputs: DebateAnswerDetailViewModelInput! = {
        return DebateAnswerDetailViewModelInput(refreshData: PublishSubject())
    }()
    //outputs
    public var outputs: DebateAnswerDetailViewModelOutput! = {
       return DebateAnswerDetailViewModelOutput(section: nil, emptyStateObserver: Variable<EmptyViewType>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Answer) {
        //初始化
        self.answerDetail = AnswerDetailModel(disposeBag: disposeBag, model: Variable<AnswerDetail>(AnswerDetail()), section: section)
        self.outputs.emptyStateObserver = Variable<EmptyViewType>(.none)
        //Rx
        self.outputs.section = self.answerDetail.model.asObservable()
            .map{ model -> AnswerDetail in
                return model
            }
            .asObservable()
        self.inputs.refreshData.asObserver()
            .subscribe(onNext: {
                //显示加载
                self.outputs.emptyStateObserver.value = .loading(type: .rotate)
                //Request
                self.service.getAnswerDetail(id: section.id!).asObservable()
                    .subscribe(onNext: { response in
                        let data = response.0
                        let result = response.1
                        
                        switch result {
                        case .ok:
                            self.answerDetail.model.value = data
                            break
                        default:
                            self.outputs.emptyStateObserver.value = .empty
                            break
                        }
                    })
                    .disposed(by: self.answerDetail.disposeBag)
            })
            .disposed(by: self.answerDetail.disposeBag)
    }
}
