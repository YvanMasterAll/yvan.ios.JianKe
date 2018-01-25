//
//  GMColor.swift
//  JianKe
//
//  Created by yiqiang on 2017/12/11.
//  Copyright © 2017年 yiqiang. All rights reserved.
//

/// Google Material Colors, 谷歌发布的颜色标准
/// 颜色处理
/// @处理一 颜色加深
/// @处理二 颜色变浅

import UIKit

extension UIColor {
    convenience init(rgb: UInt, a:CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: a
        )
    }
    
    convenience init(rgb: UInt) {
        self.init(rgb: rgb, a:1.0)
    }
    
    //颜色变亮 - 0.0~1.0
    public final func lighterByHSL(amount: CGFloat = 0.2) -> UIColor {
        return HSL(color: self).lighter(amount: amount).toUIColor()
    }
    public final func lighter(by percentage: CGFloat = 0.3) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: min(r + percentage, 1.0),
                     green: min(g + percentage, 1.0),
                     blue: min(b + percentage, 1.0),
                     alpha: a)
    }
    //颜色变暗 - 0.0~1.0
    public final func darkenByHSL(amount: CGFloat = 0.2) -> UIColor {
        return HSL(color: self).darker(amount: amount).toUIColor()
    }
    public final func darken(by percentage: CGFloat = 0.2) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: max(r - percentage, 0),
                       green: max(g - percentage, 0),
                       blue: max(b - percentage, 0),
                       alpha: a)
    }
    //调整色相 - -360~360
    public final func hued(amount: CGFloat) -> UIColor {
        return HSL(color: self).adjustedHue(amount: amount).toUIColor()
    }
    //调整饱和度 - 0.0~1.0
    public final func saturated(amount: CGFloat = 0.2) -> UIColor {
        return HSL(color: self).saturated(amount: amount).toUIColor()
    }
    //返回 RGBA
    public final func toRGBAComponents() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        
        #if os(iOS) || os(tvOS) || os(watchOS)
            getRed(&r, green: &g, blue: &b, alpha: &a)
            
            return (r, g, b, a)
        #elseif os(OSX)
            if isEqual(DynamicColor.black) {
                return (0, 0, 0, 0)
            }
            else if isEqual(DynamicColor.white) {
                return (1, 1, 1, 1)
            }
            
            getRed(&r, green: &g, blue: &b, alpha: &a)
            
            return (r, g, b, a)
        #endif
    }
}
//HSL
internal struct HSL {
    /// Hue value between 0.0 and 1.0 (0.0 = 0 degree, 1.0 = 360 degree).
    var h: CGFloat = 0
    /// Saturation value between 0.0 and 1.0.
    var s: CGFloat = 0
    /// Lightness value between 0.0 and 1.0.
    var l: CGFloat = 0
    /// Alpha value between 0.0 and 1.0.
    var a: CGFloat = 1
    
