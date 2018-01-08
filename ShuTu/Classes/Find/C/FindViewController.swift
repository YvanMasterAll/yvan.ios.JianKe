//
//  FindViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/7.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class FindViewController: UIViewController {

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.register(UINib(nibName: "FindGayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
            (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width = SW
            self.collectionView.showsVerticalScrollIndicator = false
            self.collectionView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet weak var pin1: UIView! {
        didSet {
            self.pin1.layer.cornerRadius = 1.5
            self.pin1.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var pin2: UIView! {
        didSet {
            self.pin2.layer.cornerRadius = 1.5
            self.pin2.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var pagerView1: FSPagerView! {
        didSet {
            self.pagerView1.tag = 10001
            self.pagerView1.register(UINib(nibName: "FindHotCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "findHotPagerCell")
            self.pagerView1.itemSize = CGSize.init(width: SW - 40, height: 100)
            self.pagerView1.interitemSpacing = 4
        }
    }
    @IBOutlet weak var pagerView2: FSPagerView! {
        didSet {
            self.pagerView2.tag = 10002
            self.pagerView2.register(UINib(nibName: "FindYetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "findYetPagerCell")
            self.pagerView2.itemSize = CGSize.init(width: SW - 40, height: 100)
            self.pagerView2.interitemSpacing = 4
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
        //CollectionView
        self.collectionViewHeightConstraint.constant = 62 * 4
    }
    fileprivate func bindRx() {
        
    }
}

extension FindViewController: FSPagerViewDelegate, FSPagerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    //FSPagerView Delegate && DataSource
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        if pagerView.tag == 10001 {
            return 10
        } else {
            return 10
        }
    }
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        if pagerView.tag == 10001 {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "findHotPagerCell", at: index) as! FindHotCollectionViewCell
            
            return cell
        } else {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "findYetPagerCell", at: index) as! FindYetCollectionViewCell
            
            return cell
        }
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return false
    }
    //CollectionViewDelegate && DataSource
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FindGayCollectionViewCell
        
        return cell
    }
}
