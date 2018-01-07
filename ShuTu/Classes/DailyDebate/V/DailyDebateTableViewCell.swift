//
//  DailyDebateTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/6.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class DailyDebateTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension DailyDebateTableViewCell {
    func cellOnTableView(tableView: UITableView, didScrollOnView view: UIView) {
//        //取得当前区域
//        let rectInSuperview = tableView.convert(self.frame, to: view)
//        //位移相对于中心点的距离
//        let distanceFromCenter = view.frame.height/2 - rectInSuperview.minY
//        //图片大于区域的高度就是视觉差高度
//        let parallaxHeight = imageView.frame.height - frame.height
//        // 以cell相對view中心點移動的距離，來計算視差的移動距離
//        let move = (distanceFromCenter / view.frame.height) * parallaxHeight
//        // 先將imageView向上移動一半的視差高度(difference/2)，然後根據move程度變化y的位置
//        var imageRect = imageView.frame
//        imageRect.origin.y = -(parallaxHeight/2) + move
//        // 給予imageView一個新的frame，達到視差效果。
//        imageView.frame = imageRect
    }
}