    //初始化
    init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 1) {
        h = hue.truncatingRemainder(dividingBy: 360) / 360
        s = clip(saturation, 0, 1)
        l = clip(lightness, 0, 1)
        a = clip(alpha, 0, 1)
    }
    init(color: UIColor) {
        let rgba = color.toRGBAComponents()
        
        let maximum   = max(rgba.r, max(rgba.g, rgba.b))
        let mininimum = min(rgba.r, min(rgba.g, rgba.b))
        
        let delta = maximum - mininimum
        
        h = 0
        s = 0
        l = (maximum + mininimum) / 2
        
        if delta != 0 {
            if l < 0.5 {
                s = delta / (maximum + mininimum)
            }
            else {
                s = delta / (2 - maximum - mininimum)
            }
            
            if rgba.r == maximum {
                h = (rgba.g - rgba.b) / delta + (rgba.g < rgba.b ? 6 : 0)
            }
            else if rgba.g == maximum {
                h = (rgba.b - rgba.r) / delta + 2
            }
            else if rgba.b == maximum {
                h = (rgba.r - rgba.g) / delta + 4
            }
        }
        
        h /= 6
        a = rgba.a
    }
    
    //返回 UIColor
    func toUIColor() -> UIColor {
        let m2 = l <= 0.5 ? l * (s + 1) : (l + s) - (l * s)
        let m1 = (l * 2) - m2
        
        let r = hueToRGB(m1: m1, m2: m2, h: h + 1 / 3)
        let g = hueToRGB(m1: m1, m2: m2, h: h)
        let b = hueToRGB(m1: m1, m2: m2, h: h - 1 / 3)
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(a))
    }
    
    /// Hue to RGB helper function
    private func hueToRGB(m1: CGFloat, m2: CGFloat, h: CGFloat) -> CGFloat {
        let hue = moda(h, m: 1)
        
        if hue * 6 < 1 {
            return m1 + (m2 - m1) * hue * 6
        }
        else if hue * 2 < 1 {
            return CGFloat(m2)
        }
        else if hue * 3 < 1.9999 {
            return m1 + (m2 - m1) * (2 / 3 - hue) * 6
        }
        
        return CGFloat(m1)
    }
    
    //调整色相
    func adjustedHue(amount: CGFloat) -> HSL {
        return HSL(hue: h * 360 + amount, saturation: s, lightness: l, alpha: a)
    }
    
    //颜色变亮
    func lighter(amount: CGFloat) -> HSL {
        return HSL(hue: h * 360, saturation: s, lightness: l + amount, alpha: a)
    }
    
    //颜色变暗
    func darker(amount: CGFloat) -> HSL {
        return lighter(amount: amount * -1)
    }
    
    //调整饱和度
    func saturated(amount: CGFloat) -> HSL {
        return HSL(hue: h * 360, saturation: s + amount, lightness: l, alpha: a)
    }
    func desaturated(amount: CGFloat) -> HSL {
        return saturated(amount: amount * -1)
    }

}
extension HSL {
    /**
     Clips the values in an interval.
     
     Given an interval, values outside the interval are clipped to the interval
     edges. For example, if an interval of [0, 1] is specified, values smaller than
     0 become 0, and values larger than 1 become 1.
     
     - Parameter v: The value to clipped.
     - Parameter minimum: The minimum edge value.
     - Parameter maximum: The maximum edgevalue.
     */
    internal func clip<T: Comparable>(_ v: T, _ minimum: T, _ maximum: T) -> T {
        return max(min(v, maximum), minimum)
    }
    
    /**
     Returns the absolute value of the modulo operation.
     
     - Parameter x: The value to compute.
     - Parameter m: The modulo.
     */
    internal func moda(_ x: CGFloat, m: CGFloat) -> CGFloat {
        return (x.truncatingRemainder(dividingBy: m) + m).truncatingRemainder(dividingBy: m)
    }
}

class GMColor {
    
    // MARK: - red
    class func red50Color() -> UIColor {
        return UIColor(rgb: 0xffebee)
    }
    
    class func red100Color() -> UIColor {
        return UIColor(rgb: 0xffcdd2)
    }
    
    class func red200Color() -> UIColor {
        return UIColor(rgb: 0xef9a9a)
    }
    
    class func red300Color() -> UIColor {
        return UIColor(rgb: 0xe57373)
    }
    
    class func red400Color() -> UIColor {
        return UIColor(rgb: 0xef5350)
    }
    
    class func red500Color() -> UIColor {
        return UIColor(rgb: 0xf44336)
    }
    
    class func red600Color() -> UIColor {
        return UIColor(rgb: 0xe53935)
    }
    
    class func red700Color() -> UIColor {
        return UIColor(rgb: 0xd32f2f)
    }
    
    class func red800Color() -> UIColor {
        return UIColor(rgb: 0xc62828)
    }
    
    class func red900Color() -> UIColor {
        return UIColor(rgb: 0xb71c1c)
    }
    
    class func redA100Color() -> UIColor {
        return UIColor(rgb: 0xff8a80)
    }
    
    class func redA200Color() -> UIColor {
        return UIColor(rgb: 0xff5252)
    }
    
    class func redA400Color() -> UIColor {
        return UIColor(rgb: 0xff1744)
    }
    
    class func redA700Color() -> UIColor {
        return UIColor(rgb: 0xd50000)
    }
    
    // MARK: - pink
    class func pink50Color() -> UIColor {
        return UIColor(rgb: 0xfce4ec)
    }
    
    class func pink100Color() -> UIColor {
        return UIColor(rgb: 0xf8bbd0)
    }
    
    class func pink200Color() -> UIColor {
        return UIColor(rgb: 0xf48fb1)
    }
    
    class func pink300Color() -> UIColor {
        return UIColor(rgb: 0xf06292)
    }
    
    class func pink400Color() -> UIColor {
        return UIColor(rgb: 0xec407a)
    }
    
