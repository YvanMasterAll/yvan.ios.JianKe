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
}
public struct DailyDebateDetailViewModelOutput {
    var section: Observable<AnswerDetail>?
    var emptyStateObserver: Variable<EmptyViewType>
}
class DailyDebateDetailViewModel {
    fileprivate struct DebateDetaillModel {
        var disposeBag: DisposeBag
        var model: Variable<AnswerDetail>
        var section: Answer
    }
    //私有成员
    fileprivate var detailModel: DebateDetaillModel!
    fileprivate var service = DebateService.instance
    //inputs
    public var inputs: DailyDebateDetailViewModelInput! = {
        return DailyDebateDetailViewModelInput(refreshData: PublishSubject())
    }()
    //outputs
    public var outputs: DailyDebateDetailViewModelOutput! = {
        return DailyDebateDetailViewModelOutput(section: nil, emptyStateObserver: Variable<EmptyViewType>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Answer) {
        //初始化
        self.detailModel = DebateDetaillModel(disposeBag: disposeBag, model: Variable<AnswerDetail>(AnswerDetail()), section: section)
        self.outputs.emptyStateObserver = Variable<EmptyViewType>(.none)
        //Rx
        self.outputs.section = self.detailModel.model.asObservable()
            .map{ model -> AnswerDetail in
                return model
            }
            .asObservable()
        self.inputs.refreshData.asObserver()
            .subscribe(onNext: {
                //显示加载
                self.outputs.emptyStateObserver.value = .loading(type: .indicator1)
                //Request
                self.service.getAnswerDetail(id: 0).asObservable()
                    .subscribe(onNext: { response in
                        let data = response.0
                        let result = response.1
                        
                        switch result {
                        case .ok:
                            self.detailModel.model.value = data
                            break
                        default:
                            self.outputs.emptyStateObserver.value = .empty
                            break
                        }
                    })
                    .disposed(by: self.detailModel.disposeBag)
            })
            .disposed(by: self.detailModel.disposeBag)
    }
}
