//
//  User.swift
//  Memorable
//
//  Created by 김현기 on 6/26/24.
//

import Foundation

struct User: Codable {
    var identifier: String
    var givenName: String
    var familyName: String
    var email: String

    // JSON 문자열로 변환하는 메서드
    func toJSON() -> String? {
        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error encoding user to JSON: \(error)")
            return nil
        }
    }
}
