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
}
