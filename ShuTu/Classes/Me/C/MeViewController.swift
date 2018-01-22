//
//  MeViewController
//  ShuTu
//
//  Created by yiqiang on 2018/1/8.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MeViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableViewHeader: UIView!
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
            self.thumbnail.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.gotoMeEdit))
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
        
        //导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    //私有成员
    fileprivate lazy var headerView2: UIView = { //用户未登录的表头
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        let button = UIButton.init(frame: CGRect.zero)
        view.addSubview(button)
        button.snp.makeConstraints{ make in
            make.width.equalTo(100)
            make.height.equalTo(38)
            make.center.equalTo(view)
        }
        button.setTitle("请先登录", for: .normal)
        button.setTitleColor(ColorPrimary, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = ColorPrimary.cgColor
        button.addTarget(self, action: #selector(self.gotoLogin), for: .touchUpInside)
        self.tableViewHeader.addSubview(view)
        view.snp.makeConstraints{ make in
            make.left.equalTo(self.tableViewHeader)
            make.right.equalTo(self.tableViewHeader)
            make.top.equalTo(self.tableViewHeader)
            make.bottom.equalTo(self.tableViewHeader)
        }
        view.isHidden = true
        
        return view
    }()
    fileprivate var isLogin: Bool = Environment.tokenExists //用户是否登录
    fileprivate var disposeBag = DisposeBag()
    
}

extension MeViewController {
    //初始化
    fileprivate func setupUI() {
        //判断用户是否登录
        if !isLogin {
            self.headerView.isHidden = true
            self.headerView2.isHidden = false
        }
        //登录通知
        LoginStatus.subscribe(onNext: { [weak self] state in
            switch state {
            case .ok:
                self?.isLogin = true
                self?.headerView.isHidden = false
                self?.headerView2.isHidden = true
            case .out:
                self?.isLogin = false
                self?.headerView.isHidden = true
                self?.headerView2.isHidden = false
            default:
                break
            }
        }).disposed(by: self.disposeBag)
    }
    //Goto MeEdit
    @objc fileprivate func gotoMeEdit() {
        let meStoryboard = UIStoryboard.init(name: "Me", bundle: nil)
        let meeditVC = meStoryboard.instantiateViewController(withIdentifier: "MeEdit")
        
        self.slideMenuController()?.pushViewControllerFromMain(meeditVC, close: true)
    }
    //Goto Login
    @objc fileprivate func gotoLogin() {
        self.slideMenuController()?.closeLeft()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName3), object: nil, userInfo: ["type": "push"])
    }
    
}

fileprivate var data: Dictionary<String, [String]> = ["title": ["所有动态", "我的收藏", "我的声援", "我的殊途", "我的同归"], "icon": ["icon_dynamic_grey500", "icon_keep_grey500", "icon_sy_grey500", "icon_st_grey500", "icon_tg_grey500"]]
extension MeViewController: UITableViewDelegate, UITableViewDataSource {
    //TableView Delegate && DataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中
        tableView.deselectRow(at: indexPath, animated: true)
        //判断登录
        if !self.isLogin {
            self.gotoLogin()
            return
        }
        switch indexPath.row {
        case 0:
            let meStoryboard = UIStoryboard.init(name: "Me", bundle: nil)
            let meSpaceVC = meStoryboard.instantiateViewController(withIdentifier: "MeSpace")
            
            self.slideMenuController()?.pushViewControllerFromMain(meSpaceVC, close: true)
            break
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let title = cell.viewWithTag(10001) as! UILabel
        title.text = data["title"]![indexPath.row]
        let image = cell.viewWithTag(10002) as! UIImageView
        image.image = UIImage.init(named: data["icon"]![indexPath.row])
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
}
