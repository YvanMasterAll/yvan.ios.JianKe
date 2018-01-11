//
//  MeSpaceTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/10.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class MeSpaceTableViewCell: UITableViewCell {

    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(UINib(nibName: "MeSpaceDynamicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "dynamic")
            self.pagerView.register(UINib(nibName: "MeSpaceQuizCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "quiz")
            self.pagerView.register(UINib(nibName: "MeSpaceAnswerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "answer")
            self.pagerView.itemSize = .zero
            self.pagerView.delegate = self
            self.pagerView.dataSource = self
        }
    }
    @IBOutlet weak var tabView: TabView! {
        didSet {
            var option = TabPageOption()
            option.currentColor = ColorPrimary
            option.defaultColor = GMColor.grey600Color()
            option.pageBackgoundColor = ColorPrimary
            self.tabView.initOption(option: option)
            tabView.translatesAutoresizingMaskIntoConstraints = false
            
            tabView.pageTabItems = titles
            tabView.updateCurrentIndex(0, shouldScroll: true)
            
            tabView.pageItemPressedBlock = { [weak self] (index: Int, direction: UIPageViewControllerNavigationDirection) in
                //TabView 点击事件
                self?.tabView(itemSelectedAtIndex: index)
            }
        }
    }
    
    //声明区域
    open var titles = ["动态", "提问", "回答"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.commonInit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //私有成员
    fileprivate var dynamicViewModel: MeSpaceDynamicViewModel!
    fileprivate var quizViewModel: MeSpaceQuizViewModel!
    fileprivate var answerViewModel: MeSpaceAnswerViewModel!
    fileprivate var disposeBag = DisposeBag()
    fileprivate var currentIndex: Int = 0
    fileprivate var shouldTabBarScroll: Bool = true
    
}

extension MeSpaceTableViewCell {
    //初始化
    fileprivate func commonInit() {
        //View Model
        self.dynamicViewModel = MeSpaceDynamicViewModel.init(disposeBag: self.disposeBag, section: Auth())
        self.quizViewModel = MeSpaceQuizViewModel.init(disposeBag: self.disposeBag, section: Auth())
        self.answerViewModel = MeSpaceAnswerViewModel.init(disposeBag: self.disposeBag, section: Auth())
    }
    //TabView 点击事件
    fileprivate func tabView(itemSelectedAtIndex index: Int) {
        if index == pagerView.currentIndex { return }
        
        self.pagerView.scrollToItem(at: index, animated: true)
    }
}

extension MeSpaceTableViewCell: FSPagerViewDelegate, FSPagerViewDataSource {
    //FSPagerView Delegate && DataSource
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 3
    }
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        currentIndex = pagerView.currentIndex
        if self.shouldTabBarScroll {
            tabView.scrollCurrentBarView(contentOffsetX: pagerView.scrollOffset)
        }
    }
    func pagerViewWillBeginDragging(_ pagerView: FSPagerView) {
        self.shouldTabBarScroll = true
    }
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        if currentIndex == 2 && targetIndex == 0 { //avoid infinite
            return
        }
        self.shouldTabBarScroll = false
        tabView.updateCurrentIndex(Int(targetIndex), shouldScroll: true)
    }
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        if index == 0 {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "dynamic", at: index) as! MeSpaceDynamicCollectionViewCell
            cell.backgroundColor = UIColor.white
            cell.disposeBag = self.disposeBag
            if cell.viewModel == nil {
                cell.viewModel = self.dynamicViewModel
            }
            
            return cell
        } else if index == 1 {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "quiz", at: index) as! MeSpaceQuizCollectionViewCell
            cell.backgroundColor = UIColor.white
            cell.disposeBag = self.disposeBag
            if cell.viewModel == nil {
                cell.viewModel = self.quizViewModel
            }
            
            return cell
        } else {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "answer", at: index) as! MeSpaceAnswerCollectionViewCell
            cell.backgroundColor = UIColor.white
            cell.disposeBag = self.disposeBag
            if cell.viewModel == nil {
                cell.viewModel = self.answerViewModel
            }
            
            return cell
        }
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return false
    }
}
