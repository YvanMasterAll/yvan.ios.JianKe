//
//  FriendViewModel.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/4.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

public struct FriendViewModelInput {
    var refreshNewData: PublishSubject<Bool>
}
public struct FriendViewModelOutput {
    var sections: Driver<[FriendSectionModel]>?
    var refreshStateObserver: Variable<RefreshStatus>
}
public class FriendViewModel {
    fileprivate struct FriendModel {
        var pageIndex: Int
        var section: Auth
        var disposeBag: DisposeBag
        var models: Variable<[Friend]>
    }
    //私有成员
    fileprivate var friendModel: FriendModel!
    fileprivate var service = FriendService.instance
    //Inputs
    open var inputs: FriendViewModelInput = {
        return FriendViewModelInput(refreshNewData: PublishSubject<Bool>())
    }()
    //Outputs
    open var outputs: FriendViewModelOutput = {
        return FriendViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Auth) {
        self.friendModel = FriendModel(pageIndex: 0, section: section, disposeBag: disposeBag, models: Variable<[Friend]>([]))
        //Rx
        self.outputs.sections = self.friendModel.models.asObservable()
            .map{ models in
                return [FriendSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    self.outputs.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.friendModel.pageIndex = 0
                    //拉取数据
                    self.service.getFriend(id: 0, pageIndex: self.friendModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                self.friendModel.models.value.removeAll()
                                self.friendModel.models.value = data
                                //结束刷新
                                self.outputs.refreshStateObserver.value = .endHeaderRefresh
                                break
                            default:
                                //请求错误
                                self.outputs.refreshStateObserver.value = .noData
                                break
                            }
                        })
                        .disposed(by: self.friendModel.disposeBag)
                } else {//加载更多
                    self.friendModel.pageIndex += 1
                    //拉取数据
                    self.service.getFriend(id: 0, pageIndex: self.friendModel.pageIndex)
                        .subscribe(onNext: { response in
                            let data = response.0
                            let result = response.1
                            switch result {
                            case .ok:
                                if data.count > 0 {
                                    self.friendModel.models.value += data
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
                        .disposed(by: self.friendModel.disposeBag)
                }
            })
            .disposed(by: friendModel.disposeBag)
    }
}

public struct FriendSectionModel {
    public var items: [item]
}

extension FriendSectionModel: SectionModelType {
    public typealias item = Friend
    
    public init(original: FriendSectionModel, items: [FriendSectionModel.item]) {
        self = original
        self.items = items
    }
}


public struct FriendDynamicViewModelInput {
    var refreshNewData: PublishSubject<Bool>
}
public struct FriendDynamicViewModelOutput {
    var sections: Driver<[FriendDynamicSectionModel]>?
    var refreshStateObserver: Variable<RefreshStatus>
}
public class FriendDynamicViewModel {
    fileprivate struct FriendDynamicModel {
        var pageIndex: Int
        var section: Auth
        var disposeBag: DisposeBag
        var models: Variable<[Dynamic]>
    }
    //私有成员
    fileprivate var dynamicModel: FriendDynamicModel!
    fileprivate var service = FriendService.instance
    //Inputs
    open var inputs: FriendDynamicViewModelInput = {
        return FriendDynamicViewModelInput(refreshNewData: PublishSubject<Bool>())
    }()
    //Outputs
    open var outputs: FriendDynamicViewModelOutput = {
        return FriendDynamicViewModelOutput(sections: nil, refreshStateObserver: Variable<RefreshStatus>(.none))
    }()
    
    init(disposeBag: DisposeBag, section: Auth) {
        self.dynamicModel = FriendDynamicModel(pageIndex: 0, section: section, disposeBag: disposeBag, models: Variable<[Dynamic]>([]))
        //Rx
        self.outputs.sections = self.dynamicModel.models.asObservable()
            .map{ models in
                return [FriendDynamicSectionModel.init(items: models)]
            }
            .asDriver(onErrorJustReturn: [])
        self.inputs.refreshNewData.asObserver()
            .subscribe(onNext: { full in
                if full {//头部刷新
                    self.outputs.refreshStateObserver.value = .endFooterRefresh
                    //初始化
                    self.dynamicModel.pageIndex = 0
                    //拉取数据
                    self.service.getDynamic(id: 0, pageIndex: self.dynamicModel.pageIndex)
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
                    self.service.getDynamic(id: 0, pageIndex: self.dynamicModel.pageIndex)
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

public struct FriendDynamicSectionModel {
    public var items: [item]
}

extension FriendDynamicSectionModel: SectionModelType {
    public typealias item = Dynamic
    
    public init(original: FriendDynamicSectionModel, items: [FriendDynamicSectionModel.item]) {
        self = original
        self.items = items
    }
}
