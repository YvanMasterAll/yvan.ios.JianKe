//
//  MeViewController
//  ShuTu
//
//  Created by yiqiang on 2018/1/8.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {

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
    
}

extension MeViewController {
    //初始化
    fileprivate func setupUI() {
        
    }
    //Goto MeEdit
    @objc fileprivate func gotoMeEdit() {
        let meStoryboard = UIStoryboard.init(name: "Me", bundle: nil)
        let meeditVC = meStoryboard.instantiateViewController(withIdentifier: "MeEdit")
        
        self.slideMenuController()?.pushViewControllerFromMain(meeditVC, close: true)
//        self.navigationController?.pushViewController(meeditVC, animated: true)
    }
    
}

fileprivate var data: Dictionary<String, [String]> = ["title": ["所有动态", "我的收藏", "我的声援", "我的殊途", "我的同归"], "icon": ["icon_dynamic_grey500", "icon_keep_grey500", "icon_sy_grey500", "icon_st_grey500", "icon_tg_grey500"]]
extension MeViewController: UITableViewDelegate, UITableViewDataSource {
    //TableView Delegate && DataSource
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //取消选中
        tableView.deselectRow(at: indexPath, animated: true)
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
