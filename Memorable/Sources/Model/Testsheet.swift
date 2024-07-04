//
//  Testsheet.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/3/24.
//

import Foundation

struct Testsheet: Document {
    let id: Int
    let name: String
    let category: String
    var isBookmarked: Bool
    let createdDate: Date
    var fileType: String = "나만의 시험지"
    
    init(testsheetId: Int, name: String, category: String, testsheetBookmark: Bool, testsheetCreateDate: Date) {
        self.id = testsheetId
        self.name = name
        self.category = category
        self.isBookmarked = testsheetBookmark
        self.createdDate = testsheetCreateDate
    }
}

struct TestsheetDetail: Codable {
    let testsheetId: Int
    let name: String
    let category: String
    var isReExtracted: Bool
    let questions1: [Question]
    let questions2: [Question]
}
