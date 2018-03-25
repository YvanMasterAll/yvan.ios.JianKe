//
//  STEmojiPagerViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/2/9.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

typealias STEmojiPagerViewCellBlock = (_ imageUrl: String) -> ()

class STEmojiPagerViewCell: FSPagerViewCell {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.register(UINib.init(nibName: "STEmojiCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
            self.collectionView.showsVerticalScrollIndicator = false
            self.collectionView.showsHorizontalScrollIndicator = false
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
        }
    }
    
    //MARK: - 声明区域
    open var block: STEmojiPagerViewCellBlock?
    open var row: Int!
    open var count: Int!
    open var data: [EmotionModel]! {
        didSet {
            let width = self.bounds.width/(CGFloat(count/row))
            let height = (self.bounds.height - 0)/(CGFloat)(row)
            (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize.init(width: width, height: height)
            self.collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.needShadow = false
    }

}

extension STEmojiPagerViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - CollectionViewDelegate && DataSource
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! STEmojiCollectionViewCell
        if let path = STEmojiConfig.getImagePath(data[indexPath.row].imageString) {
            cell.setupPopView(UIImage(contentsOfFile: path)!)
            cell.imageUrl = path
            cell.block = { imageUrl in
                self.block?(imageUrl)
            }
        }
        
        return cell
    }
}
