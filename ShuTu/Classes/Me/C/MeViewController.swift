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

class MeViewController: BaseViewController {

    @IBOutlet weak var fans: UIView! {
        didSet {
            self.fans.isUserInteractionEnabled = true
            self.fans.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.gotoMeJoinFA)))
        }
    }
    @IBOutlet weak var followPerson: UIView! {
        didSet {
            self.followPerson.isUserInteractionEnabled = true
            self.followPerson.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.gotoMeJoinFP)))
        }
    }
    @IBOutlet weak var followTopic: UIView! {
        didSet {
            self.followTopic.isUserInteractionEnabled = true
            self.followTopic.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.gotoMeJoinFT)))
        }
    }
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableViewHeader: UIView!
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
            self.thumbnail.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.gotoMeEdit))
            self.thumbnail.addGestureRecognizer(tapGes)
            if let t = Environment.protrait {
                self.thumbnail.kf.setImage(with: URL.init(string: t))
            }
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
        self.setupUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func loginIn() {
        self.headerView.isHidden = false
        self.headerView2.isHidden = true
    }

    override func loginOut() {
        self.headerView.isHidden = true
        self.headerView2.isHidden = false
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
    fileprivate var disposeBag = DisposeBag()
    fileprivate var menuData: [[String: Any]] = [[:]]
    
}

extension MeViewController {
    //初始化
    fileprivate func setupUI() {
        //判断用户是否登录
        if !isLogin {
            self.headerView.isHidden = true
            self.headerView2.isHidden = false
        }
        //获取菜单数据
        self.setupMenuData()
    }
    fileprivate func setupMenuData() {
        //Json
        guard let path = Bundle.main.path(forResource: "menuData.json", ofType: nil),
            let data = NSData.init(contentsOfFile: path),
            let jsonData = try? JSONSerialization.jsonObject(with: data as Data, options: []) as? [[String: Any]]
            else { return }
        self.menuData = jsonData!
    }
    fileprivate func setupUserInfo() {
        //初始化获取用户信息
        let label1 = self.followTopic.viewWithTag(10001) as! UILabel
        let label2 = self.followPerson.viewWithTag(10002) as! UILabel
        let label3 = self.fans.viewWithTag(10003) as! UILabel
        label1.text = "\(Environment.followtopics ?? 0)"
        label2.text = "\(Environment.followpersons ?? 0)"
        label3.text = "\(Environment.fans ?? 0)"
        if isLogin {
            MeService.instance.userinfo().asObservable()
                .subscribe(onNext: { response in
                    let userinfo = response.0
                    let result = response.1
                    switch result {
                    case .ok:
                        label1.text = "\(userinfo?.followtopics ?? 0)"
                        label2.text = "\(userinfo?.follows ?? 0)"
                        label3.text = "\(userinfo?.fans ?? 0)"
                        break
                    default:
                        break
                    }
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    //按钮事件
    @objc fileprivate func gotoMeEdit() {
        let meeditVC = GeneralFactory.getVCfromSb("Me", "MeEdit")
        
        self.slideMenuController()?.pushViewControllerFromMain(meeditVC, close: true)
    }
    @objc fileprivate func gotoLogin() {
        self.slideMenuController()?.closeLeft()
        self.gotoLoginPage()
    }
    @objc fileprivate func gotoMeJoinFT() {
        let meJoinVC = GeneralFactory.getVCfromSb("Me", "MeJoin") as! MeJoinViewController
        meJoinVC.navTitle = "我关注的话题"
        meJoinVC.type = MeJoinType.followtopic
        
        self.slideMenuController()?.pushViewControllerFromMain(meJoinVC, close: true)
    }
    @objc fileprivate func gotoMeJoinFA() {
        let meJoinVC = GeneralFactory.getVCfromSb("Me", "MeJoin") as! MeJoinViewController
        meJoinVC.navTitle = "关注我的人"
        meJoinVC.type = MeJoinType.fan
        
        self.slideMenuController()?.pushViewControllerFromMain(meJoinVC, close: true)
    }
    @objc fileprivate func gotoMeJoinFP() {
        let meJoinVC = GeneralFactory.getVCfromSb("Me", "MeJoin") as! MeJoinViewController
        meJoinVC.navTitle = "我关注的人"
        meJoinVC.type = MeJoinType.followperson
        
        self.slideMenuController()?.pushViewControllerFromMain(meJoinVC, close: true)
    }
    
}

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
            let meSpaceVC = GeneralFactory.getVCfromSb("Me", "MeSpace")
            self.slideMenuController()?.pushViewControllerFromMain(meSpaceVC, close: true)
            break
        case 1:
            let meJoinVC = GeneralFactory.getVCfromSb("Me", "MeJoin") as! MeJoinViewController
            meJoinVC.navTitle = "我的收藏"
            meJoinVC.type = MeJoinType.collect
            self.slideMenuController()?.pushViewControllerFromMain(meJoinVC, close: true)
            break
        case 2:
            let meJoinVC = GeneralFactory.getVCfromSb("Me", "MeJoin") as! MeJoinViewController
            meJoinVC.navTitle = "我的支持"
            meJoinVC.type = MeJoinType.support
            self.slideMenuController()?.pushViewControllerFromMain(meJoinVC, close: true)
            break
        case 3:
            let meJoinVC = GeneralFactory.getVCfromSb("Me", "MeJoin") as! MeJoinViewController
            meJoinVC.navTitle = "我的话题"
            meJoinVC.type = MeJoinType.topic
            self.slideMenuController()?.pushViewControllerFromMain(meJoinVC, close: true)
            break
        case 4:
            let meJoinVC = GeneralFactory.getVCfromSb("Me", "MeJoin") as! MeJoinViewController
            meJoinVC.navTitle = "我的观点"
            meJoinVC.type = MeJoinType.viewpoint
            self.slideMenuController()?.pushViewControllerFromMain(meJoinVC, close: true)
            break
        case 5:
            let alertController = UIAlertController(title: "提示", message: "退出登录？", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: { _ in
                Environment.clearUserInfo()
                LoginStatus.onNext(LoginState.out)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let title = cell.viewWithTag(10001) as! UILabel
        title.text = menuData[indexPath.row]["title"] as? String
        let image = cell.viewWithTag(10002) as! UIImageView
        image.image = UIImage.init(named: (menuData[indexPath.row]["icon"] as? String)!)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
}
