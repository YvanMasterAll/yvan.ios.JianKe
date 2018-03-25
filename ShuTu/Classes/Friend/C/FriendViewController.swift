//
//  FriendViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/4.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FriendViewController: BaseViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(UINib(nibName: "FriendCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "friendPagerCell")
            self.pagerView.register(UINib(nibName: "FriendDynamicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "friendDynamicPagerCell")
            self.pagerView.itemSize = .zero
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNavbar = true
        navBarTitle = "消息"
        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - 私有成员
    fileprivate var disposeBag = DisposeBag()
    fileprivate var friendViewModel: FriendViewModel!
    fileprivate var dynamicViewModel: FriendDynamicViewModel!
    
}

extension FriendViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //SegmentControl
        self.segmentControl.addTarget(self, action: #selector(self.segmentControlChanged), for: UIControlEvents.valueChanged)
    }
    fileprivate func bindRx() {
        //View Model
        self.friendViewModel = FriendViewModel(disposeBag: disposeBag)
        self.dynamicViewModel = FriendDynamicViewModel(disposeBag: disposeBag)
    }
    
    //MAKR: - SegmentControl Action
    @objc fileprivate func segmentControlChanged(sender: UISegmentedControl) {
        self.pagerView.scrollToItem(at: sender.selectedSegmentIndex, animated: true)
    }
}

extension FriendViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    
    //MARK: - FSPagerView Delegate && DataSource
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 2
    }
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        //SegmentControl
        guard self.segmentControl.selectedSegmentIndex != pagerView.currentIndex else {
            return
        }
        self.segmentControl.selectedSegmentIndex = pagerView.currentIndex
    }
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        if index == 0 {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "friendPagerCell", at: index) as! FriendCollectionViewCell
            cell.navigationController = self.navigationController
            cell.disposeBag = self.disposeBag
            if cell.viewModel == nil {
                cell.viewModel = self.friendViewModel
            }
            cell.backgroundColor = UIColor.white
            
            return cell
        } else {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "friendDynamicPagerCell", at: index) as! FriendDynamicCollectionViewCell
            cell.navigationController = self.navigationController
            cell.disposeBag = self.disposeBag
            if cell.viewModel == nil {
                cell.viewModel = self.dynamicViewModel
            }
            cell.backgroundColor = UIColor.white

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