    class func pink500Color() -> UIColor {
        return UIColor(rgb: 0xe91e63)
    }
    
    class func pink600Color() -> UIColor {
        return UIColor(rgb: 0xd81b60)
    }
    
    class func pink700Color() -> UIColor {
        return UIColor(rgb: 0xc2185b)
    }
    
    class func pink800Color() -> UIColor {
        return UIColor(rgb: 0xad1457)
    }
    
    class func pink900Color() -> UIColor {
        return UIColor(rgb: 0x880e4f)
    }
    
    class func pinkA100Color() -> UIColor {
        return UIColor(rgb: 0xff80ab)
    }
    
    class func pinkA200Color() -> UIColor {
        return UIColor(rgb: 0xff4081)
    }
    
    class func pinkA400Color() -> UIColor {
        return UIColor(rgb: 0xf50057)
    }
    
    class func pinkA700Color() -> UIColor {
        return UIColor(rgb: 0xc51162)
    }
    
    // MARK: - purple
    class func purple50Color() -> UIColor {
        return UIColor(rgb: 0xf3e5f5)
    }
    
    class func purple100Color() -> UIColor {
        return UIColor(rgb: 0xe1bee7)
    }
    
    class func purple200Color() -> UIColor {
        return UIColor(rgb: 0xce93d8)
    }
    
    class func purple300Color() -> UIColor {
        return UIColor(rgb: 0xba68c8)
    }
    
    class func purple400Color() -> UIColor {
        return UIColor(rgb: 0xab47bc)
    }
    
    class func purple500Color() -> UIColor {
        return UIColor(rgb: 0x9c27b0)
    }
    
    class func purple600Color() -> UIColor {
        return UIColor(rgb: 0x8e24aa)
    }
    
    class func purple700Color() -> UIColor {
        return UIColor(rgb: 0x7b1fa2)
    }
    
    class func purple800Color() -> UIColor {
        return UIColor(rgb: 0x6a1b9a)
    }
    
    class func purple900Color() -> UIColor {
        return UIColor(rgb: 0x4a148c)
    }
    
    class func purpleA100Color() -> UIColor {
        return UIColor(rgb: 0xea80fc)
    }
    
    class func purpleA200Color() -> UIColor {
        return UIColor(rgb: 0xe040fb)
    }
    
    class func purpleA400Color() -> UIColor {
        return UIColor(rgb: 0xd500f9)
    }
    
    class func purpleA700Color() -> UIColor {
        return UIColor(rgb: 0xaa00ff)
    }
    
    // MARK: - deep-purple
    class func deepPurple50Color() -> UIColor {
        return UIColor(rgb: 0xede7f6)
    }
    
    class func deepPurple100Color() -> UIColor {
        return UIColor(rgb: 0xd1c4e9)
    }
    
    class func deepPurple200Color() -> UIColor {
        return UIColor(rgb: 0xb39ddb)
    }
    
    class func deepPurple300Color() -> UIColor {
        return UIColor(rgb: 0x9575cd)
    }
    
    class func deepPurple400Color() -> UIColor {
        return UIColor(rgb: 0x7e57c2)
    }
    
    class func deepPurple500Color() -> UIColor {
        return UIColor(rgb: 0x673ab7)
    }
    
    class func deepPurple600Color() -> UIColor {
        return UIColor(rgb: 0x5e35b1)
    }
    
    class func deepPurple700Color() -> UIColor {
        return UIColor(rgb: 0x512da8)
    }
    
    class func deepPurple800Color() -> UIColor {
        return UIColor(rgb: 0x4527a0)
    }
    
    class func deepPurple900Color() -> UIColor {
        return UIColor(rgb: 0x311b92)
    }
    
    class func deepPurpleA100Color() -> UIColor {
        return UIColor(rgb: 0xb388ff)
    }
    
    class func deepPurpleA200Color() -> UIColor {
        return UIColor(rgb: 0x7c4dff)
    }
    
    class func deepPurpleA400Color() -> UIColor {
        return UIColor(rgb: 0x651fff)
    }
    
    class func deepPurpleA700Color() -> UIColor {
        return UIColor(rgb: 0x6200ea)
    }
    
    // MARK: - indigo
    class func indigo50Color() -> UIColor {
        return UIColor(rgb: 0xe8eaf6)
    }
    
    class func indigo100Color() -> UIColor {
        return UIColor(rgb: 0xc5cae9)
    }
    
