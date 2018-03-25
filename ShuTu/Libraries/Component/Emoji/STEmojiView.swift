//
//  STEmojiView.swift
//  ShuTu
//
//  Created by yiqiang on 2018/2/9.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol STEmojiViewDelegate {
    @objc optional func emojiClicked(_ imageUrl: String)
}

class STEmojiView: UIView {
    
    //MARK: - 声明区域
    open weak var delegate: STEmojiViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: - 私有成员
    fileprivate var groupDataSouce = [[EmotionModel]]()  //大数组包含小数组
    fileprivate var emotionsDataSouce = [EmotionModel]()  //Model 数组
    fileprivate lazy var pagerView: FSPagerView = {
        let pagerView = FSPagerView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height - 20))
        pagerView.register(UINib(nibName: "STEmojiPagerViewCell", bundle: nil), forCellWithReuseIdentifier: "pagerCell")
        pagerView.itemSize = .zero
        pagerView.delegate = self
        pagerView.dataSource = self
        
        return pagerView
    }()
    fileprivate lazy var pagerControl: UIPageControl = {
        let pagerControl = UIPageControl.init(frame: CGRect.init(x: 0, y: self.bounds.height - 20, width: self.bounds.width, height: 20))
        return pagerControl
    }()

}

extension STEmojiView {
    
    //MARK: - 初始化
    fileprivate func setupUI() {
        //加载成员
        setupEmoji()
        self.addSubview(pagerView)
        self.addSubview(pagerControl)
    }
    fileprivate func setupEmoji() {
        guard let emojiArray = NSArray(contentsOfFile: STEmojiConfig.ExpressionPlist!) else {
            return
        }
        for data in emojiArray {
            let model = EmotionModel.init(fromDictionary: data as! NSDictionary)
            self.emotionsDataSouce.append(model)
        }
        self.groupDataSouce = `$`.chunk(self.emotionsDataSouce, size: 24)
        //初始化控制器
        self.pagerControl.backgroundColor = UIColor.clear
        self.pagerControl.numberOfPages = groupDataSouce.count
        self.pagerControl.currentPageIndicatorTintColor = STColor.grey500Color()
        self.pagerControl.pageIndicatorTintColor = STColor.grey50Color()
        self.pagerControl.currentPage = 0
    }
}

extension STEmojiView: FSPagerViewDelegate, FSPagerViewDataSource {
    
    //MARK: - FSPagerViewDataSource & FSPagerViewDelegate
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.groupDataSouce.count
    }
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "pagerCell", at: index) as! STEmojiPagerViewCell
        cell.row = 3
        cell.count = 24
        cell.data = self.groupDataSouce[index]
        cell.block = { imageUrl in
            self.delegate?.emojiClicked?(imageUrl)
        }
        
        return cell
    }
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        self.pagerControl.currentPage = pagerView.currentIndex
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
}

struct EmotionModel {
    
    var imageString : String!
    var text : String!
    
    init(fromDictionary dictionary: NSDictionary){
        let imageText = dictionary["image"] as! String
        imageString = "\(imageText)@2x"
        text = dictionary["text"] as? String
    }
}

class STEmojiConfig {
    
    static let ExpressionPlist = Bundle.main.path(forResource: "Expression", ofType: "plist")
    static let ExpressionBundle = Bundle(url: Bundle.main.url(forResource: "Expression", withExtension: "bundle")!)
    
    /// 获取图片路径
    static func getImagePath(_ imageString: String) -> String? {
        return self.ExpressionBundle!.path(forResource: imageString, ofType:"png")
    }
}

