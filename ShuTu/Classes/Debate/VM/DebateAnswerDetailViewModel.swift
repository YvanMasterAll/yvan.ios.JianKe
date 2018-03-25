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
    var followTap: PublishSubject<Bool>
    var followCheck: PublishSubject<Void>
    var attitudeCheck: PublishSubject<Void>
    var attitudeTap: PublishSubject<(AttitudeStand, Bool)>
}
public struct DebateAnswerDetailViewModelOutput {
    var section: Observable<AnswerDetail>?
    var emptyStateObserver: Variable<STEmptyViewType>
    var followResult: Variable<ResultType>
    var followCheck: Variable<ResultType>
    var attitudeResult: Variable<AnswerAttitude>
}
class DebateAnswerDetailViewModel {

    //MARK: - 私有成员
    fileprivate struct AnswerDetailModel {
        var disposeBag: DisposeBag
        var model: Variable<AnswerDetail>
        var section: Answer
    }
    fileprivate var answerDetail: AnswerDetailModel!
    fileprivate var service = DebateService.instance
    fileprivate var fservice = FriendService.instance

    //MARK: - inputs
    public var inputs: DebateAnswerDetailViewModelInput! = {
        return DebateAnswerDetailViewModelInput(refreshData: PublishSubject(), followTap: PublishSubject(), followCheck: PublishSubject(), attitudeCheck: PublishSubject(), attitudeTap: PublishSubject())
    }()
    
    //MARK: - outputs
    public var outputs: DebateAnswerDetailViewModelOutput! = {
        return DebateAnswerDetailViewModelOutput(section: nil, emptyStateObserver: Variable<STEmptyViewType>(.none), followResult: Variable<ResultType>(.empty), followCheck: Variable<ResultType>(.none), attitudeResult: Variable<AnswerAttitude>(AnswerAttitude.init()))
    }()
    
    init(disposeBag: DisposeBag, section: Answer) {
        //初始化
        self.answerDetail = AnswerDetailModel(disposeBag: disposeBag, model: Variable<AnswerDetail>(AnswerDetail()), section: section)
        self.outputs.emptyStateObserver = Variable<STEmptyViewType>(.none)
        //Rx
        self.outputs.section = self.answerDetail.model.asObservable()
            .map{ model -> AnswerDetail in
                return model
            }
            .asObservable()
        self.inputs.refreshData.asObserver()
            .subscribe(onNext: {
                //显示加载
                self.outputs.emptyStateObserver.value = .loading(type: .indicator1)
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
                            self.outputs.emptyStateObserver.value = .empty(type: .box, options: nil)
                            break
                        }
                    })
                    .disposed(by: self.answerDetail.disposeBag)
            })
            .disposed(by: self.answerDetail.disposeBag)
        self.inputs.attitudeCheck.asObserver()
            .subscribe(onNext: {
                guard ServiceUtil.loginCheck()  else {
                    return
                }
                self.service.attitudeCheck(self.answerDetail.section.id!).asObservable()
                    .subscribe(onNext: { response in
                        let result = response.1
                        let data = response.0
                        switch result {
                        case .ok:
                            self.outputs.attitudeResult.value = data!
                        default:
                            break
                        }
                    })
                    .disposed(by: self.answerDetail.disposeBag)
            })
            .disposed(by: self.answerDetail.disposeBag)
        self.inputs.attitudeTap.asObserver()
            .subscribe(onNext: { (attitude, add) in
                guard ServiceUtil.loginCheck(true)  else {
                    return
                }
                HUD.show(.progress)
                if add {
                    self.service.attitudeAdd(self.answerDetail.section.id!, attitude: attitude, type: AttitudeType.viewpoint, toggle: Toggle.on)
                        .subscribe(onNext: { response in
                            HUD.hide()
                            let result = response.1
                            let data = response.0
                            switch result {
                            case .ok:
                                self.outputs.attitudeResult.value = data!
                            default:
                                break
                            }
                        })
                        .disposed(by: self.answerDetail.disposeBag)
                } else {
                    self.service.attitudeAdd(self.answerDetail.section.id!, attitude: attitude, type: AttitudeType.viewpoint, toggle: Toggle.off)
                        .subscribe(onNext: { response in
                            HUD.hide()
                            let result = response.1
                            let data = response.0
                            switch result {
                            case .ok:
                                self.outputs.attitudeResult.value = data!
                            default:
                                break
                            }
                        })
                        .disposed(by: self.answerDetail.disposeBag)
                }
            })
            .disposed(by: self.answerDetail.disposeBag)
        self.inputs.followCheck.asObserver()
            .subscribe(onNext: {
                guard ServiceUtil.loginCheck(), let id = self.answerDetail.section.userid else {
                    return
                }
                self.fservice.followCheck(id).asObservable()
                    .subscribe(onNext: { result in
                        self.outputs.followCheck.value = result
                    })
                    .disposed(by: self.answerDetail.disposeBag)
            })
            .disposed(by: self.answerDetail.disposeBag)
        self.inputs.followTap.asObserver()
            .subscribe(onNext: { add in
                guard ServiceUtil.loginCheck(true), let id = self.answerDetail.section.userid  else {
                    return
                }
                HUD.show(.progress)
                if add {
                    self.fservice.followAdd(id, Toggle.on)
                        .subscribe(onNext: { result in
                            HUD.hide()
                            self.outputs.followResult.value = result
                        })
                        .disposed(by: self.answerDetail.disposeBag)
                } else {
                    self.fservice.followAdd(id, Toggle.off)
                        .subscribe(onNext: { result in
                            HUD.hide()
                            self.outputs.followResult.value = result
                        })
                        .disposed(by: self.answerDetail.disposeBag)
                }
            })
            .disposed(by: self.answerDetail.disposeBag)
    }
}
