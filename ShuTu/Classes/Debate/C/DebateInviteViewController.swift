//
//  DebateInviteViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/14.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class DebateInviteViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.showsVerticalScrollIndicator = false
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            self.cancelButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        }
    }
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            self.searchTextField.attributedPlaceholder = NSAttributedString.init(string: self.searchTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: GMColor.grey300Color(), NSAttributedStringKey.font: self.searchTextField.font!])
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

        self.setupUI()
        self.bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //私有成员
    fileprivate var disposeBag = DisposeBag()
    fileprivate var viewModel: DebateInviteViewModel!
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<DebateInviteSectionModel>!
    
}

extension DebateInviteViewController {
    //初始化
    fileprivate func setupUI() {
        //PullToRefreshKit
        self.tableView.configRefreshFooter(with: FirstRefreshFooter(), action: { [weak self] () -> Void in
            self?.viewModel.inputs.refreshNewData.onNext(false)
        })
        //阴影
        GeneralFactory.generateRectShadow(layer: self.searchView.layer, rect: CGRect.init(x: 0, y: self.searchView.frame.height, width: SW, height: 0.5), color: GMColor.grey800Color().cgColor)
        self.view.bringSubview(toFront: self.searchView)
    }
    fileprivate func bindRx() {
        //View Model
        self.viewModel = DebateInviteViewModel.init(disposeBag: self.disposeBag)
        //Rx
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        dataSource = RxTableViewSectionedReloadDataSource<DebateInviteSectionModel>(
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip) as! DebateInviteTableViewCell
                
                return cell
        })
        self.tableView.rx
            .modelSelected(Friend.self)
            .subscribe(onNext: { data in
                //跳转
            })
            .disposed(by: disposeBag)
        self.viewModel.outputs.refreshStateObserver.asObservable()
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .noData:
                    break
                case .beginHeaderRefresh:
                    break
                case .endHeaderRefresh:
                    self?.tableView.switchRefreshHeader(to: .normal(.success, 0))
                    break
                case .beginFooterRefresh:
                    break
                case .endFooterRefresh:
                    self?.tableView.switchRefreshFooter(to: .normal)
                    break
                case .endRefreshWithoutData:
                    self?.tableView.switchRefreshFooter(to: .noMoreData)
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
        self.viewModel.inputs.refreshNewData.onNext(true)
    }
    //返回
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    //搜索框点击事件
    @objc fileprivate func searchViewClicked() {
        self.searchTextField.becomeFirstResponder()
    }
}

extension DebateInviteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //按下回车
        return true
    }
}

extension DebateInviteViewController: UITableViewDelegate {
    //TableViewDelegate && TableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消cell选中状态
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
