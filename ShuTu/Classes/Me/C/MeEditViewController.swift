//
//  MeEditViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/10.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MeEditViewController: BaseViewController {
    
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
            self.thumbnail.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.gotoPhotoPicker))
            self.thumbnail.addGestureRecognizer(tapGes)
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
        }
    }
    
    //MARK: - 声明区域
    open var userinfo: UserInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideNavbar = true
        setupUI()
        bindRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //显示导航栏
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "资料编辑"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "保存", style: .plain, target: self, action: #selector(self.saveUserInfo))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - 私有成员
    fileprivate var viewModel: MeEditViewModel!
    fileprivate var disposeBag = DisposeBag()
    fileprivate var selectedAssets = [TLPHAsset]()
    fileprivate lazy var photoPicker: TLPhotosPickerViewController! = {
        //相册控制器
        let photoPicker = GeneralFactory.generatePhotoPicker(self.selectedAssets)
        photoPicker.delegate = self
        
        return photoPicker
    }()
    fileprivate var imagePath: String?
    fileprivate var nickname: String?
    fileprivate var gender: String?
    fileprivate var signature: String?
    
}

extension MeEditViewController {
    
    //MARK: - 初始化
    fileprivate func setupUI() {
        //用户信息
        self.nickname = userinfo.nickname
        self.gender = userinfo.gender
        self.signature = userinfo.signature
        if let t = userinfo.portrait {
            self.thumbnail.kf.setImage(with: URL.init(string: t))
        }
    }
    fileprivate func bindRx() {
        //View Model
        self.viewModel = MeEditViewModel.init(disposeBag: self.disposeBag)
        self.viewModel.outputs.saveResult.asObservable()
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .ok:
                    HUD.flash(.label("保存成功"))
                    //更新用户信息
                    self.userinfoRefresh(nil)
                    //退出编辑
                    self.navigationController?.popViewController(animated: true)
                case .failed:
                    HUD.flash(.label("保存失败"))
                default:
                    HUD.hide()
                    break
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    //MARK: - 修改头像
    @objc fileprivate func gotoPhotoPicker() {
        self.present(self.photoPicker, animated: true, completion: nil)
    }
    fileprivate func setThumbnail() {
        if let asset = self.selectedAssets.first {
            if let image = asset.fullResolutionImage {
                self.thumbnail.image = image
                asset.fullResolutionImagePath(handler: { [unowned self] imagePath in
                    self.imagePath = imagePath
                })
            } else {
                //获取图片资源错误
            }
            self.photoPicker.selectedAssets.removeAll()
        }
    }
    
    //MARK: - 保存用户信息
    @objc fileprivate func saveUserInfo() {
        var p: [String: Any] = [:]
        if let url = self.imagePath {
            p["url"] = url
        }
        if self.nickname != userinfo.nickname {
            p["nickname"] = nickname
        }
        if self.gender != userinfo.gender {
            p["gender"] = gender
        }
        if self.signature != userinfo.signature {
            p["signature"] = signature
        }

        self.viewModel.inputs.saveTap.onNext(p)
    }
}

extension MeEditViewController: UITableViewDelegate, TLPhotosPickerViewControllerDelegate, UITableViewDataSource {
    
    //MARK: - TableView Delegate && DataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let alert = UIAlertController.init(title: "修改昵称", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { [unowned self] (textField: UITextField!) in
                textField.placeholder = "请输入昵称"
                textField.text = self.nickname
            })
            let cancle = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            let ok = UIAlertAction.init(title: "保存", style: .default, handler: { [weak self] action in
                self?.nickname = alert.textFields!.first!.text!
                self?.tableView.reloadData()
            })
            alert.addAction(cancle)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            break
        case 1:
            let alert = UIAlertController.init(title: "选择性别", message: "", preferredStyle: .actionSheet)
            let cancle = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            let boy = UIAlertAction.init(title: "男", style: .default, handler: { [weak self] action in
                self?.gender = "男"
                self?.tableView.reloadData()
            })
            let girl = UIAlertAction.init(title: "女", style: .default, handler: { [weak self] action in
                self?.gender = "女"
                self?.tableView.reloadData()
            })
            alert.addAction(cancle)
            alert.addAction(boy)
            alert.addAction(girl)
            self.present(alert, animated: true, completion: nil)
            break
        case 2:
            let meEditIntroVC = GeneralFactory.getVCfromSb("Me", "MeEditIntro") as! MeEditIntroViewController
            meEditIntroVC.signature = signature
            meEditIntroVC.block = { [weak self] text in
                self?.signature = text
                self?.tableView.reloadData()
            }
            
            self.navigationController?.pushViewController(meEditIntroVC, animated: true)
            break
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let title = cell.viewWithTag(10001) as! UILabel
        let content = cell.viewWithTag(10002) as! UILabel
        switch indexPath.row {
        case 0:
            title.text = "昵称"
            content.text = nickname
            break
        case 1:
            title.text = "性别"
            content.text = gender
            break
        case 2:
            title.text = "个性签名"
            content.text = signature
            break
        default:
            break
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
    
    //MAKR: - TLPhotosPickerViewControllerDelegate
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        //获取选中图片
        self.selectedAssets = withTLPHAssets
        //修改头像
        self.setThumbnail()
    }
    func dismissComplete() {
        
    }
    func photoPickerDidCancel() {
        
    }
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        
    }
}