    class func indigo200Color() -> UIColor {
        return UIColor(rgb: 0x9fa8da)
    }
    
    class func indigo300Color() -> UIColor {
        return UIColor(rgb: 0x7986cb)
    }
    
    class func indigo400Color() -> UIColor {
        return UIColor(rgb: 0x5c6bc0)
    }
    
    class func indigo500Color() -> UIColor {
        return UIColor(rgb: 0x3f51b5)
    }
    
    class func indigo600Color() -> UIColor {
        return UIColor(rgb: 0x3949ab)
    }
    
    class func indigo700Color() -> UIColor {
        return UIColor(rgb: 0x303f9f)
    }
    
    class func indigo800Color() -> UIColor {
        return UIColor(rgb: 0x283593)
    }
    
    class func indigo900Color() -> UIColor {
        return UIColor(rgb: 0x1a237e)
    }
    
    class func indigoA100Color() -> UIColor {
        return UIColor(rgb: 0x8c9eff)
    }
    
    class func indigoA200Color() -> UIColor {
        return UIColor(rgb: 0x536dfe)
    }
    
    class func indigoA400Color() -> UIColor {
        return UIColor(rgb: 0x3d5afe)
    }
    
    class func indigoA700Color() -> UIColor {
        return UIColor(rgb: 0x304ffe)
    }
    
    // MARK: - blue
    class func blue50Color() -> UIColor {
        return UIColor(rgb: 0xe3f2fd)
    }
    
    class func blue100Color() -> UIColor {
        return UIColor(rgb: 0xbbdefb)
    }
    
    class func blue200Color() -> UIColor {
        return UIColor(rgb: 0x90caf9)
    }
    
    class func blue300Color() -> UIColor {
        return UIColor(rgb: 0x64b5f6)
    }
    
    class func blue400Color() -> UIColor {
        return UIColor(rgb: 0x42a5f5)
    }
    
    class func blue500Color() -> UIColor {
        return UIColor(rgb: 0x2196f3)
    }
    
    class func blue600Color() -> UIColor {
        return UIColor(rgb: 0x1e88e5)
    }
    
    class func blue700Color() -> UIColor {
        return UIColor(rgb: 0x1976d2)
    }
    
    class func blue800Color() -> UIColor {
        return UIColor(rgb: 0x1565c0)
    }
    
    class func blue900Color() -> UIColor {
        return UIColor(rgb: 0x0d47a1)
    }
    
    class func blueA100Color() -> UIColor {
        return UIColor(rgb: 0x82b1ff)
    }
    
    class func blueA200Color() -> UIColor {
        return UIColor(rgb: 0x448aff)
    }
    
    class func blueA400Color() -> UIColor {
        return UIColor(rgb: 0x2979ff)
    }
    
    class func blueA700Color() -> UIColor {
        return UIColor(rgb: 0x2962ff)
    }
    
    // MARK: - light-blue
    class func lightBlue50Color() -> UIColor {
        return UIColor(rgb: 0xe1f5fe)
    }
    
    class func lightBlue100Color() -> UIColor {
        return UIColor(rgb: 0xb3e5fc)
    }
    
    class func lightBlue200Color() -> UIColor {
        return UIColor(rgb: 0x81d4fa)
    }
    
    class func lightBlue300Color() -> UIColor {
        return UIColor(rgb: 0x4fc3f7)
    }
    
    class func lightBlue400Color() -> UIColor {
        return UIColor(rgb: 0x29b6f6)
    }
    
    class func lightBlue500Color() -> UIColor {
        return UIColor(rgb: 0x03a9f4)
    }
    
    class func lightBlue600Color() -> UIColor {
        return UIColor(rgb: 0x039be5)
    }
    
    class func lightBlue700Color() -> UIColor {
        return UIColor(rgb: 0x0288d1)
    }
    
    class func lightBlue800Color() -> UIColor {
        return UIColor(rgb: 0x0277bd)
    }
    
    class func lightBlue900Color() -> UIColor {
        return UIColor(rgb: 0x01579b)
    }
    
    class func lightBlueA100Color() -> UIColor {
        return UIColor(rgb: 0x80d8ff)
    }
    
    class func lightBlueA200Color() -> UIColor {
        return UIColor(rgb: 0x40c4ff)
    }
    
    class func lightBlueA400Color() -> UIColor {
        return UIColor(rgb: 0x00b0ff)
    }
    
