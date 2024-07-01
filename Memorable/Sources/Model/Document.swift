//
//  Document.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/27/24.
//

import Foundation

struct Document {
    let fileName: String
    let fileType: String
    let category: String
    var bookmark: Bool
    let date: Date
}

func makeDate(year: Int, month: Int, day: Int) -> Date {
    let calendar = Calendar.current
    let components = DateComponents(year: year, month: month, day: day)
    return calendar.date(from: components) ?? Date()
}
