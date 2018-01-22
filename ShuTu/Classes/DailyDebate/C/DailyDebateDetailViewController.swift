//
//  DailyDebateDetailViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/11.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift
import PMSuperButton

class DailyDebateDetailViewController: UIViewController {

    @IBOutlet weak var navigationBack: UIImageView! {
        didSet {
            self.navigationBack.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.goBack))
            self.navigationBack.addGestureRecognizer(tapGes)
        }
    }
    @IBOutlet weak var gotoDebate: PMSuperButton! {
        didSet {
            self.gotoDebate.setImage(UIImage.init(named: "icon_go_white")!.reSizeImage(CGSize.init(width: 15, height: 15)), for: .normal)
            self.gotoDebate.imageEdgeInsets.right = 4
            self.gotoDebate.addTarget(self, action: #selector(self.gotoDebateMethod), for: .touchUpInside)
        }
    }
    @IBOutlet weak var actionVIew: UIView!
    @IBOutlet weak var addAnswer: PMSuperButton! {
        didSet {
            self.addAnswer.setImage(UIImage.init(named: "icon_quiz_grey500")!.reSizeImage(CGSize.init(width: 15, height: 15)), for: .normal)
            self.addAnswer.imageEdgeInsets.right = 4
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
    
    //声明区域
    open var section: Debate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
        self.hidesBottomBarWhenPushed = true
        //阴影
        GeneralFactory.generateRectShadow(layer: self.actionVIew.layer, rect: CGRect.init(x: 0, y: -0.5, width: SW, height: 0.5), color: GMColor.grey800Color().cgColor)
        self.view.bringSubview(toFront: self.actionVIew)
    }
    
    //私有成员
    fileprivate weak var viewModel: DailyDebateDetailViewModel!
    fileprivate var disposeBag = DisposeBag()

}

extension DailyDebateDetailViewController {
    //初始化
    fileprivate func setupUI() {
        //View Model
        self.viewModel = DailyDebateDetailViewModel(disposeBag: disposeBag, section: Answer.init())
    }
    //NavigationBarItem Action
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    //Button Action
    @objc fileprivate func gotoDebateMethod() {
        //跳转至详情
        let debateStoryBoard = UIStoryboard(name: "Debate", bundle: nil)
        let debateDetailVC = debateStoryBoard.instantiateViewController(withIdentifier: "DebateDetail") as! DebateDetailViewController
        debateDetailVC.section = self.section

        self.navigationController?.pushViewController(debateDetailVC, animated: true)
    }
}

extension DailyDebateDetailViewController: UITableViewDelegate, UITableViewDataSource {
    //TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SH - 280 - 34
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DailyDebateDetailTableViewCell
        cell.disposeBag = self.disposeBag
        if cell.viewModel == nil {
            cell.viewModel = self.viewModel
        }
        
        return cell
    }
}



