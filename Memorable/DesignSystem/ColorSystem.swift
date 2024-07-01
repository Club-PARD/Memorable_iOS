//
//  ColorSystem.swift
//  Memorable
//
//  Created by 김현기 on 6/30/24.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        assert(red >= 0 && red <= 255, "invalid red component")
        assert(green >= 0 && green <= 255, "invalid red component")
        assert(blue >= 0 && blue <= 255, "invalid red component")
        assert(alpha >= 0 && alpha <= 255, "invalid red component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

    convenience init(rgb: Int, alpha: CGFloat) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }

    static var background: UIColor {
        return UIColor(rgb: 0xFFF4F1EF, alpha: 1.0)
    }

    static var primary: UIColor {
        return UIColor(rgb: 0xFFF35E3E, alpha: 1.0)
    }

    static var secondary: UIColor {
        return UIColor(rgb: 0xFF239F95, alpha: 1.0)
    }

    static var textBlack: UIColor {
        return UIColor(rgb: 0xFF2B2B2B, alpha: 1.0)
    }
}
