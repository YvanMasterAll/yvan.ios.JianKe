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

class FriendViewController: UIViewController {

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
        
        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //NavigationBar
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
        self.navigationController?.navigationBar.barTintColor = GMColor.grey50Color()
        //GeneralFactory.generateRectShadow(layer: self.navigationController!.navigationBar.layer, rect: CGRect.init(x: 0, y: self.navigationController!.navigationBar.frame.height, width: SW, height: 0.5), color: GMColor.grey400Color().cgColor)
    }
    
    //私有成员
    fileprivate var disposeBag = DisposeBag()
    fileprivate var friendViewModel: FriendViewModel!
    fileprivate var dynamicViewModel: FriendDynamicViewModel!
    
}

extension FriendViewController {
    //初始化
    fileprivate func setupUI() {
        //SegmentControl
        self.segmentControl.addTarget(self, action: #selector(self.segmentControlChanged), for: UIControlEvents.valueChanged)
    }
    fileprivate func bindRx() {
        //View Model
        self.friendViewModel = FriendViewModel(disposeBag: disposeBag, section: Auth())
        self.dynamicViewModel = FriendDynamicViewModel(disposeBag: disposeBag, section: Auth())
    }
    //SegmengControl Changed
    @objc fileprivate func segmentControlChanged(sender: UISegmentedControl) {
        self.pagerView.scrollToItem(at: sender.selectedSegmentIndex, animated: true)
    }
}

extension FriendViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    //FSPagerView Delegate && DataSource
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
