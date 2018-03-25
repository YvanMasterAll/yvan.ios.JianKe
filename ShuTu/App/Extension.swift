//
//  Extension.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/14.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import ObjectMapper

/// 常用扩展

/// 字符串扩展
extension String {
    
    /// 除去空格
    public var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// URL Escape
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    /// 正则表达式获取目标值
    /// - parameter pattern: 一个字符串类型的正则表达式
    /// - parameter str: 需要比较判断的对象
    /// - returns: 返回字符串数组
    public func regexGetSub(pattern:String, str:String) -> [String] {
        var subStr = [String]()
        let regex = try! NSRegularExpression(pattern: pattern, options:[NSRegularExpression.Options.caseInsensitive])
        let results = regex.matches(in: str, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, str.count))
        //解析出子串
        for  rst in results {
            let nsStr = str as  NSString
            subStr.append(nsStr.substring(with: rst.range))
        }
        return subStr
    }
}

/// 日期扩展
extension Date {
    
    /// 日期转字符串
    /// - parameter date: 日期
    /// - parameter dateFormat: 格式字符串
    static func toString(date: Date = Date(), dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        
        return formatter.string(from: date)
    }
    
    /// 字符串转日期
    /// - parameter dateString: 日期字符串
    /// - parameter dateFormat: 格式字符串
    static func toDate(dateString: String, dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        
        return formatter.date(from: dateString)!
    }
    
}

/// UILabel
extension UILabel {
    
    /// 获取文本一行的高度
    var heightOfLine: CGFloat {
        get {
            return (self.text! as NSString).boundingRect(with: CGSize(width: self.frame.width, height:CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : self.font], context: nil).height
        }
    }
    
    /// 获取文本宽度
    var widthOfString: CGFloat {
        get {
            return (self.text! as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : self.font], context: nil).width
        }
    }
    
    /// 获取文本相应行数的高度
    /// - parameter by: 行数
    /// - returns: 返回相应行数的文本高度
    func heightOfLines(by: Int) -> CGFloat {
        var s = ""
        for i in 0..<by {
            s += "\(i)"
        }
        return (s as NSString).boundingRect(with: CGSize(width: 1, height:CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : self.font], context: 
            nil).height
    }
    
}

/// UIView
extension UIView {
    
    /// 加载 XIB, 返回 UIView
    func loadViewFromNib() -> UIView {
        let className = type(of: self)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
}

/// UIImage
extension UIImage {
    
    /// 重设图片尺寸
    func reSizeImage(_ reSize: CGSize)->UIImage {
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale)
        self.draw(in: CGRect.init(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return reSizeImage
    }
    
    /// 等比例缩放
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        
        return reSizeImage(reSize)
    }
    
    /// 为图片叠加颜色
    public func imageWithTintColor(_ color : UIColor) -> UIImage{
        UIGraphicsBeginImageContext(self.size)
        color.setFill()
        let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage!
    }
}

/// UIImageVIew
extension UIImageView {
    
    /// 更改图片颜色
    public func changeImageColor(_ color : UIColor){
        let maskLayer = CALayer.init()
        maskLayer.frame = self.bounds
        //maskLayer.contents = GeneralFactory.createImageWithColor(color)
        maskLayer.backgroundColor = color.cgColor
        self.layer.addSublayer(maskLayer)
        
        self.clipsToBounds = true
    }
}