    class func lightBlueA700Color() -> UIColor {
        return UIColor(rgb: 0x0091ea)
    }
    
    // MARK: - cyan
    class func cyan50Color() -> UIColor {
        return UIColor(rgb: 0xe0f7fa)
    }
    
    class func cyan100Color() -> UIColor {
        return UIColor(rgb: 0xb2ebf2)
    }
    
    class func cyan200Color() -> UIColor {
        return UIColor(rgb: 0x80deea)
    }
    
    class func cyan300Color() -> UIColor {
        return UIColor(rgb: 0x4dd0e1)
    }
    
    class func cyan400Color() -> UIColor {
        return UIColor(rgb: 0x26c6da)
    }
    
    class func cyan500Color() -> UIColor {
        return UIColor(rgb: 0x00bcd4)
    }
    
    class func cyan600Color() -> UIColor {
        return UIColor(rgb: 0x00acc1)
    }
    
    class func cyan700Color() -> UIColor {
        return UIColor(rgb: 0x0097a7)
    }
    
    class func cyan800Color() -> UIColor {
        return UIColor(rgb: 0x00838f)
    }
    
    class func cyan900Color() -> UIColor {
        return UIColor(rgb: 0x006064)
    }
    
    class func cyanA100Color() -> UIColor {
        return UIColor(rgb: 0x84ffff)
    }
    
    class func cyanA200Color() -> UIColor {
        return UIColor(rgb: 0x18ffff)
    }
    
    class func cyanA400Color() -> UIColor {
        return UIColor(rgb: 0x00e5ff)
    }
    
    class func cyanA700Color() -> UIColor {
        return UIColor(rgb: 0x00b8d4)
    }
    
    // MARK: - teal
    class func teal50Color() -> UIColor {
        return UIColor(rgb: 0xe0f2f1)
    }
    
    class func teal100Color() -> UIColor {
        return UIColor(rgb: 0xb2dfdb)
    }
    
    class func teal200Color() -> UIColor {
        return UIColor(rgb: 0x80cbc4)
    }
    
    class func teal300Color() -> UIColor {
        return UIColor(rgb: 0x4db6ac)
    }
    
    class func teal400Color() -> UIColor {
        return UIColor(rgb: 0x26a69a)
    }
    
    class func teal500Color() -> UIColor {
        return UIColor(rgb: 0x009688)
    }
    
    class func teal600Color() -> UIColor {
        return UIColor(rgb: 0x00897b)
    }
    
    class func teal700Color() -> UIColor {
        return UIColor(rgb: 0x00796b)
    }
    
    class func teal800Color() -> UIColor {
        return UIColor(rgb: 0x00695c)
    }
    
    class func teal900Color() -> UIColor {
        return UIColor(rgb: 0x004d40)
    }
    
    class func tealA100Color() -> UIColor {
        return UIColor(rgb: 0xa7ffeb)
    }
    
    class func tealA200Color() -> UIColor {
        return UIColor(rgb: 0x64ffda)
    }
    
    class func tealA400Color() -> UIColor {
        return UIColor(rgb: 0x1de9b6)
    }
    
    class func tealA700Color() -> UIColor {
        return UIColor(rgb: 0x00bfa5)
    }
    
    // MARK: - green
    class func green50Color() -> UIColor {
        return UIColor(rgb: 0xe8f5e9)
    }
    
    class func green100Color() -> UIColor {
        return UIColor(rgb: 0xc8e6c9)
    }
    
    class func green200Color() -> UIColor {
        return UIColor(rgb: 0xa5d6a7)
    }
    
    class func green300Color() -> UIColor {
        return UIColor(rgb: 0x81c784)
    }
    
    class func green400Color() -> UIColor {
        return UIColor(rgb: 0x66bb6a)
    }
    
    class func green500Color() -> UIColor {
        return UIColor(rgb: 0x4caf50)
    }
    
    class func green600Color() -> UIColor {
        return UIColor(rgb: 0x43a047)
    }
    
    class func green700Color() -> UIColor {
        return UIColor(rgb: 0x388e3c)
    }
    
    class func green800Color() -> UIColor {
        return UIColor(rgb: 0x2e7d32)
    }
    
    class func green900Color() -> UIColor {
        return UIColor(rgb: 0x1b5e20)
    }
    
    class func greenA100Color() -> UIColor {
        return UIColor(rgb: 0xb9f6ca)
    }
    
