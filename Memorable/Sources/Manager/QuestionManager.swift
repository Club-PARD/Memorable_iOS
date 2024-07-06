//
//  QuestionManager.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/28/24.
//

import Foundation

class QuestionManager {
    var questions: [Question] = []

    func parseQuestions(from data: [Int: [String: String]]) {
        questions = data.map { (id, dict) in
            Question(questionId: id, question: dict["question"] ?? "", answer: dict["answer"] ?? "", userAnswer: dict["userAnswer"] ?? "")
        }.sorted { $0.questionId < $1.questionId }
    }
}
