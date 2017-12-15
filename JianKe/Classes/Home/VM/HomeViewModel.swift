//
//  HomeViewModel.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/15.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Moya
import RxDataSources

public protocol HomeViewModelInput {
    var isRefresh: PublishSubject<Bool?>{ get }
}
public protocol HomeViewModelOutput {
    var sections: Driver<[HomeSectionModel]>{ get }
    var refreshResult: Driver<Result>{ get }
}
public protocol HomeViewModelType {
    var inputs: HomeViewModelInput { get }
    var outputs: HomeViewModelOutput { get }
}
public class HomeViewModel: HomeViewModelInput, HomeViewModelOutput, HomeViewModelType {
    //声明区
    let models = Variable<[News]>([])
    //inputs
    public var isRefresh = PublishSubject<Bool?>()
    //outputs
    public var sections: Driver<[HomeSectionModel]>
    public var refreshResult: Driver<Result>
    //get
    public var inputs: HomeViewModelInput { return self }
    public var outputs: HomeViewModelOutput { return self }
    
    init() {
        sections = models.asObservable()
            .map{ models -> [HomeSectionModel] in
                //return [HomeSectionModel(items: models)]
                var news = News()
                news.id = 1
                let m = [news, news, news, news, news]
                return [HomeSectionModel(items: m)]
            }
            .asDriver(onErrorJustReturn: [])
        refreshResult = isRefresh.asDriver(onErrorJustReturn: nil)
            .flatMapLatest{ refresh in
                //刷新数据
                return Observable.just(Result.empty).asDriver(onErrorJustReturn: Result.empty)
            }
    }
}

public struct HomeSectionModel {
    public var items: [item]
}

extension HomeSectionModel: SectionModelType {
    public typealias item = News
    
    public init(original: HomeSectionModel, items: [HomeSectionModel.item]) {
        self = original
        self.items = items
    }
}
