//
//  MeSpaceViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/10.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public struct MeSpaceDynamicViewModelInput {
    var refreshNewData: PublishSubject<Bool>
}
public struct MeSpaceDynamicViewModelOutput {
    var sections: Driver<[MeSpaceDynamicSectionModel]>?
    var refreshStateObserver: Variable<RefreshStatus>
}
public class MeSpaceDynamicViewModel {
    fileprivate struct MeSpaceDynamicModel {
        var pageIndex: Int
        var section: Auth
        var disposeBag: DisposeBag
        var models: Variable<[Debate]>
    }
    //私有成员
    fileprivate var dynamicModel: MeSpaceDynamicModel!
    fileprivate var service = DebateService.instance
    //Inputs
    open var inputs: MeSpaceDynamicViewModelInput = {
        return MeSpaceDynamicViewModelInput(refreshNewData: PublishSubject<Bool>())
    }()
    //Outputs
    open var outputs: MeSpaceDynamicViewModelOutput = {
        return MeSpaceDynamicViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Auth) {
        self.dynamicModel = MeSpaceDynamicModel(pageIndex: 0, section: section, disposeBag: disposeBag, models: Variable<[Debate]>([]))
        //Rx
        self.outputs.sections = self.dynamicModel.models.asObservable()
            .map{ models in
                return [MeSpaceDynamicSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    self.outputs.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.dynamicModel.pageIndex = 0
                    //拉取数据
                    self.service.getDebate(pageIndex: self.dynamicModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                self.dynamicModel.models.value.removeAll()
                                self.dynamicModel.models.value = data
                                //结束刷新
                                self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                break
                            default:
                                //请求错误
                                self.outputs.refreshStateObserver.value = .noData
                                break
                            }
                        })
                        .disposed(by: self.dynamicModel.disposeBag)
                } else {//加载更多
                    self.dynamicModel.pageIndex += 1
                    //拉取数据
                    self.service.getDebate(pageIndex: self.dynamicModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.dynamicModel.models.value += data
                                    //结束刷新
                                    self.outputs.refreshStateObserver.value = .endFooterRefresh
                                } else {
                                    //没有更多数据
                                    self.outputs.refreshStateObserver.value = .endRefreshWithoutData
                                }
                                break
                            default:
                                //没有更多数据
                                self.outputs.refreshStateObserver.value = .endRefreshWithoutData
                                break
                            }
                        })
                        .disposed(by: self.dynamicModel.disposeBag)
                }
            })
            .disposed(by: dynamicModel.disposeBag)
    }
}

public struct MeSpaceDynamicSectionModel {
    public var items: [item]
}

extension MeSpaceDynamicSectionModel: SectionModelType {
    public typealias item = Debate
    
    public init(original: MeSpaceDynamicSectionModel, items: [MeSpaceDynamicSectionModel.item]) {
        self = original
        self.items = items
    }
}

public struct MeSpaceQuizViewModelInput {
    var refreshNewData: PublishSubject<Bool>
}
public struct MeSpaceQuizViewModelOutput {
    var sections: Driver<[MeSpaceQuizSectionModel]>?
    var refreshStateObserver: Variable<RefreshStatus>
}
public class MeSpaceQuizViewModel {
    fileprivate struct MeSpaceQuizModel {
        var pageIndex: Int
        var section: Auth
        var disposeBag: DisposeBag
        var models: Variable<[Debate]>
    }
    //私有成员
    fileprivate var quizModel: MeSpaceQuizModel!
    fileprivate var service = DebateService.instance
    //Inputs
    open var inputs: MeSpaceQuizViewModelInput = {
        return MeSpaceQuizViewModelInput(refreshNewData: PublishSubject<Bool>())
    }()
    //Outputs
    open var outputs: MeSpaceQuizViewModelOutput = {
        return MeSpaceQuizViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Auth) {
        self.quizModel = MeSpaceQuizModel(pageIndex: 0, section: section, disposeBag: disposeBag, models: Variable<[Debate]>([]))
        //Rx
        self.outputs.sections = self.quizModel.models.asObservable()
            .map{ models in
                return [MeSpaceQuizSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                self.outputs.refreshStateObserver.value = .noData
            })
            .disposed(by: quizModel.disposeBag)
    }
}

public struct MeSpaceQuizSectionModel {
    public var items: [item]
}

extension MeSpaceQuizSectionModel: SectionModelType {
    public typealias item = Debate
    
    public init(original: MeSpaceQuizSectionModel, items: [MeSpaceQuizSectionModel.item]) {
        self = original
        self.items = items
    }
}

public struct MeSpaceAnswerViewModelInput {
    var refreshNewData: PublishSubject<Bool>
}
public struct MeSpaceAnswerViewModelOutput {
    var sections: Driver<[MeSpaceAnswerSectionModel]>?
    var refreshStateObserver: Variable<RefreshStatus>
}
public class MeSpaceAnswerViewModel {
    fileprivate struct MeSpaceAnswerModel {
        var pageIndex: Int
        var section: Auth
        var disposeBag: DisposeBag
        var models: Variable<[Debate]>
    }
    //私有成员
    fileprivate var answerModel: MeSpaceAnswerModel!
    fileprivate var service = DebateService.instance
    //Inputs
    open var inputs: MeSpaceAnswerViewModelInput = {
        return MeSpaceAnswerViewModelInput(refreshNewData: PublishSubject<Bool>())
    }()
    //Outputs
    open var outputs: MeSpaceAnswerViewModelOutput = {
        return MeSpaceAnswerViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Auth) {
        self.answerModel = MeSpaceAnswerModel(pageIndex: 0, section: section, disposeBag: disposeBag, models: Variable<[Debate]>([]))
        //Rx
        self.outputs.sections = self.answerModel.models.asObservable()
            .map{ models in
                return [MeSpaceAnswerSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                self.outputs.refreshStateObserver.value = .noData
            })
            .disposed(by: answerModel.disposeBag)
    }
}

public struct MeSpaceAnswerSectionModel {
    public var items: [item]
}

extension MeSpaceAnswerSectionModel: SectionModelType {
    public typealias item = Debate
    
    public init(original: MeSpaceAnswerSectionModel, items: [MeSpaceAnswerSectionModel.item]) {
        self = original
        self.items = items
    }
}
