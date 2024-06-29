//
//  QuestionManager.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/28/24.
//

import Foundation

class QuestionManager {
    var questions: [Question] = []
    
    func parseQuestions(from json: [Int: [String: String]]) {
        questions = json.compactMap { (key, value) in
            guard let question = value["question"],
                  let answer = value["answer"] else { return nil }
            return Question(id: key, question: question, answer: answer, userAnswer: "") // Initialize userAnswer with a default value
        }.sorted { $0.id < $1.id }
    }
}
