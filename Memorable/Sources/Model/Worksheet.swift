//
//  Worksheet.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/3/24.
//

import Foundation

struct Worksheet: Document {
    let id: Int
    let name: String
    let category: String
    var isBookmarked: Bool
    let createdDate: Date
    var fileType: String = "빈칸학습지"
    
    init(worksheetId: Int, name: String, category: String, worksheetBookmark: Bool, worksheetCreate_date: Date) {
        self.id = worksheetId
        self.name = name
        self.category = category
        self.isBookmarked = worksheetBookmark
        self.createdDate = worksheetCreate_date
    }
}

struct WorksheetDetail: Codable {
    let worksheetId: Int
    let name: String
    let category: String
    let isCompleteAllBlanks: Bool
    let isReExtracted: Bool
    let answer1: [String]
    let answer2: [String]
}
