//
//  DebateDetailViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2017/12/24.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public struct DebateDetailViewModelInput {
    var refreshNewData: PublishSubject<Bool>
}
public struct DebateDetailViewModelOutput {
    var sections: Driver<[DebateDetailSectionModel]>?
    var refreshStateObserver: Variable<RefreshStatus>
}
class DebateDetailViewModel {

    //MARK: - 私有成员
    fileprivate struct DebateAnswerModel {
        var pageIndex: Int
        var models: Variable<[Answer]>
        var disposeBag: DisposeBag
    }
    fileprivate var answerY:  DebateAnswerModel!
    fileprivate var answerS: DebateAnswerModel!
    fileprivate var service = DebateService.instance

    //MARK: - inputs
    public var section: Debate!
    public var inputsY: DebateDetailViewModelInput!
    public var inputsS: DebateDetailViewModelInput!
    
    //MARK: - outputs
    public var outputsY: DebateDetailViewModelOutput!
    public var outputsS: DebateDetailViewModelOutput!
    
    init(section: Debate) {
        //初始化
        self.section = section
        self.inputsY = DebateDetailViewModelInput(refreshNewData: PublishSubject<Bool>())
        self.inputsS = DebateDetailViewModelInput(refreshNewData: PublishSubject<Bool>())
        self.outputsY = DebateDetailViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
        self.outputsS = DebateDetailViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }
    
    //MARK: - 初始化
    public func initAnswerY(disposeBag: DisposeBag) {
        self.answerY = DebateAnswerModel(pageIndex: 0, models: Variable<[Answer]>([]), disposeBag: disposeBag )
        //Rx
        self.outputsY.sections = self.answerY.models.asObservable()
            .map{ models -> [DebateDetailSectionModel] in
                return [DebateDetailSectionModel(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputsY.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full { //头部刷新
                    self.outputsY.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.answerY.pageIndex = 1
                    //拉取数据
                    self.service.getAnswer(id: self.section.id!, pageIndex: self.answerY.pageIndex, side: .SY)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.answerY.models.value.removeAll()
                                    self.answerY.models.value = data
                                    //结束刷新
                                    self.outputsY.refreshStateObserver.value = .endHeaderRefresh
                                } else {
                                    self.outputsY.refreshStateObserver.value = .noData
                                }
                            default:
                                self.outputsY.refreshStateObserver.value = .noNet
                            }
                        })
                        .disposed(by: self.answerY.disposeBag)
                } else { //加载更多
                    self.answerY.pageIndex += 1
                    //拉取数据
                    self.service.getAnswer(id: self.section.id!, pageIndex: self.answerY.pageIndex, side: .SY)
                        .subscribe(onNext: { response in
                            let data = response.0
                            //let result = response.1
                            if data.count > 0 {
                                self.answerY.models.value += data
                                //结束刷新
                                self.outputsY.refreshStateObserver.value = .endFooterRefresh
                            } else { //没有更多数据
                                //结束刷新
                                self.outputsY.refreshStateObserver.value = .endRefreshWithoutData
                            }
                        })
                        .disposed(by: self.answerY.disposeBag)
                }
            })
            .disposed(by: self.answerY.disposeBag)
    }
    public func initAnswerS(disposeBag: DisposeBag) {
        self.answerS = DebateAnswerModel(pageIndex: 0, models: Variable<[Answer]>([]), disposeBag: disposeBag)
        //Rx
        self.outputsS.sections = self.answerS.models.asObservable()
            .map{ models -> [DebateDetailSectionModel] in
                return [DebateDetailSectionModel(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputsS.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full { //头部刷新
                    self.outputsS.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.answerS.pageIndex = 1
                    //拉取数据
                    self.service.getAnswer(id: self.section.id!, pageIndex: self.answerS.pageIndex, side: .ST)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.answerS.models.value.removeAll()
                                    self.answerS.models.value = data
                                    //结束刷新
                                    self.outputsS.refreshStateObserver.value = .endHeaderRefresh
                                } else {
                                    //没有数据
                                    self.outputsS.refreshStateObserver.value = .noData
                                }
                            default:
                                self.outputsS.refreshStateObserver.value = .noNet
                            }
                        })
                        .disposed(by: self.answerS.disposeBag)
                } else { //加载更多
                    self.answerS.pageIndex += 1
                    //拉取数据
                    self.service.getAnswer(id: self.section.id!, pageIndex: self.answerS.pageIndex, side: .SY)
                        .subscribe(onNext: { response in
                            let data = response.0
                            // let result = response.1
                            if data.count > 0 {
                                self.answerS.models.value += data
                                //结束刷新
                                self.outputsS.refreshStateObserver.value = .endFooterRefresh
                            } else { //没有更多数据
                                //结束刷新
                                self.outputsS.refreshStateObserver.value = .endRefreshWithoutData
                            }
                        })
                        .disposed(by: self.answerS.disposeBag)
                }
            })
            .disposed(by: self.answerS.disposeBag)
    }
}

public struct DebateDetailSectionModel {
    public var items: [item]
}

extension DebateDetailSectionModel: SectionModelType {
    public typealias item = Answer
    
    public init(original: DebateDetailSectionModel, items: [DebateDetailSectionModel.item]) {
        self = original
        self.items = items
    }
}

public struct DebateDetailViewModelInput2 {
    var followTap: PublishSubject<Bool>
    var followCheck: PublishSubject<Void>
    var answerCheck: PublishSubject<Void>
}
public struct DebateDetailViewModelOutput2 {
    var followResult: Variable<ResultType>
    var followCheck: Variable<ResultType>
    var answerCheck: Variable<ResultType>
}
class DebateDetailViewModel2 {

    //MARK: - 私有成员
    fileprivate struct DebateDetaillModel {
        var disposeBag: DisposeBag
        var section: Debate
    }
    fileprivate var detailModel: DebateDetaillModel!
    fileprivate var service = DebateService.instance
    
    //MARK: - inputs
    public var inputs: DebateDetailViewModelInput2! = {
        return DebateDetailViewModelInput2(followTap: PublishSubject(), followCheck: PublishSubject(), answerCheck: PublishSubject())
    }()

    //MARK: - outputs
    public var outputs: DebateDetailViewModelOutput2! = {
        return DebateDetailViewModelOutput2(followResult: Variable<ResultType>(.empty), followCheck: Variable<ResultType>(.none), answerCheck: Variable<ResultType>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Debate) {
        //初始化
        self.detailModel = DebateDetaillModel(disposeBag: disposeBag, section: section)
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


