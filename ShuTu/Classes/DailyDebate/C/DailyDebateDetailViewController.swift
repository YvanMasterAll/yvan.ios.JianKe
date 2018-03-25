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

class DailyDebateDetailViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var followButton: STButton! {
        didSet {
            self.followButton.addTarget(self, action: #selector(self.follow), for: .touchUpInside)
        }
    }
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var navigationBack: UIImageView! {
        didSet {
            self.navigationBack.image = self.navigationBack.image?.imageWithTintColor(ColorPrimary)
            self.navigationBack.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.goBack))
            self.navigationBack.addGestureRecognizer(tapGes)
        }
    }
    @IBOutlet weak var gotoDebate: STButton! {
        didSet {
            self.gotoDebate.setImage(UIImage.init(named: "icon_go_white")!.reSizeImage(CGSize.init(width: 15, height: 15)), for: .normal)
            self.gotoDebate.imageEdgeInsets.right = 4
            self.gotoDebate.addTarget(self, action: #selector(self.gotoDebateMethod), for: .touchUpInside)
        }
    }
    @IBOutlet weak var actionVIew: UIView!
    @IBOutlet weak var addAnswer: STButton! {
        didSet {
            self.addAnswer.setImage(UIImage.init(named: "icon_quiz_grey500")!.reSizeImage(CGSize.init(width: 15, height: 15)), for: .normal)
            self.addAnswer.imageEdgeInsets.right = 4
            if !Environment.tokenExists {
                self.addAnswer.isEnabled = false
            }
            self.addAnswer.addTarget(self, action: #selector(self.gotoAddAnswerCheck), for: .touchUpInside)
        }
    }
    @IBOutlet weak var tableView: BaseTableView!
    
    //MARK: - 声明区域
    open var section: Debate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideTabbar = true
        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - 私有成员
    fileprivate weak var viewModel: DailyDebateDetailViewModel!
    fileprivate var disposeBag = DisposeBag()
    fileprivate var followed: Bool = false
    fileprivate var scrollDragging: Bool = false
    fileprivate var tableStatus: TableState = .headBottom
    fileprivate var canScroll: Bool = true
    fileprivate var tableOneScrolled: Bool = false

}

extension DailyDebateDetailViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        //Init
        self.titleLabel.text = self.section.title
        if let imageUrl = URL.init(string: section.cover_image!) {
            self.coverImage.kf.setImage(with: imageUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, _, _, _) in
                if image != nil {
                    self.coverImage.image = image!.applyLightEffect(2, 0.3)
                }
            })
        }
        //阴影
        GeneralFactory.generateRectShadow(layer: self.actionVIew.layer, rect: CGRect.init(x: 0, y: -0.5, width: SW, height: 0.5), color: STColor.grey800Color().cgColor)
        self.view.bringSubview(toFront: self.actionVIew)
    }
    fileprivate func bindRx() {
        //SonTableStatue
        SonTableStatus.asObserver()
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .canParentScroll:
                    self?.canScroll = true
                case .noParentScroll:
                    self?.canScroll = false
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
        //View Model
        self.viewModel = DailyDebateDetailViewModel(disposeBag: disposeBag, section: self.section)
        viewModel.outputs.followResult
            .asObservable()
            .subscribe(onNext: { [weak self] result in
                guard let _ = self?.followed else { return }
                if self!.followed { //取消关注结果
                    switch result {
                    case .failed:
                        HUD.flash(.label("取消关注失败"))
                        break
                    case .ok:
                        self?.applyFollowButton(false)
                        ServiceUtil.userinfoPartRefresh(nil, false)
                        break
                    default:
                        break
                    }
                } else { //关注结果
                    switch result {
                    case .failed:
                        HUD.flash(.label("关注失败"))
                        break
                    case .ok:
                        self?.applyFollowButton(true)
                        ServiceUtil.userinfoPartRefresh(nil, true)
                        break
                    case .exist:
                        self?.applyFollowButton(true)
                        break
                    default:
                        break
                    }
                }
                
            })
            .disposed(by: disposeBag)
        viewModel.outputs.followCheck
            .asObservable()
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .exist:
                    self?.applyFollowButton(true)
                    break
                case .empty:
                    self?.applyFollowButton(false)
                    break
                default:
                    self?.applyFollowButton(false)
                    break
                }
            })
            .disposed(by: disposeBag)
        viewModel.outputs.answerCheck
            .asObservable()
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .exist:
                    HUD.flash(.label("你已经提交过观点"))
                    break
                case .empty:
                    self?.gotoAddAnswer()
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        //检查关注
        self.viewModel.inputs.followCheck.onNext(())
    }
    
    //MARK: - 按钮事件
    @objc fileprivate func follow() {
        if self.followed { //取消关注
            viewModel.inputs.followTap.onNext(false)
        } else { //关注
            viewModel.inputs.followTap.onNext(true)
        }
    }
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    @objc fileprivate func gotoDebateMethod() {
        //跳转至详情
        let debateDetailVC = GeneralFactory.getVCfromSb("Debate", "DebateDetail") as! DebateDetailViewController
        debateDetailVC.section = self.section
        
        self.navigationController?.pushViewController(debateDetailVC, animated: true)
        self.viewModel.inputs.followCheck.onNext(())
    }
    @objc fileprivate func gotoAddAnswerCheck() {
        self.viewModel.inputs.answerCheck.onNext(())
    }
    fileprivate func gotoAddAnswer() {
        let debateAnswerAddNewVC = GeneralFactory.getVCfromSb("Debate", "DebateAnswerAddNew") as! DebateAnswerAddNewViewController
        debateAnswerAddNewVC.section = self.section
        
        self.navigationController?.pushViewController(debateAnswerAddNewVC, animated: true)
    }
    
    //MAKR: - 按钮状态变更
    fileprivate func applyFollowButton(_ followed: Bool) {
        self.followed = followed
        self.followButton.isHidden = false
        if followed {
            self.followButton.setTitle("已关注", for: .normal)
            self.followButton.backgroundColor = ColorPrimary.darken(by: 0.2)
            self.followButton.setImage(nil, for: .normal)
        } else {
            self.followButton.setTitle("关注", for: .normal)
            self.followButton.backgroundColor = ColorPrimary
            self.followButton.setImage(UIImage.init(icon: .fontAwesome(.plus), size: CGSize.init(width: 14, height: 14), textColor: UIColor.white, backgroundColor: UIColor.clear), for: .normal)
        }
    }
}

extension DailyDebateDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //54
        return SH - 54
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DailyDebateDetailTableViewCell
        cell.section = self.section
        cell.disposeBag = self.disposeBag
        if cell.viewModel == nil {
            cell.viewModel = self.viewModel
        }
        
        return cell
    }
    
    //MARK: - ScrollView Delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollDragging = true
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.scrollDragging {
            if self.canScroll {
                let height = self.tableView.tableHeaderView!.frame.height
                let scrollOffset = scrollView.contentOffset.y
                if Int(scrollOffset) >= Int(height) {
                    self.tableView.contentOffset.y = height
                    tableStatus = .headTop
                    TableStatus.onNext(.headTop)
                } else if scrollOffset <= 0 {
                    tableStatus = .headBottom
                    TableStatus.onNext(.headBottom)
                } else {
                    TableStatus.onNext(.headMid)
                }
            } else {
                let height = self.tableView.tableHeaderView!.frame.height
                switch tableStatus {
                case .headBottom:
                    self.canScroll = true
                    self.tableView.contentOffset.y = 0
                case .headTop:
                    self.tableView.contentOffset.y = height
                default:
                    break
                }
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollDragging = false
    }
}



