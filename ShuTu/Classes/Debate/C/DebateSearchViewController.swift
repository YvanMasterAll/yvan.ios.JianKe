//
//  DebateSearchViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/14.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class DebateSearchViewController: UIViewController {

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
        
        //Hot Topic
        Environment.searchHot = ["冲顶大会", "李小璐被爆出轨", "PGOne道歉", "今日小寒", "绝地求生吃鸡", "五五开使用外挂", "公司该不该招应届生", "拿到年终奖马上辞职厚不厚到"]
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //阴影
        GeneralFactory.generateRectShadow(layer: self.searchView.layer, rect: CGRect.init(x: 0, y: self.searchView.frame.height, width: SW, height: 0.5), color: GMColor.grey800Color().cgColor)
        self.view.bringSubview(toFront: self.searchView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }
    
    //私有成员
    fileprivate var categories: [String]!
    fileprivate var histories: [String]!

}

extension DebateSearchViewController {
    //初始化
    fileprivate func setupUI() {
        self.setupCategoryLayout()
        self.setupHistoryLayout()
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
            button.setTitleColor(GMColor.grey500Color(), for: .normal)
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
            button.setTitleColor(GMColor.grey500Color(), for: .normal)
            button.backgroundColor = UIColor.white
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            button.contentEdgeInsets.left = 10
            button.contentEdgeInsets.right = 10
            button.imageEdgeInsets.right = 8
            button.layer.cornerRadius = 1
            button.clipsToBounds = true
            button.setImage(UIImage.init(icon: .fontAwesome(.history), size: CGSize.init(width: 20, height: 20), textColor: GMColor.grey500Color(), backgroundColor: UIColor.clear), for: .normal)
            let divider = UIView.init(frame: CGRect.init(x: 0, y: btnH - 0.5, width: width, height: 0.5))
            divider.backgroundColor = GMColor.grey50Color()
            button.addSubview(divider)
            let removeImage = UIImageView.init(image: UIImage.init(icon: .fontAwesome(.remove), size: CGSize.init(width: 20, height: 20), textColor: GMColor.grey500Color(), backgroundColor: UIColor.clear))
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
    //搜索框点击事件
    @objc fileprivate func searchViewClicked() {
        self.searchTextField.becomeFirstResponder()
    }
    //返回
    @objc fileprivate func goBack() {
        if (navigationController != nil) {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    //删除历史搜索记录
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

extension DebateSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let target = self.searchTextField.text!.trimmed
        if target == "" { return false }
        //添加历史搜索记录
        Environment.addHistory(target)
        self.setupHistoryLayout()
        return true
    }
}
