//
//  File.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/3/24.
//

import Foundation

struct Wrongsheet: Document {
    let id: Int
    let name: String
    let category: String
    var isBookmarked: Bool
    let createdDate: Date
    var fileType: String = "오답노트"
    
    init(wrongsheetId: Int, name: String, category: String, wrongsheetBookmark: Bool, wrongsheetCreate_date: Date) {
        self.id = wrongsheetId
        self.name = name
        self.category = category
        self.isBookmarked = wrongsheetBookmark
        self.createdDate = wrongsheetCreate_date
    }
}

struct WrongsheetDetail: Codable {
    let wrongsheetId: Int
    let name: String
    let category: String
    let questions: [Question]
}
