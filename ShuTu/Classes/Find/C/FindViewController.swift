//
//  FindViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/7.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class FindViewController: UIViewController {

    @IBOutlet weak var pagerView1: FSPagerView! {
        didSet {
            self.pagerView1.tag = 10001
            self.pagerView1.register(UINib(nibName: "FindHotCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "findHotPagerCell")
            self.pagerView1.itemSize = CGSize.init(width: SW - 20, height: 100)
            self.pagerView1.interitemSpacing = 0
//            self.pagerView1.transformer = FSPagerViewTransformer(type: .linear)
        }
    }
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
                self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //NavigationBar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: self, action: nil)
        self.navigationController?.navigationBar.barTintColor = GMColor.grey50Color()
    }
    
    deinit {
        print("deinit: \(type(of: self))")
    }

}

extension FindViewController {
    //初始化
    fileprivate func setupUI() {
    
    }
    fileprivate func bindRx() {
        
    }
}

extension FindViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    //FSPagerView Delegate && DataSource
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 10
    }
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
//        if pagerView.tag == 10001 {
//
//        }
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "findHotPagerCell", at: index) as! FindHotCollectionViewCell
        
        return cell
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return false
    }
}
