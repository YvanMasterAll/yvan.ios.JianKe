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

    //MARK: - 私有成员
    fileprivate struct MeSpaceDynamicModel {
        var pageIndex: Int
        var disposeBag: DisposeBag
        var models: Variable<[Dynamic]>
    }
    fileprivate var dynamicModel: MeSpaceDynamicModel!
    fileprivate var service = MeService.instance

    //MARK: - Inputs
    open var inputs: MeSpaceDynamicViewModelInput = {
        return MeSpaceDynamicViewModelInput(refreshNewData: PublishSubject<Bool>())
    }()

    //MARK: - Outputs
    open var outputs: MeSpaceDynamicViewModelOutput = {
        return MeSpaceDynamicViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag) {
        self.dynamicModel = MeSpaceDynamicModel(pageIndex: 0, disposeBag: disposeBag, models: Variable<[Dynamic]>([]))
        //Rx
        self.outputs.sections = self.dynamicModel.models.asObservable()
            .map{ models in
                return [MeSpaceDynamicSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full { //头部刷新
                    self.outputs.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.dynamicModel.pageIndex = 1
                    //拉取数据
                    self.service.trend(self.dynamicModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.dynamicModel.models.value.removeAll()
                                    self.dynamicModel.models.value = data
                                    //结束刷新
                                    self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                } else {
                                    self.outputs.refreshStateObserver.value = .noData
                                }
                                break
                            default:
                                //请求错误
                                self.outputs.refreshStateObserver.value = .noNet
                                break
                            }
                        })
                        .disposed(by: self.dynamicModel.disposeBag)
                } else { //加载更多
                    self.dynamicModel.pageIndex += 1
                    //拉取数据
                    self.service.trend(self.dynamicModel.pageIndex)
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
    public typealias item = Dynamic
    
    public init(original: MeSpaceDynamicSectionModel, items: [MeSpaceDynamicSectionModel.item]) {
        self = original
        self.items = items
    }
}

public struct MeSpaceTopicViewModelInput {
    var refreshNewData: PublishSubject<Bool>
}
public struct MeSpaceTopicViewModelOutput {
    var sections: Driver<[MeSpaceTopicSectionModel]>?
    var refreshStateObserver: Variable<RefreshStatus>
}
public class MeSpaceTopicViewModel {

    //MARK: - 私有成员
    fileprivate struct MeSpaceTopicModel {
        var pageIndex: Int
        var disposeBag: DisposeBag
        var models: Variable<[Debate]>
    }
    fileprivate var topicModel: MeSpaceTopicModel!
    fileprivate var service = DebateService.instance

    //MARK: - Inputs
    open var inputs: MeSpaceTopicViewModelInput = {
        return MeSpaceTopicViewModelInput(refreshNewData: PublishSubject<Bool>())
    }()
    
    //MAKR: - Outputs
    open var outputs: MeSpaceTopicViewModelOutput = {
        return MeSpaceTopicViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag) {
        self.topicModel = MeSpaceTopicModel(pageIndex: 0, disposeBag: disposeBag, models: Variable<[Debate]>([]))
        //Rx
        self.outputs.sections = self.topicModel.models.asObservable()
            .map{ models in
                return [MeSpaceTopicSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                self.outputs.refreshStateObserver.value = .noData
            })
            .disposed(by: topicModel.disposeBag)
    }
}

public struct MeSpaceTopicSectionModel {
    public var items: [item]
}

extension MeSpaceTopicSectionModel: SectionModelType {
    public typealias item = Debate
    
