//
//  RichTextView.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/2.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit

class RichTextView: STGrowingTextView {

    open func insertImage(_ image: UIImage, mode: ImageFitMode) {
        //获取textView的所有文本，转成可变的文本
        let mutableStr = NSMutableAttributedString(attributedString: self.attributedText)
        
        //创建图片附件
        let imgAttachment = NSTextAttachment(data: nil, ofType: nil)
        var imgAttachmentString: NSAttributedString
        imgAttachment.image = image
        
        //设置图片显示方式
        if mode == .FitTextLine {
            //与文字一样大小
            imgAttachment.bounds = CGRect(x: 0, y: -4, width: self.font!.lineHeight,
                                          height: self.font!.lineHeight)
        } else if mode == .FitTextView {
            //撑满一行
            let imageWidth = self.frame.width
            let imageHeight = image.size.height/image.size.width*imageWidth
            imgAttachment.bounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        }
        
        imgAttachmentString = NSAttributedString(attachment: imgAttachment)
        
        //获得目前光标的位置
        let selectedRange = self.selectedRange
        //插入文字
        mutableStr.insert(imgAttachmentString, at: selectedRange.location)
        //设置可变文本的字体属性
        mutableStr.addAttribute(NSAttributedStringKey.font, value: self.font!,
                                range: NSMakeRange(0,mutableStr.length))
        //再次记住新的光标的位置
        let newSelectedRange = NSMakeRange(selectedRange.location+1, 0)
        
        //重新给文本赋值
        self.attributedText = mutableStr
        //恢复光标的位置, 上面一句代码执行之后, 光标会移到最后面
        self.selectedRange = newSelectedRange
        //移动滚动条, 确保光标在可视区域内
        self.scrollRangeToVisible(newSelectedRange)
    }
    
}

public enum ImageFitMode {
    case Default  //默认大小
    case FitTextLine  //使尺寸适应行高
    case FitTextView  //使尺寸适应 TextView
}
