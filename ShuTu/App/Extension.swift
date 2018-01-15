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

//请求响应本地处理
class StubResponse { //Stub<存根>
    static var stubJsonPath = ""
    static func fromJSONFile(filePath: String = stubJsonPath) -> Data {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            fatalError("Invalid data from json file")
        }
        return data
    }
    static func jsonResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data // fallback to original data if it can't be serialized.
        }
    }
}
//Moya 响应扩展 - Model 映射
public extension Response {
    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> T {
        guard let object = Mapper<T>(context: context).map(JSONObject: try mapJSON()) else {
            throw MoyaError.jsonMapping(self)
        }
        return object
    }
    /// Maps data received from the signal into an array of objects which implement the Mappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) throws -> [T] {
//        print(self.mapJSON())
        guard let array = try mapJSON() as? [[String : Any]] else {
            throw MoyaError.jsonMapping(self)
        }
        return Mapper<T>(context: context).mapArray(JSONArray: array)
    }
}
// MARK: - ImmutableMappable
public extension Response {
    /// Maps data received from the signal into an object which implements the ImmutableMappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapObject<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) throws -> T {
        return try Mapper<T>(context: context).map(JSONObject: try mapJSON())
    }
    /// Maps data received from the signal into an array of objects which implement the ImmutableMappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapArray<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) throws -> [T] {
        guard let array = try mapJSON() as? [[String : Any]] else {
            throw MoyaError.jsonMapping(self)
        }
        return try Mapper<T>(context: context).mapArray(JSONArray: array)
    }
}
/// Extension for processing Responses into Mappable objects through ObjectMapper
public extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    /// Maps data received from the signal into an object
    /// which implements the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<T> {
        return flatMap { response -> Single<T> in
            return Single.just(try response.mapObject(type, context: context))
        }
    }
    /// Maps data received from the signal into an array of objects
    /// which implement the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<[T]> {
        return flatMap { response -> Single<[T]> in
            return Single.just(try response.mapArray(type, context: context))
        }
    }
}
// MARK: - ImmutableMappable
public extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Response {
    /// Maps data received from the signal into an object
    /// which implements the ImmutableMappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapObject<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<T> {
        return flatMap { response -> Single<T> in
            return Single.just(try response.mapObject(type, context: context))
        }
    }
    /// Maps data received from the signal into an array of objects
    /// which implement the ImmutableMappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapArray<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<[T]> {
        return flatMap { response -> Single<[T]> in
            return Single.just(try response.mapArray(type, context: context))
        }
    }
}
/// Extension for processing Responses into Mappable objects through ObjectMapper
public extension ObservableType where E == Response {
    /// Maps data received from the signal into an object
    /// which implements the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(try response.mapObject(T.self, context: context))
        }
    }
    /// Maps data received from the signal into an array of objects
    /// which implement the Mappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<[T]> {
        return flatMap { response -> Observable<[T]> in
            return Observable.just(try response.mapArray(T.self, context: context))
        }
    }
}
// MARK: - ImmutableMappable
public extension ObservableType where E == Response {
    /// Maps data received from the signal into an object
    /// which implements the ImmutableMappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapObject<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(try response.mapObject(T.self, context: context))
        }
    }
    /// Maps data received from the signal into an array of objects
    /// which implement the ImmutableMappable protocol and returns the result back
    /// If the conversion fails, the signal errors.
    public func mapArray<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<[T]> {
        return flatMap { response -> Observable<[T]> in
            return Observable.just(try response.mapArray(T.self, context: context))
        }
    }
}

//字符串扩展
extension String {
    //URL Encode
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

//日期扩展
extension Date {
    //日期转字符串
    static func toString(date: Date = Date(), dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        
        return formatter.string(from: date)
    }
    //字符串转日期
    static func toDate(dateString: String, dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let timeZone = TimeZone.init(identifier: "UTC")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        
        return formatter.date(from: dateString)!
    }
}

//UILabel 扩展
extension UILabel {
    var heightOfLine: CGFloat {
        get {
            return (self.text! as NSString).boundingRect(with: CGSize(width: self.frame.width, height:CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : self.font], context: nil).height
        }
    }
    var widthOfString: CGFloat {
        get {
            return (self.text! as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : self.font], context: nil).width
        }
    }
    func heightOfLines(by: Int) -> CGFloat {
        var s = ""
        for i in 0..<by {
            s += "\(i)"
        }
        return (s as NSString).boundingRect(with: CGSize(width: 1, height:CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : self.font], context: nil).height
    }
}


//UIView 扩展

extension UIView {
    //生成外阴影
    open func generateOuterShadow() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = layer.cornerRadius
        view.layer.shadowRadius = layer.shadowRadius
        view.layer.shadowOpacity = layer.shadowOpacity
        view.layer.shadowColor = layer.shadowColor
        view.layer.shadowOffset = CGSize.zero
        view.clipsToBounds = false
        view.backgroundColor = .white
        
        superview?.insertSubview(view, belowSubview: self)
        
        let constraints = [
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            ]
        superview?.addConstraints(constraints)
    }
    //生成内阴影
    open func generateInnerShadow() {
        let view = SwiftyInnerShadowView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.shadowLayer.cornerRadius = layer.cornerRadius
        view.shadowLayer.shadowRadius = layer.shadowRadius
        view.shadowLayer.shadowOpacity = layer.shadowOpacity
        view.shadowLayer.shadowColor = layer.shadowColor
        view.shadowLayer.shadowOffset = CGSize.zero
        view.clipsToBounds = false
        view.backgroundColor = .clear
        
        superview?.insertSubview(view, aboveSubview: self)
        
        let constraints = [
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            ]
        superview?.addConstraints(constraints)
    }
    //生成底部阴影
    open func generateEllipticalShadow() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = layer.cornerRadius
        view.layer.shadowRadius = layer.shadowRadius
        view.layer.shadowOpacity = layer.shadowOpacity
        view.layer.shadowColor = layer.shadowColor
        view.layer.shadowOffset = CGSize.zero
        view.clipsToBounds = false
        view.backgroundColor = .white
        
        let ovalRect = CGRect(x: 0, y: frame.size.height + 10, width: frame.size.width, height: 15)
        let path = UIBezierPath(ovalIn: ovalRect)
        
        view.layer.shadowPath = path.cgPath
        
        superview?.insertSubview(view, belowSubview: self)
        
        let constraints = [
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            ]
        superview?.addConstraints(constraints)
    }
    
}

//扩展 UIImage
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
    /// 更改图片颜色
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

//扩展 String
extension String {
    //除去空格
    public var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