    public init(original: MeSpaceTopicSectionModel, items: [MeSpaceTopicSectionModel.item]) {
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

    //MARK: - 私有成员
    fileprivate struct MeSpaceAnswerModel {
        var pageIndex: Int
        var disposeBag: DisposeBag
        var models: Variable<[Debate]>
    }
    fileprivate var answerModel: MeSpaceAnswerModel!
    fileprivate var service = DebateService.instance

    //MARK: - Inputs
    open var inputs: MeSpaceAnswerViewModelInput = {
        return MeSpaceAnswerViewModelInput(refreshNewData: PublishSubject<Bool>())
    }()

    //MARK: - Outputs
    open var outputs: MeSpaceAnswerViewModelOutput = {
        return MeSpaceAnswerViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag) {
        self.answerModel = MeSpaceAnswerModel(pageIndex: 0, disposeBag: disposeBag, models: Variable<[Debate]>([]))
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

public struct MeJoinViewModelInput {
    var refreshNewData: PublishSubject<(MeJoinType, Bool)>
}
public struct MeJoinViewModelOutput {
    var collectSections: Driver<[MeJoinCollectSectionModel]>?
    var topicSections: Driver<[MeJoinTopicSectionModel]>?
    var userSections: Driver<[MeJoinUserSectionModel]>?
    var refreshStateObserver: Variable<RefreshStatus>
}
public class MeJoinViewModel {

    //MARK: - 私有成员
    fileprivate struct MeJoinModel {
        var pageIndex: Int
        var disposeBag: DisposeBag
        var collectModels: Variable<[Answer]>
        var topicModels: Variable<[Debate]>
        var userModels: Variable<[User]>
    }
    fileprivate var joinModel: MeJoinModel!
    fileprivate var service = MeService.instance

    //MARK - Inputs
    open var inputs: MeJoinViewModelInput = {
        return MeJoinViewModelInput(refreshNewData: PublishSubject<(MeJoinType, Bool)>())
    }()

    //MARK: - Outputs
    open var outputs: MeJoinViewModelOutput = {
        return MeJoinViewModelOutput(collectSections: nil, topicSections: nil, userSections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag) {
        self.joinModel = MeJoinModel(pageIndex: 0, disposeBag: disposeBag, collectModels: Variable<[Answer]>([]), topicModels: Variable<[Debate]>([]), userModels: Variable<[User]>([]))
        //Rx
        self.outputs.collectSections = self.joinModel.collectModels.asObservable()
            .map{ models in
                return [MeJoinCollectSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.outputs.topicSections = self.joinModel.topicModels.asObservable()
            .map{ models in
                return [MeJoinTopicSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.outputs.userSections = self.joinModel.userModels.asObservable()
            .map{ models in
                return [MeJoinUserSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { (type, full) in
                switch type {
                case .collect:
                    if full { //头部刷新
                        self.outputs.refreshStateObserver.value = .endFooterRefresh
                        //初始化
                        self.joinModel.pageIndex = 1
                        //拉取数据
                        self.service.collects(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.collectModels.value.removeAll()
                                        self.joinModel.collectModels.value = data
                                        //结束刷新
                                        self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                    } else {
                                        self.outputs.refreshStateObserver.value = .noData
                                    }
                                    break
                                default:
                                    //请求错误
                                    self.outputs.refreshStateObserver.value = .noNet
                                    break
                                }
                            })
                            .disposed(by: self.joinModel.disposeBag)
                    } else { //加载更多
                        self.joinModel.pageIndex += 1
                        //拉取数据
                        self.service.collects(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.collectModels.value += data
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
                            .disposed(by: self.joinModel.disposeBag)
                    }
                case .support:
                    if full { //头部刷新
                        self.outputs.refreshStateObserver.value = .endFooterRefresh
                        //初始化
                        self.joinModel.pageIndex = 1
                        //拉取数据
                        self.service.supports(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.collectModels.value.removeAll()
                                        self.joinModel.collectModels.value = data
                                        //结束刷新
                                        self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                    } else {
                                        self.outputs.refreshStateObserver.value = .noData
                                    }
                                    break
                                default:
                                    //请求错误
                                    self.outputs.refreshStateObserver.value = .noNet
                                    break
                                }
                            })
                            .disposed(by: self.joinModel.disposeBag)
                    } else { //加载更多
                        self.joinModel.pageIndex += 1
                        //拉取数据
                        self.service.supports(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.collectModels.value += data
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
                            .disposed(by: self.joinModel.disposeBag)
                    }
                case .viewpoint:
                    if full { //头部刷新
                        self.outputs.refreshStateObserver.value = .endFooterRefresh
                        //初始化
                        self.joinModel.pageIndex = 1
                        //拉取数据
                        self.service.viewpoints(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.collectModels.value.removeAll()
                                        self.joinModel.collectModels.value = data
                                        //结束刷新
                                        self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                    } else {
                                        self.outputs.refreshStateObserver.value = .noData
                                    }
                                    break
                                default:
                                    //请求错误
                                    self.outputs.refreshStateObserver.value = .noNet
                                    break
                                }
                            })
                            .disposed(by: self.joinModel.disposeBag)
                    } else { //加载更多
                        self.joinModel.pageIndex += 1
                        //拉取数据
                        self.service.viewpoints(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.collectModels.value += data
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
                            .disposed(by: self.joinModel.disposeBag)
                    }
                case .topic:
                    if full { //头部刷新
                        self.outputs.refreshStateObserver.value = .endFooterRefresh
                        //初始化
                        self.joinModel.pageIndex = 1
                        //拉取数据
                        self.service.topics(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.topicModels.value.removeAll()
                                        self.joinModel.topicModels.value = data
                                        //结束刷新
                                        self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                    } else {
                                        self.outputs.refreshStateObserver.value = .noData
                                    }
                                    break
                                default:
                                    //请求错误
                                    self.outputs.refreshStateObserver.value = .noNet
                                    break
                                }
                            })
                            .disposed(by: self.joinModel.disposeBag)
                    } else { //加载更多
                        self.joinModel.pageIndex += 1
                        //拉取数据
                        self.service.topics(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.topicModels.value += data
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
                            .disposed(by: self.joinModel.disposeBag)
                    }
                case .followtopic:
                    if full { //头部刷新
                        self.outputs.refreshStateObserver.value = .endFooterRefresh
                        //初始化
                        self.joinModel.pageIndex = 1
                        //拉取数据
                        self.service.followtopics(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.topicModels.value.removeAll()
                                        self.joinModel.topicModels.value = data
                                        //结束刷新
                                        self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                    } else {
                                        self.outputs.refreshStateObserver.value = .noData
                                    }
                                    break
                                default:
                                    //请求错误
                                    self.outputs.refreshStateObserver.value = .noNet
                                    break
                                }
                            })
                            .disposed(by: self.joinModel.disposeBag)
                    } else { //加载更多
                        self.joinModel.pageIndex += 1
                        //拉取数据
                        self.service.followtopics(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.topicModels.value += data
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
                            .disposed(by: self.joinModel.disposeBag)
                    }
                case .followperson:
                    if full { //头部刷新
                        self.outputs.refreshStateObserver.value = .endFooterRefresh
                        //初始化
                        self.joinModel.pageIndex = 1
                        //拉取数据
                        self.service.follows(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.userModels.value.removeAll()
                                        self.joinModel.userModels.value = data
                                        //结束刷新
                                        self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                    } else {
                                        self.outputs.refreshStateObserver.value = .noData
                                    }
                                    break
                                default:
                                    //请求错误
                                    self.outputs.refreshStateObserver.value = .noNet
                                    break
                                }
                            })
                            .disposed(by: self.joinModel.disposeBag)
                    } else { //加载更多
                        self.joinModel.pageIndex += 1
                        //拉取数据
                        self.service.follows(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.userModels.value += data
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
                            .disposed(by: self.joinModel.disposeBag)
                    }
                case .fan:
                    if full { //头部刷新
                        self.outputs.refreshStateObserver.value = .endFooterRefresh
                        //初始化
                        self.joinModel.pageIndex = 1
                        //拉取数据
                        self.service.fans(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.userModels.value.removeAll()
                                        self.joinModel.userModels.value = data
                                        //结束刷新
                                        self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                    } else {
                                        self.outputs.refreshStateObserver.value = .noData
                                    }
                                    break
                                default:
                                    //请求错误
                                    self.outputs.refreshStateObserver.value = .noNet
                                    break
                                }
                            })
                            .disposed(by: self.joinModel.disposeBag)
                    } else { //加载更多
                        self.joinModel.pageIndex += 1
                        //拉取数据
                        self.service.fans(self.joinModel.pageIndex)
                            .subscribe(onNext: { response in
                                let data = response.0
                                let result = response.1
                                switch result {
                                case .ok:
                                    if data.count > 0 {
                                        self.joinModel.userModels.value += data
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
                            .disposed(by: self.joinModel.disposeBag)
                    }
                }
            })
            .disposed(by: joinModel.disposeBag)
    }
}

public struct MeJoinCollectSectionModel {
    public var items: [item]
}

extension MeJoinCollectSectionModel: SectionModelType {
    public typealias item = Answer
    
    public init(original: MeJoinCollectSectionModel, items: [MeJoinCollectSectionModel.item]) {
        self = original
        self.items = items
    }
}

public struct MeJoinTopicSectionModel {
    public var items: [item]
}

extension MeJoinTopicSectionModel: SectionModelType {
    public typealias item = Debate
    
    public init(original: MeJoinTopicSectionModel, items: [MeJoinTopicSectionModel.item]) {
        self = original
        self.items = items
    }
}

public struct MeJoinUserSectionModel {
    public var items: [item]
}

extension MeJoinUserSectionModel: SectionModelType {
    public typealias item = User
    
    public init(original: MeJoinUserSectionModel, items: [MeJoinUserSectionModel.item]) {
        self = original
        self.items = items
    }
}


