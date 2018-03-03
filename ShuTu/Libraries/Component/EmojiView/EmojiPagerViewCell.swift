//
//  EmojiPagerViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/2/9.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

typealias EmojiPagerViewCellBlock = (_ imageUrl: String) -> ()

class EmojiPagerViewCell: FSPagerViewCell {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.register(UINib.init(nibName: "EmojiCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
            self.collectionView.showsVerticalScrollIndicator = false
            self.collectionView.showsHorizontalScrollIndicator = false
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
        }
    }
    
    //声明区域
    open var block: EmojiPagerViewCellBlock?
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

extension EmojiPagerViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    //CollectionViewDelegate && DataSource
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! EmojiCollectionViewCell
        if let path = EmojiConfig.getImagePath(data[indexPath.row].imageString) {
            cell.setupPopView(UIImage(contentsOfFile: path)!)
            cell.imageUrl = path
            cell.block = { imageUrl in
                self.block?(imageUrl)
            }
        }
        
        return cell
    }
}
