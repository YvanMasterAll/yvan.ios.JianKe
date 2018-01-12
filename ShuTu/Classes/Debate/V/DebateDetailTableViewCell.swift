//
//  DebateDetailTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/12.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class DebateDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var segmentControl: UISegmentedControl! {
        didSet {
            //SegmentControl
            self.segmentControl.addTarget(self, action: #selector(self.segmentControlChanged), for: UIControlEvents.valueChanged)
        }
    }
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(UINib(nibName: "DebateDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "pagerCell")
            self.pagerView.itemSize = .zero
            self.pagerView.delegate = self
            self.pagerView.dataSource = self
        }
    }
    
    //声明区域
    open var navigationController: UINavigationController!
    open var section: Debate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //私有成员
    fileprivate var viewModel: DebateDetailViewModel! {
        return DebateDetailViewModel(section: self.section)
    }

}

extension DebateDetailTableViewCell {
    //SegmengControl Changed
    @objc fileprivate func segmentControlChanged(sender: UISegmentedControl) {
        self.pagerView.scrollToItem(at: sender.selectedSegmentIndex, animated: true)
    }
}

extension DebateDetailTableViewCell: FSPagerViewDelegate, FSPagerViewDataSource {
    //FSPagerViewDataSource & FSPagerViewDelegate
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 2
    }
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        //SegmentControl
        guard self.segmentControl.selectedSegmentIndex != pagerView.currentIndex else {
            return
        }
        self.segmentControl.selectedSegmentIndex = pagerView.currentIndex
    }
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "pagerCell", at: index) as! DebateDetailCollectionViewCell
        cell.navigationController = self.navigationController
        //Side
        if index == 0 {
            cell.side = .SY
        } else {
            cell.side = .ST
        }
        //传入 VM
        if cell.viewModel == nil {
            cell.viewModel = self.viewModel
        }
        //传入 Model
        cell.section = self.section
        
        return cell
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
}
