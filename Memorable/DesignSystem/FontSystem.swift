//
//  FontSystem.swift
//  Memorable
//
//  Created by 김현기 on 6/30/24.
//

import UIKit

extension UIFont {
    static func header0(size fontSize: CGFloat = 40.0) -> UIFont {
        let familyName = "Pretendard"
        let weightString = "SemiBold"
        return UIFont(name: "\(familyName)-\(weightString)", size: fontSize) ?? .systemFont(ofSize: fontSize)
    }

    static func header1(size fontSize: CGFloat = 26.0) -> UIFont {
        let familyName = "Pretendard"
        let weightString = "Regular"
        return UIFont(name: "\(familyName)-\(weightString)", size: fontSize) ?? .systemFont(ofSize: fontSize)
    }

    static func header2R(size fontSize: CGFloat = 25.0) -> UIFont {
        let familyName = "Pretendard"
        let weightString = "Regular"
        return UIFont(name: "\(familyName)-\(weightString)", size: fontSize) ?? .systemFont(ofSize: fontSize)
    }

    static func header2B(size fontSize: CGFloat = 25.0) -> UIFont {
        let familyName = "Pretendard"
        let weightString = "Bold"
        return UIFont(name: "\(familyName)-\(weightString)", size: fontSize) ?? .systemFont(ofSize: fontSize)
    }
}