    class func greenA200Color() -> UIColor {
        return UIColor(rgb: 0x69f0ae)
    }
    
    class func greenA400Color() -> UIColor {
        return UIColor(rgb: 0x00e676)
    }
    
    class func greenA700Color() -> UIColor {
        return UIColor(rgb: 0x00c853)
    }
    
    // MARK: - light-green
    class func lightGreen50Color() -> UIColor {
        return UIColor(rgb: 0xf1f8e9)
    }
    
    class func lightGreen100Color() -> UIColor {
        return UIColor(rgb: 0xdcedc8)
    }
    
    class func lightGreen200Color() -> UIColor {
        return UIColor(rgb: 0xc5e1a5)
    }
    
    class func lightGreen300Color() -> UIColor {
        return UIColor(rgb: 0xaed581)
    }
    
    class func lightGreen400Color() -> UIColor {
        return UIColor(rgb: 0x9ccc65)
    }
    
    class func lightGreen500Color() -> UIColor {
        return UIColor(rgb: 0x8bc34a)
    }
    
    class func lightGreen600Color() -> UIColor {
        return UIColor(rgb: 0x7cb342)
    }
    
    class func lightGreen700Color() -> UIColor {
        return UIColor(rgb: 0x689f38)
    }
    
    class func lightGreen800Color() -> UIColor {
        return UIColor(rgb: 0x558b2f)
    }
    
    class func lightGreen900Color() -> UIColor {
        return UIColor(rgb: 0x33691e)
    }
    
    class func lightGreenA100Color() -> UIColor {
        return UIColor(rgb: 0xccff90)
    }
    
    class func lightGreenA200Color() -> UIColor {
        return UIColor(rgb: 0xb2ff59)
    }
    
    class func lightGreenA400Color() -> UIColor {
        return UIColor(rgb: 0x76ff03)
    }
    
    class func lightGreenA700Color() -> UIColor {
        return UIColor(rgb: 0x64dd17)
    }
    
    // MARK: - lime
    class func lime50Color() -> UIColor {
        return UIColor(rgb: 0xf9fbe7)
    }
    
    class func lime100Color() -> UIColor {
        return UIColor(rgb: 0xf0f4c3)
    }
    
    class func lime200Color() -> UIColor {
        return UIColor(rgb: 0xe6ee9c)
    }
    
    class func lime300Color() -> UIColor {
        return UIColor(rgb: 0xdce775)
    }
    
    class func lime400Color() -> UIColor {
        return UIColor(rgb: 0xd4e157)
    }
    
    class func lime500Color() -> UIColor {
        return UIColor(rgb: 0xcddc39)
    }
    
    class func lime600Color() -> UIColor {
        return UIColor(rgb: 0xc0ca33)
    }
    
    class func lime700Color() -> UIColor {
        return UIColor(rgb: 0xafb42b)
    }
    
    class func lime800Color() -> UIColor {
        return UIColor(rgb: 0x9e9d24)
    }
    
    class func lime900Color() -> UIColor {
        return UIColor(rgb: 0x827717)
    }
    
    class func limeA100Color() -> UIColor {
        return UIColor(rgb: 0xf4ff81)
    }
    
    class func limeA200Color() -> UIColor {
        return UIColor(rgb: 0xeeff41)
    }
    
    class func limeA400Color() -> UIColor {
        return UIColor(rgb: 0xc6ff00)
    }
    
    class func limeA700Color() -> UIColor {
        return UIColor(rgb: 0xaeea00)
    }
    
    // MARK: - yellow
    class func yellow50Color() -> UIColor {
        return UIColor(rgb: 0xfffde7)
    }
    
    class func yellow100Color() -> UIColor {
        return UIColor(rgb: 0xfff9c4)
    }
    
    class func yellow200Color() -> UIColor {
        return UIColor(rgb: 0xfff59d)
    }
    
    class func yellow300Color() -> UIColor {
        return UIColor(rgb: 0xfff176)
    }
    
    class func yellow400Color() -> UIColor {
        return UIColor(rgb: 0xffee58)
    }
    
    class func yellow500Color() -> UIColor {
        return UIColor(rgb: 0xffeb3b)
    }
    
    class func yellow600Color() -> UIColor {
        return UIColor(rgb: 0xfdd835)
    }
    
    class func yellow700Color() -> UIColor {
        return UIColor(rgb: 0xfbc02d)
    }
    
    class func yellow800Color() -> UIColor {
        return UIColor(rgb: 0xf9a825)
    }
    
