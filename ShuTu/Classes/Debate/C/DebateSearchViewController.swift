//
//  DebateSearchViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/14.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class DebateSearchViewController: BaseViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            self.cancelButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        }
    }
    @IBOutlet weak var historyViewHeightC: NSLayoutConstraint!
    @IBOutlet weak var categoryViewHeightC: NSLayoutConstraint!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var clearHistory: UIButton! {
        didSet {
            self.clearHistory.addTarget(self, action: #selector(self.removeAllHistory), for: .touchUpInside)
        }
    }
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            self.searchTextField.attributedPlaceholder = NSAttributedString.init(string: self.searchTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: STColor.grey300Color(), NSAttributedStringKey.font: self.searchTextField.font!])
            self.searchTextField.delegate = self
        }
    }
    @IBOutlet weak var searchView: UIView! {
        didSet {
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.searchViewClicked))
            self.searchView.isUserInteractionEnabled = true
            self.searchView.addGestureRecognizer(tapGes)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hot Topic
        Environment.searchHot = ["冲顶大会", "李小璐被爆出轨", "PGOne道歉", "今日小寒", "绝地求生吃鸡", "五五开使用外挂", "公司该不该招应届生", "拿到年终奖马上辞职厚不厚到"]
        
        setupUI()
        bindRx()
    }
    
    override func reload() {
        self.tableView.switchRefreshHeader(to: .refreshing)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - 私有成员
    fileprivate var categories: [String]!
    fileprivate var histories: [String]!
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView.init()
        tableView.register(UINib.init(nibName: "DebateSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView() //消除底部视图
        tableView.separatorStyle = .none //消除分割线
        tableView.showsVerticalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.top.equalTo(self.searchView.snp.bottom)
        }
        tableView.isHidden = true
        
        return tableView
    }()
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<DebateSearchSectionModel>!
    fileprivate var viewModel: DebateSearchViewModel!
    fileprivate var disposeBag = DisposeBag()
    fileprivate var searchText = ""

}

extension DebateSearchViewController {

    //MARK: - 初始化
    fileprivate func setupUI() {
        self.setupCategoryLayout()
        self.setupHistoryLayout()
        //PullToRefreshKit
        let secondHeader = SecondRefreshHeader()
        tableView.configRefreshHeader(with: secondHeader, action: { [weak self] () -> Void in
            self?.viewModel.inputs.refreshNewData.onNext((true, self!.searchText))
        })
        tableView.configRefreshFooter(with: FirstRefreshFooter(), action: { [weak self] () -> Void in
            self?.viewModel.inputs.refreshNewData.onNext((false, self!.searchText))
        })
        //阴影
        GeneralFactory.generateRectShadow(layer: self.searchView.layer, rect: CGRect.init(x: 0, y: self.searchView.frame.height, width: SW, height: 0.5), color: STColor.grey800Color().cgColor)
        self.view.bringSubview(toFront: self.searchView)
    }
    fileprivate func bindRx() {
        //View Model
        self.viewModel = DebateSearchViewModel.init(disposeBag: self.disposeBag)
        //Rx
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<DebateSearchSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip) as! DebateSearchTableViewCell
                
