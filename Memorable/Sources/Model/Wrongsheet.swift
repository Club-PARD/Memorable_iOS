//
//  File.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/3/24.
//

import Foundation

struct Wrongsheet: Document, Codable {
    let id: Int
    let name: String
    let category: String
    var isBookmarked: Bool
    let createdDate: Date
    var fileType: String = "오답노트"
    
    enum CodingKeys: String, CodingKey {
        case id = "wrongsheetId"
        case name
        case category
        case isBookmarked = "wrongsheetBookmark"
        case createdDate = "wrongsheetCreateDate"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        isBookmarked = try container.decode(Bool.self, forKey: .isBookmarked)
        
        let dateString = try container.decode(String.self, forKey: .createdDate)
        
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
        
        // If all formatters fail, try ISO8601DateFormatter
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso8601Formatter.date(from: dateString) {
            createdDate = date
            return
        }
        
        // If all parsing attempts fail, throw an error
        throw DecodingError.dataCorruptedError(forKey: .createdDate, in: container, debugDescription: "Date string does not match any known format: \(dateString)")
    }
}

struct WrongsheetDetail: Codable {
    let wrongsheetId: Int
    let name: String
    let category: String
    let questions: [Question]
}
