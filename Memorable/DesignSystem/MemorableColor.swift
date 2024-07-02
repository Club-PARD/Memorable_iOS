//
//  MemorableColor.swift
//  Memorable
//
//  Created by 김현기 on 7/2/24.
//

import UIKit

public struct MemorableColor {
    private init() {}
    
    private static func color(named: String) -> UIColor? {
        return UIColor(named: named)
    }
    
    // System Color
    public static let Red = color(named: "Red")
    public static let Orange = color(named: "Orange")
    public static let Yellow = color(named: "Yellow")
    public static let Green = color(named: "Green")
    public static let Blue = color(named: "Blue")
    
    // Brand Color
    public static let Blue1 = color(named: "Blue1")
    public static let Blue2 = color(named: "Blue2")
    public static let Blue3 = color(named: "Blue3")
    public static let Yellow1 = color(named: "Yellow1")
    public static let Yellow2 = color(named: "Yellow2")
    public static let Yellow3 = color(named: "Yellow3")
    
    // Gray Scale
    public static let Black = color(named: "Black")
    public static let Gray1 = color(named: "Gray1")
    public static let Gray2 = color(named: "Gray2")
    public static let Gray3 = color(named: "Gray3")
    public static let Gray4 = color(named: "Gray4")
    public static let Gray5 = color(named: "Gray5")
    public static let White = color(named: "White")
}
