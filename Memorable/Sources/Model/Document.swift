//
//  Document.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/27/24.
//

import Foundation

protocol Document: Codable {
    var id: Int { get }
    var name: String { get }
    var category: String { get }
    var isBookmarked: Bool { get set }
    var createdDate: Date { get }
    var fileType: String { get }
}