    class func yellow900Color() -> UIColor {
        return UIColor(rgb: 0xf57f17)
    }
    
    class func yellowA100Color() -> UIColor {
        return UIColor(rgb: 0xffff8d)
    }
    
    class func yellowA200Color() -> UIColor {
        return UIColor(rgb: 0xffff00)
    }
    
    class func yellowA400Color() -> UIColor {
        return UIColor(rgb: 0xffea00)
    }
    
    class func yellowA700Color() -> UIColor {
        return UIColor(rgb: 0xffd600)
    }
    
    // MARK: - amber
    class func amber50Color() -> UIColor {
        return UIColor(rgb: 0xfff8e1)
    }
    
    class func amber100Color() -> UIColor {
        return UIColor(rgb: 0xffecb3)
    }
    
    class func amber200Color() -> UIColor {
        return UIColor(rgb: 0xffe082)
    }
    
    class func amber300Color() -> UIColor {
        return UIColor(rgb: 0xffd54f)
    }
    
    class func amber400Color() -> UIColor {
        return UIColor(rgb: 0xffca28)
    }
    
    class func amber500Color() -> UIColor {
        return UIColor(rgb: 0xffc107)
    }
    
    class func amber600Color() -> UIColor {
        return UIColor(rgb: 0xffb300)
    }
    
    class func amber700Color() -> UIColor {
        return UIColor(rgb: 0xffa000)
    }
    
    class func amber800Color() -> UIColor {
        return UIColor(rgb: 0xff8f00)
    }
    
    class func amber900Color() -> UIColor {
        return UIColor(rgb: 0xff6f00)
    }
    
    class func amberA100Color() -> UIColor {
        return UIColor(rgb: 0xffe57f)
    }
    
    class func amberA200Color() -> UIColor {
        return UIColor(rgb: 0xffd740)
    }
    
    class func amberA400Color() -> UIColor {
        return UIColor(rgb: 0xffc400)
    }
    
    class func amberA700Color() -> UIColor {
        return UIColor(rgb: 0xffab00)
    }
    
    // MARK: - orange
    class func orange50Color() -> UIColor {
        return UIColor(rgb: 0xfff3e0)
    }
    
    class func orange100Color() -> UIColor {
        return UIColor(rgb: 0xffe0b2)
    }
    
    class func orange200Color() -> UIColor {
        return UIColor(rgb: 0xffcc80)
    }
    
    class func orange300Color() -> UIColor {
        return UIColor(rgb: 0xffb74d)
    }
    
    class func orange400Color() -> UIColor {
        return UIColor(rgb: 0xffa726)
    }
    
    class func orange500Color() -> UIColor {
        return UIColor(rgb: 0xff9800)
    }
    
    class func orange600Color() -> UIColor {
        return UIColor(rgb: 0xfb8c00)
    }
    
    class func orange700Color() -> UIColor {
        return UIColor(rgb: 0xf57c00)
    }
    
    class func orange800Color() -> UIColor {
        return UIColor(rgb: 0xef6c00)
    }
    
    class func orange900Color() -> UIColor {
        return UIColor(rgb: 0xe65100)
    }
    
    class func orangeA100Color() -> UIColor {
        return UIColor(rgb: 0xffd180)
    }
    
    class func orangeA200Color() -> UIColor {
        return UIColor(rgb: 0xffab40)
    }
    
    class func orangeA400Color() -> UIColor {
        return UIColor(rgb: 0xff9100)
    }
    
    class func orangeA700Color() -> UIColor {
        return UIColor(rgb: 0xff6d00)
    }
    
    // MARK: - deep-orange
    class func deepOrange50Color() -> UIColor {
        return UIColor(rgb: 0xfbe9e7)
    }
    
    class func deepOrange100Color() -> UIColor {
        return UIColor(rgb: 0xffccbc)
    }
    
    class func deepOrange200Color() -> UIColor {
        return UIColor(rgb: 0xffab91)
    }
    
    class func deepOrange300Color() -> UIColor {
        return UIColor(rgb: 0xff8a65)
    }
    
    class func deepOrange400Color() -> UIColor {
        return UIColor(rgb: 0xff7043)
    }
    
    class func deepOrange500Color() -> UIColor {
        return UIColor(rgb: 0xff5722)
    }
    
    class func deepOrange600Color() -> UIColor {
        return UIColor(rgb: 0xf4511e)
    }
    