                return cell
        })
        self.tableView.rx
            .modelSelected(Debate.self)
            .subscribe(onNext: { data in
                //跳转
            })
            .disposed(by: disposeBag)
        self.viewModel.outputs.refreshStateObserver.asObservable()
            .subscribe(onNext: { [unowned self] state in
                switch state {
                case .noNet:
                    self.tableView.switchRefreshHeader(to: .normal(.none, 0))
                    if self.hasRequested {
                        HUD.flash(.label("网络走失了"))
                    } else {
                        self.showBaseEmptyView()
                    }
                    break
                case .noData:
                    self.tableView.switchRefreshHeader(to: .normal(.none, 0))
                    self.tableView.switchRefreshFooter(to: FooterRefresherState.removed)
                    self.showBaseEmptyView("还没有数据")
                    break
                case .beginHeaderRefresh:
                    break
                case .endHeaderRefresh:
                    self.hasRequested = true
                    self.tableView.switchRefreshHeader(to: .normal(.success, 0))
                    break
                case .beginFooterRefresh:
                    break
                case .endFooterRefresh:
                    self.tableView.switchRefreshFooter(to: .normal)
                    break
                case .endRefreshWithoutData:
                    self.tableView.switchRefreshFooter(to: .noMoreData)
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        viewModel.outputs.sections!.asDriver()
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        //刷新
        //self.tableView.switchRefreshHeader(to: .refreshing)
    }
    fileprivate func setupCategoryLayout() {
        //清空
        for view in self.categoryView.subviews {
            view.removeFromSuperview()
        }
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        let btnH: CGFloat = 30
        let width: CGFloat = SW - 20
        categories = Environment.searchHot ?? []
        for i in 0..<self.categories.count {
            let button = UIButton.init(frame: CGRect.zero)
            button.setTitle(self.categories[i], for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 11)
            button.setTitleColor(STColor.grey500Color(), for: .normal)
            button.backgroundColor = UIColor.white
            button.contentEdgeInsets.left = 8
            button.contentEdgeInsets.right = 8
            button.layer.cornerRadius = 4
            button.clipsToBounds = true
            var btnw = button.titleLabel!.widthOfString + 16
            btnw = btnw>width ? width:btnw
            if (btnw + x) > (width) {
                x = 0
                y += btnH + 10
            }
            button.frame.origin = CGPoint(x: x, y: y + 10)
            button.frame.size = CGSize(width: btnw, height: btnH)
            self.categoryView.addSubview(button)
            //累加
            x = button.frame.maxX + 10
        }
        self.categoryViewHeightC.constant = y + btnH + 20
    }
    fileprivate func setupHistoryLayout() {
        //清空
        for view in self.historyView.subviews {
            view.removeFromSuperview()
        }
        
        let x: CGFloat = 0
        var y: CGFloat = 0
        let btnH: CGFloat = 38
        let width: CGFloat = SW - 20
        histories = Environment.searchHistory ?? []
        if histories.count > 0 {
            self.clearHistory.isHidden = false
        } else {
            self.clearHistory.isHidden = true
        }
        for i in 0..<histories.count {
            let button = UIButton.init(frame: CGRect.zero)
            button.setTitle(histories[i], for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            button.setTitleColor(STColor.grey500Color(), for: .normal)
            button.backgroundColor = UIColor.white
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            button.contentEdgeInsets.left = 10
            button.contentEdgeInsets.right = 10
            button.imageEdgeInsets.right = 8
            button.layer.cornerRadius = 1
            button.clipsToBounds = true
            button.setImage(UIImage.init(icon: .fontAwesome(.history), size: CGSize.init(width: 20, height: 20), textColor: STColor.grey500Color(), backgroundColor: UIColor.clear), for: .normal)
            let divider = UIView.init(frame: CGRect.init(x: 0, y: btnH - 0.5, width: width, height: 0.5))
            divider.backgroundColor = STColor.grey50Color()
            button.addSubview(divider)
            let removeImage = UIImageView.init(image: UIImage.init(icon: .fontAwesome(.remove), size: CGSize.init(width: 20, height: 20), textColor: STColor.grey500Color(), backgroundColor: UIColor.clear))
            removeImage.frame.origin = CGPoint(x: width - 30, y: (btnH - 20)/2)
            removeImage.tag = 10000 + i
            button.addSubview(removeImage)
            removeImage.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.removeHistory))
            removeImage.addGestureRecognizer(tapGes)
            button.frame.origin = CGPoint(x: x, y: y)
            button.frame.size = CGSize(width: width, height: btnH)
            self.historyView.addSubview(button)
            //累加
            y = button.frame.maxY
        }
        self.historyViewHeightC.constant = y
    }
    
    //MARK: - 按钮事件
    @objc fileprivate func searchViewClicked() {
        self.searchTextField.becomeFirstResponder()
    }
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    @objc fileprivate func removeHistory(_ gesture: UITapGestureRecognizer) {
        let removeImage = gesture.view as! UIImageView
        let index = removeImage.tag - 10000
        Environment.removeHistory(index)
        self.setupHistoryLayout()
    }
    @objc fileprivate func removeAllHistory() {
        Environment.searchHistory = []
        self.setupHistoryLayout()
    }
}

extension DebateSearchViewController: UITableViewDelegate {
    
    //MARK: - TableViewDelegate && TableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DebateSearchViewController: UITextFieldDelegate {
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let target = self.searchTextField.text!.trimmed
        if target == "" { return false }
        //添加历史搜索记录
        Environment.addHistory(target)
        self.setupHistoryLayout()
        //收索
        self.searchText = target
        self.contentView.isHidden = true
        self.tableView.isHidden = false
        self.tableView.switchRefreshHeader(to: .refreshing)
        return true
    }
}
