//---------------------------------------
// https://github.com/pixel-ink/PIRipple
//---------------------------------------


import UIKit

///视图点击波浪效果

/*
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
         super.touchesBegan(touches, withEvent: event)
             for touch: AnyObject in touches {
             let t: UITouch = touch as! UITouch
             let location = t.locationInView(self)

             //RIPPLE BORDER
             rippleBorder(location, color: UIColor.whiteColor())
         }
    }
    or
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
            for touch: AnyObject in touches {
            let t: UITouch = touch as! UITouch
            let location = t.locationInView(self)

            //RIPPLE FILL
            rippleFill(location, color: UIColor.whiteColor())
        }
    }
 */

public extension UIView {
    
    public func rippleBorder(_ location:CGPoint, _ color:UIColor) {
        rippleBorder(location, color){}
    }

    public func rippleBorder(_ location:CGPoint, _ color:UIColor, _ then: @escaping ()->() ) {
        Ripple.border(self, locationInView: location, color: color, then: then)
    }
    
    public func rippleFill(_ location:CGPoint, _ color:UIColor) {
        rippleFill(location, color){}
    }
    
    public func rippleFill(_ radius: CGFloat, _ location:CGPoint, _ color:UIColor) {
        rippleFill(radius, location, color){}
    }
    
    public func rippleFill(_ location:CGPoint, _ color:UIColor, _ then: @escaping ()->() ) {
        Ripple.fill(self, nil, locationInView: location, color: color, then: then)
    }
    
    public func rippleFill(_ radius: CGFloat, _ location:CGPoint, _ color:UIColor, _ then: @escaping ()->() ) {
        Ripple.fill(self, radius, locationInView: location, color: color, then: then)
    }
    
    public func rippleStop() {
        Ripple.stop(self)
    }
    
}

public class Ripple {
    
    private static var targetLayer: CALayer?
    
    public struct Option {
        public var borderWidth = CGFloat(5.0)
        public var radius = CGFloat(30.0)
        public var duration = CFTimeInterval(0.4)
        public var borderColor = UIColor.white
        public var fillColor = UIColor.clear
        public var scale = CGFloat(3.0)
    }
    
    public class func option () -> Option {
        return Option()
    }
    
    public class func border(_ view:UIView, locationInView:CGPoint, color:UIColor, then: @escaping ()->() ) {
        var opt = Ripple.Option()
        opt.borderColor = color
        prePreform(view, point: locationInView, option: opt, then: then)
    }
    
    public class func fill(_ view: UIView, _ radius: CGFloat, _ locationInView:CGPoint, _ color:UIColor) {
        fill(view, radius, locationInView: locationInView, color: color){}
    }
    
    public class func fill(_ view:UIView, _ radius: CGFloat?, locationInView:CGPoint, color:UIColor, then: @escaping ()->() ) {
        var opt = Ripple.Option()
        opt.borderColor = color
        opt.fillColor = color
        if radius != nil { opt.radius = radius! }
        prePreform(view, point: locationInView, option: opt, then: then)
    }
    
    private class func prePreform(_ view:UIView, point:CGPoint, option: Ripple.Option, then: @escaping ()->() ) {
        
        //let p = isLocationInView ? CGPoint.init(x: point.x + view.frame.origin.x, y: point.y + view.frame.origin.y) : point
        let p = point
        var parentview = view
        if view.superview != nil {
            parentview = view.superview!
        }
//        while let v = parentview.superview {
//            parentview = v
//        }
        perform(
            parentview,
            view,
            point:p,
            option:option,
            then: then
        )
    }
    
    private class func perform(_ parent: UIView, _ view:UIView, point:CGPoint, option: Ripple.Option, then: @escaping ()->() ) {
        UIGraphicsBeginImageContextWithOptions ( CGSize.init(width: (option.radius + option.borderWidth) * 2, height: (option.radius + option.borderWidth) * 2), false, 3.0)
        let path = UIBezierPath(
            roundedRect: CGRect.init(x: option.borderWidth, y: option.borderWidth, width: option.radius * 2, height: option.radius * 2),
            cornerRadius: option.radius)
        option.fillColor.setFill()
        path.fill()
        option.borderColor.setStroke()
        path.lineWidth = option.borderWidth
        path.stroke()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.autoreverses = false
        opacity.fillMode = kCAFillModeForwards
        opacity.isRemovedOnCompletion = false
        opacity.duration = option.duration
        opacity.fromValue = 1.0
        opacity.toValue = 0.0
        
        let transform = CABasicAnimation(keyPath: "transform")
        transform.autoreverses = false
        transform.fillMode = kCAFillModeForwards
        transform.isRemovedOnCompletion = false
        transform.duration = option.duration
        
        transform.fromValue = NSValue.init(caTransform3D: CATransform3DMakeScale(1.0 / option.scale, 1.0 / option.scale, 1.0))
        transform.toValue = NSValue(caTransform3D: CATransform3DMakeScale(option.scale, option.scale, 1.0))
        
//        var rippleLayer:CALayer? = targetLayer
//
//        if rippleLayer == nil {
//            rippleLayer = CALayer()
//            rippleLayer?.masksToBounds = true
//            parent.layer.addSublayer(rippleLayer!)
//            targetLayer = rippleLayer
//            targetLayer?.addSublayer(CALayer())//Temporary, CALayer.sublayers is Implicitly Unwrapped Optional
//        }
//
//        rippleLayer?.frame = view.frame
//        rippleLayer?.backgroundColor = UIColor.red.cgColor
//        print(view.frame)
        
        let rippleLayer = CALayer()
        rippleLayer.masksToBounds = true
        parent.layer.addSublayer(rippleLayer)
        targetLayer = rippleLayer
        targetLayer?.addSublayer(CALayer())
        rippleLayer.frame = view.frame
        
        DispatchQueue.main.async {
            [weak rippleLayer] in
            if let target = rippleLayer {
                let layer = CALayer()
                layer.contents = img?.cgImage
                //layer.frame = CGRect.init(x: point.x - option.radius, y: point.y - option.radius, width: option.radius * 2, height: option.radius * 2)
                //layer.frame = CGRect.init(x: point.x - option.radius, y: point.y, width: option.radius * 2, height: option.radius * 2)
                layer.frame = CGRect.init(x: point.x - option.radius, y: point.y - option.radius, width: option.radius * 2, height: option.radius * 2)
                target.addSublayer(layer)
                CATransaction.begin()
                CATransaction.setAnimationDuration(option.duration)
                CATransaction.setCompletionBlock {
                    layer.contents = nil
                    layer.removeAllAnimations()
                    layer.removeFromSuperlayer()
                    target.removeFromSuperlayer()
                    then()
                }
                layer.add(opacity, forKey:nil)
                layer.add(transform, forKey:nil)
                CATransaction.commit()
            }
        }
    }
    
    public class func stop(_ view:UIView) {
        
        guard let sublayers = targetLayer?.sublayers else {
            return
        }
        
        for layer in sublayers {
            layer.removeAllAnimations()
        }
    }
    
}
