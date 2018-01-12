//
//  MeSpaceViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/10.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import PMSuperButton
import RxSwift
import RxCocoa
import RxGesture

class MeSpaceViewController: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var button: PMSuperButton! {
        didSet {
            self.button.contentEdgeInsets.left = 8
            self.button.contentEdgeInsets.right = 8
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
            self.tableView.showsVerticalScrollIndicator = false
            self.tableView.showsHorizontalScrollIndicator = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //显示导航栏
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    //私有成员
    fileprivate var isScrollEnabled: Bool = true
    fileprivate var panOffset: CGFloat = 0
    fileprivate var disposeBag = DisposeBag()

}

extension MeSpaceViewController {
    //初始化
    fileprivate func setupUI() {
        //Navigation
        self.navigationItem.title = ""
        //View Gesture
        self.view.rx
            .panGesture()
            .when(.began)
            .subscribe(onNext: { [weak self] gesture in
                self?.panOffset = gesture.location(in: self?.view).y
            })
            .disposed(by: self.disposeBag)
        self.view.rx
            .panGesture()
            .when(.changed)
            .subscribe(onNext: { [weak self] gesture in
                guard let _ = self else { return }
                
                let currentPanOffset = gesture.location(in: self!.view).y
                let scrollOffset = currentPanOffset - self!.panOffset
                self!.scrollHeader(scrollOffset)
                self!.panOffset = currentPanOffset
            })
            .disposed(by: self.disposeBag)
    }
    //滚动头部
    fileprivate func scrollHeader(_ scrollOffset: CGFloat) {
        let height = self.tableView.tableHeaderView!.frame.height
        let contentOffset = self.tableView.contentOffset.y
        let distance = contentOffset - scrollOffset
        if (scrollOffset < 0 && distance < height) || (scrollOffset >= 0 && distance >= 0) { //向下滚动 & 向上滚动
            self.tableView.setContentOffset(CGPoint.init(x: self.tableView.contentOffset.x, y: distance), animated: false)
        }
    }
}

extension MeSpaceViewController: UITableViewDelegate, UITableViewDataSource {
    //TableView Delegate && DataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SH - 64
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

