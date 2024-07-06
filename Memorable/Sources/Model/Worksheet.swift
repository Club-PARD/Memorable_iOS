//
//  Worksheet.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/3/24.
//

import Foundation

struct Worksheet: Document, Codable {
    let id: Int
    let name: String
    let category: String
    var isBookmarked: Bool
    let createdDate: Date
    var fileType: String = "빈칸학습지"
    
    enum CodingKeys: String, CodingKey {
        case id = "worksheetId"
        case name
        case category
        case isBookmarked = "worksheetBookmark"
        case createdDate = "worksheetCreate_date"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "빈칸 학습지"
        category = try container.decode(String.self, forKey: .category)
        isBookmarked = try container.decode(Bool.self, forKey: .isBookmarked)
        
        let dateString = try container.decode(String.self, forKey: .createdDate)
        
        // DateFormatter를 사용한 파싱 시도
        let dateFormatters: [DateFormatter] = [
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                return formatter
            }(),
            {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                return formatter
            }()
        ]
        
        for formatter in dateFormatters {
            if let date = formatter.date(from: dateString) {
                createdDate = date
                return
            }
        }
        
        // ISO8601DateFormatter를 사용한 파싱 시도
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso8601Formatter.date(from: dateString) {
            createdDate = date
            return
        }
        
        // 모든 형식이 실패하면 오류를 던집니다.
        throw DecodingError.dataCorruptedError(forKey: .createdDate, in: container, debugDescription: "Date string does not match any known format: \(dateString)")
    }
}

struct WorksheetDetail: Codable {
    var worksheetId: Int
    var name: String
    var category: String
    var isCompleteAllBlanks: Bool
    var isAddWorksheet: Bool
    var isMakeTestSheet: Bool
    var answer1: [String]
    var answer2: [String]
    var content: String
}
