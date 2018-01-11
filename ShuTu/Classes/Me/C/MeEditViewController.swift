//
//  MeEditViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/10.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class MeEditViewController: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.gotoPhotoPicker))
            self.thumbnail.isUserInteractionEnabled = true
            self.thumbnail.addGestureRecognizer(tapGes)
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView() //消除底部视图
            self.tableView.separatorStyle = .none //消除分割线
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
    fileprivate var selectedAssets = [TLPHAsset]()
    fileprivate lazy var photoPicker: TLPhotosPickerViewController = {
        let photoPicker = TLPhotosPickerViewController()
        photoPicker.delegate = self
        photoPicker.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            //图片数超过设定
        }
        var configure = TLPhotosPickerConfigure()
        configure.maxSelectedAssets = 1
        configure.numberOfColumn = 3
        configure.allowedVideo = false
        photoPicker.configure = configure
        photoPicker.selectedAssets = self.selectedAssets
        
        return photoPicker
    }()
    
}

extension MeEditViewController {
    //初始化
    fileprivate func setupUI() {
        //Navigation
        self.navigationItem.title = "资料编辑"
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
    }
    //修改头像
    @objc fileprivate func gotoPhotoPicker() {
        self.present(self.photoPicker, animated: true, completion: nil)
    }
    fileprivate func setThumbnail() {
        if let asset = self.selectedAssets.first {
            if let image = asset.fullResolutionImage {
                self.thumbnail.image = image
            } else {
                //获取图片资源错误
            }
        }
    }
}

fileprivate var data: Dictionary<String, [String]> = ["title": ["昵称", "性别", "个人简历"], "content": ["吃饭很幸苦的", "男", "插科打挥可以的"]]
extension MeEditViewController: UITableViewDelegate, TLPhotosPickerViewControllerDelegate, UITableViewDataSource {
    //TableView Delegate && DataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let alert = UIAlertController.init(title: "修改昵称", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField: UITextField!) in
                textField.placeholder = "请输入昵称"
                textField.text = data["content"]![0]
            })
            let cancle = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            let ok = UIAlertAction.init(title: "保存", style: .default, handler: { [weak self] action in
                let nickname = alert.textFields!.first!.text!
                data["content"]![0] = nickname
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
                data["content"]![1] = "男"
                self?.tableView.reloadData()
            })
            let girl = UIAlertAction.init(title: "女", style: .default, handler: { [weak self] action in
                data["content"]![1] = "女"
                self?.tableView.reloadData()
            })
            alert.addAction(cancle)
            alert.addAction(boy)
            alert.addAction(girl)
            self.present(alert, animated: true, completion: nil)
            break
        case 2:
            let meStoryboard = UIStoryboard.init(name: "Me", bundle: nil)
            let meEditIntroVC = meStoryboard.instantiateViewController(withIdentifier: "MeEditIntro") as! MeEditIntroViewController
            meEditIntroVC.intro = data["content"]![2]
            meEditIntroVC.block = { [weak self] text in
                data["content"]![2] = text
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
        title.text = data["title"]![indexPath.row]
        let content = cell.viewWithTag(10002) as! UILabel
        content.text = data["content"]![indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
    //TLPhotosPickerViewControllerDelegate
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

