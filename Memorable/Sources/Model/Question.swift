//
//  TestQuestion.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/28/24.
//
import Foundation

struct Question: Codable {
    let questionId: Int
    let question: String
    let answer: String
    var userAnswer: String?
}