    class func deepOrange700Color() -> UIColor {
        return UIColor(rgb: 0xe64a19)
    }
    
    class func deepOrange800Color() -> UIColor {
        return UIColor(rgb: 0xd84315)
    }
    
    class func deepOrange900Color() -> UIColor {
        return UIColor(rgb: 0xbf360c)
    }
    
    class func deepOrangeA100Color() -> UIColor {
        return UIColor(rgb: 0xff9e80)
    }
    
    class func deepOrangeA200Color() -> UIColor {
        return UIColor(rgb: 0xff6e40)
    }
    
    class func deepOrangeA400Color() -> UIColor {
        return UIColor(rgb: 0xff3d00)
    }
    
    class func deepOrangeA700Color() -> UIColor {
        return UIColor(rgb: 0xdd2c00)
    }
    
    // MARK: - brown
    class func brown50Color() -> UIColor {
        return UIColor(rgb: 0xefebe9)
    }
    
    class func brown100Color() -> UIColor {
        return UIColor(rgb: 0xd7ccc8)
    }
    
    class func brown200Color() -> UIColor {
        return UIColor(rgb: 0xbcaaa4)
    }
    
    class func brown300Color() -> UIColor {
        return UIColor(rgb: 0xa1887f)
    }
    
    class func brown400Color() -> UIColor {
        return UIColor(rgb: 0x8d6e63)
    }
    
    class func brown500Color() -> UIColor {
        return UIColor(rgb: 0x795548)
    }
    
    class func brown600Color() -> UIColor {
        return UIColor(rgb: 0x6d4c41)
    }
    
    class func brown700Color() -> UIColor {
        return UIColor(rgb: 0x5d4037)
    }
    
    class func brown800Color() -> UIColor {
        return UIColor(rgb: 0x4e342e)
    }
    
    class func brown900Color() -> UIColor {
        return UIColor(rgb: 0x3e2723)
    }
    
    // MARK: - grey
    class func grey50Color() -> UIColor {
        return UIColor(rgb: 0xfafafa)
    }
    
    class func grey100Color() -> UIColor {
        return UIColor(rgb: 0xf5f5f5)
    }
    
    class func grey200Color() -> UIColor {
        return UIColor(rgb: 0xeeeeee)
    }
    
    class func grey300Color() -> UIColor {
        return UIColor(rgb: 0xe0e0e0)
    }
    
    class func grey400Color() -> UIColor {
        return UIColor(rgb: 0xbdbdbd)
    }
    
    class func grey500Color() -> UIColor {
        return UIColor(rgb: 0x9e9e9e)
    }
    
    class func grey600Color() -> UIColor {
        return UIColor(rgb: 0x757575)
    }
    
    class func grey700Color() -> UIColor {
        return UIColor(rgb: 0x616161)
    }
    
    class func grey800Color() -> UIColor {
        return UIColor(rgb: 0x424242)
    }
    
    class func grey900Color() -> UIColor {
        return UIColor(rgb: 0x212121)
    }
    
    // MARK: - blue-grey
    class func blueGrey50Color() -> UIColor {
        return UIColor(rgb: 0xeceff1)
    }
    
    class func blueGrey100Color() -> UIColor {
        return UIColor(rgb: 0xcfd8dc)
    }
    
    class func blueGrey200Color() -> UIColor {
        return UIColor(rgb: 0xb0bec5)
    }
    
    class func blueGrey300Color() -> UIColor {
        return UIColor(rgb: 0x90a4ae)
    }
    
    class func blueGrey400Color() -> UIColor {
        return UIColor(rgb: 0x78909c)
    }
    
    class func blueGrey500Color() -> UIColor {
        return UIColor(rgb: 0x607d8b)
    }
    
    class func blueGrey600Color() -> UIColor {
        return UIColor(rgb: 0x546e7a)
    }
    
    class func blueGrey700Color() -> UIColor {
        return UIColor(rgb: 0x455a64)
    }
    
    class func blueGrey800Color() -> UIColor {
        return UIColor(rgb: 0x37474f)
    }
    
    class func blueGrey900Color() -> UIColor {
        return UIColor(rgb: 0x263238)
    }
    
    // MARK: - black
    class func blackColor() -> UIColor {
        return UIColor(rgb: 0x000000)
    }
    
    // MARK: - white
    class func whiteColor() -> UIColor {
        return UIColor(rgb: 0xffffff)
    }
}
