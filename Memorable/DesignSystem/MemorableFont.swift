//
//  MemorableFont.swift
//  Memorable
//
//  Created by 김현기 on 7/2/24.
//

import UIKit

public struct MemorableFont {
    private init() {}

    private static func font(name: String, size: CGFloat) -> UIFont {
        UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
    }

    public static func LargeTitle(size fontSize: CGFloat = 34.0) -> UIFont {
        font(name: "Pretendard-Bold", size: fontSize)
    }

    public static func Title(size fontSize: CGFloat = 24.0) -> UIFont {
        font(name: "Pretendard-SemiBold", size: fontSize)
    }

    public static func Body1(size fontSize: CGFloat = 17.0) -> UIFont {
        font(name: "Pretendard-Medium", size: fontSize)
    }

    public static func Body2(size fontSize: CGFloat = 14.0) -> UIFont {
        font(name: "Pretendard-Medium", size: fontSize)
    }

    public static func BodyCaption(size fontSize: CGFloat = 14.0) -> UIFont {
        font(name: "Pretendard-Regular", size: fontSize)
    }

    public static func Button(size fontSize: CGFloat = 20.0) -> UIFont {
        font(name: "Pretendard-SemiBold", size: fontSize)
    }
}
