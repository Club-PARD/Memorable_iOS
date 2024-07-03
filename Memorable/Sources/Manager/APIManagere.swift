//
//  APIManagere.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/3/24.
//

//import Foundation

//class APIManagere {
//    static let shared = APIManagere()
//    private let baseURL = "http://172.30.1.11:8080"
//    
//    struct EmptyResponse: Codable {}
//    
//    private init() {}
//    
//    // MARK: - Worksheet
//    
//    func getWorksheets(userId: String, completion: @escaping (Result<[Worksheet], Error>) -> Void) {
//        let urlString = "\(baseURL)/api/worksheet/\(userId)"
//        performRequest(urlString: urlString, completion: completion)
//    }
//    
//    func getWorksheet(worksheetId: Int, completion: @escaping (Result<WorksheetDetail, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/worksheet/\(worksheetId)"
//        performRequest(urlString: urlString, completion: completion)
//    }
//    
//    func getRecentWorksheet(userId: String, completion: @escaping (Result<WorksheetDetail, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/worksheet/recentDate/\(userId)"
//        performRequest(urlString: urlString, completion: completion)
//    }
//    
//    func createWorksheet(userId: String, name: String, category: String, content: String, completion: @escaping (Result<WorksheetDetail, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/worksheet"
//        let body = ["userId": userId, "name": name, "category": category, "content": content]
//        performRequest(urlString: urlString, method: "POST", body: body, completion: completion)
//    }
//    
//    func toggleWorksheetBookmark(worksheetId: Int, completion: @escaping (Result<Worksheet, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/worksheet/\(worksheetId)"
//        performRequest(urlString: urlString, method: "PATCH", completion: completion)
//    }
//    
//    func deleteWorksheet(worksheetId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/worksheet/\(worksheetId)"
//        performRequest(urlString: urlString, method: "DELETE", completion: completion)
//    }
//    
//    // MARK: - Testsheet
//    
//    func getTestsheets(userId: String, completion: @escaping (Result<[Testsheet], Error>) -> Void) {
//        let urlString = "\(baseURL)/api/testsheet/\(userId)"
//        performRequest(urlString: urlString, completion: completion)
//    }
//    
//    func getTestsheet(testsheetId: Int, completion: @escaping (Result<TestsheetDetail, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/testsheet/\(testsheetId)"
//        performRequest(urlString: urlString, completion: completion)
//    }
//    
//    func createTestsheet(worksheetId: Int, completion: @escaping (Result<TestsheetDetail, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/testsheet/\(worksheetId)"
//        performRequest(urlString: urlString, method: "POST", completion: completion)
//    }
//    
//    func updateTestsheet(testsheetId: Int, userAnswers1: [String], userAnswers2: [String], completion: @escaping (Result<TestsheetDetail, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/testsheet/\(testsheetId)"
//        let body = ["userAnswers1": userAnswers1, "userAnswers2": userAnswers2]
//        performRequest(urlString: urlString, method: "PATCH", body: body, completion: completion)
//    }
//    
//    func toggleTestsheetBookmark(testsheetId: Int, completion: @escaping (Result<Testsheet, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/testsheet/\(testsheetId)"
//        performRequest(urlString: urlString, method: "PATCH", completion: completion)
//    }
//    
//    func deleteTestsheet(testsheetId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/testsheet/\(testsheetId)"
//        performRequest(urlString: urlString, method: "DELETE", completion: completion)
//    }
//    
//    // MARK: - Wrongsheet
//    
//    func getWrongsheets(userId: String, completion: @escaping (Result<[Wrongsheet], Error>) -> Void) {
//        let urlString = "\(baseURL)/api/wrongsheet/\(userId)"
//        performRequest(urlString: urlString, completion: completion)
//    }
//    
//    func getWrongsheet(wrongsheetId: Int, completion: @escaping (Result<WrongsheetDetail, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/wrongsheet/\(wrongsheetId)"
//        performRequest(urlString: urlString, completion: completion)
//    }
//    
//    func createWrongsheet(questions: [[String: Any]], completion: @escaping (Result<WrongsheetDetail, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/wrongsheet"
//        let body = ["questions": questions]
//        performRequest(urlString: urlString, method: "POST", body: body, completion: completion)
//    }
//    
//    func toggleWrongsheetBookmark(wrongsheetId: Int, completion: @escaping (Result<Wrongsheet, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/wrongsheet/\(wrongsheetId)"
//        performRequest(urlString: urlString, method: "PATCH", completion: completion)
//    }
//    
//    func deleteWrongsheet(wrongsheetId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
//        let urlString = "\(baseURL)/api/wrongsheet/\(wrongsheetId)"
//        performRequest(urlString: urlString, method: "DELETE", completion: completion)
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func performRequest<T: Codable>(urlString: String, method: String = "GET", body: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
//        guard let url = URL(string: urlString) else {
//            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        
//        if let body = body {
//            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        }
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let data = data else {
//                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
//                return
//            }
//            
//            do {
//                let decodedData = try JSONDecoder().decode(T.self, from: data)
//                completion(.success(decodedData))
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume()
//    }
//    
//    private func performRequestWithoutResponse(urlString: String, method: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        guard let url = URL(string: urlString) else {
//            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = method
//        
//        URLSession.shared.dataTask(with: request) { _, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
//                completion(.success(()))
//            } else {
//                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
//            }
//        }.resume()
//    }
//    
//    func getDocuments(userId: String, completion: @escaping (Result<[Document], Error>) -> Void) {
//        let group = DispatchGroup()
//        var documents: [Document] = []
//        var error: Error?
//        
//        group.enter()
//        getWorksheets(userId: userId) { result in
//            switch result {
//            case .success(let worksheets):
//                documents.append(contentsOf: worksheets)
//            case .failure(let err):
//                error = err
//            }
//            group.leave()
//        }
//        
//        group.enter()
//        getTestsheets(userId: userId) { result in
//            switch result {
//            case .success(let testsheets):
//                documents.append(contentsOf: testsheets)
//            case .failure(let err):
//                error = err
//            }
//            group.leave()
//        }
//        
//        group.enter()
//        getWrongsheets(userId: userId) { result in
//            switch result {
//            case .success(let wrongsheets):
//                documents.append(contentsOf: wrongsheets)
//            case .failure(let err):
//                error = err
//            }
//            group.leave()
//        }
//        
//        group.notify(queue: .main) {
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(documents))
//            }
//        }
//    }
//    
//    // MARK: - Mock Data
//    
//    func getMockWorksheets() -> [Worksheet] {
//        return [
//            Worksheet(worksheetId: 1, name: "Worksheet 1", category: "Math", worksheetBookmark: true, worksheetCreate_date: Date()),
//            Worksheet(worksheetId: 2, name: "Worksheet 2", category: "Science", worksheetBookmark: false, worksheetCreate_date: Date()),
//            Worksheet(worksheetId: 3, name: "Worksheet 3", category: "History", worksheetBookmark: true, worksheetCreate_date: Date())
//        ]
//    }
//    
//    func getMockWorksheetDetail() -> WorksheetDetail {
//        return WorksheetDetail(worksheetId: 1, name: "Worksheet 1", category: "Math", isCompleteAllBlanks: false, isReExtracted: false, answer1: ["Answer 1", "Answer 2"], answer2: ["Answer 3", "Answer 4"])
//    }
//    
//    func getMockTestsheets() -> [Testsheet] {
//        return [
//            Testsheet(testsheetId: 1, name: "Testsheet 1", category: "Math", testsheetBookmark: true, testsheetCreateDate: Date()),
//            Testsheet(testsheetId: 2, name: "Testsheet 2", category: "Science", testsheetBookmark: false, testsheetCreateDate: Date()),
//            Testsheet(testsheetId: 3, name: "Testsheet 3", category: "History", testsheetBookmark: true, testsheetCreateDate: Date())
//        ]
//    }
//    
//    func getMockTestsheetDetail() -> TestsheetDetail {
//        return TestsheetDetail(testsheetId: 1, name: "Testsheet 1", category: "Math", isReExtracted: false, questions1: [
//            Question(questionId: 1, question: "Question 1", answer: "Answer 1", userAnswer: nil),
//            Question(questionId: 2, question: "Question 2", answer: "Answer 2", userAnswer: nil)
//        ], questions2: [
//            Question(questionId: 3, question: "Question 3", answer: "Answer 3", userAnswer: nil),
//            Question(questionId: 4, question: "Question 4", answer: "Answer 4", userAnswer: nil)
//        ])
//    }
//    
//    func getMockWrongsheets() -> [Wrongsheet] {
//        return [
//            Wrongsheet(wrongsheetId: 1, name: "Wrongsheet 1", category: "Math", wrongsheetBookmark: true, wrongsheetCreate_date: Date()),
//            Wrongsheet(wrongsheetId: 2, name: "Wrongsheet 2", category: "Science", wrongsheetBookmark: false, wrongsheetCreate_date: Date()),
//            Wrongsheet(wrongsheetId: 3, name: "Wrongsheet 3", category: "History", wrongsheetBookmark: true, wrongsheetCreate_date: Date())
//        ]
//    }
//    
//    func getMockWrongsheetDetail() -> WrongsheetDetail {
//        return WrongsheetDetail(wrongsheetId: 1, name: "Wrongsheet 1", category: "Math", questions: [
//            Question(questionId: 1, question: "Question 1", answer: "Answer 1", userAnswer: "Wrong Answer 1"),
//            Question(questionId: 2, question: "Question 2", answer: "Answer 2", userAnswer: "Wrong Answer 2")
//        ])
//    }
//}

import Foundation

class APIManagere {
    static let shared = APIManagere()
    private let baseURL = "http://172.30.1.11:8080"
    
    struct EmptyResponse: Codable {}
    
    private init() {}
    
    // MARK: - Worksheet
    
    func getWorksheets(userId: String, completion: @escaping (Result<[Worksheet], Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockWorksheets()))
    }
    
    func getWorksheet(worksheetId: Int, completion: @escaping (Result<WorksheetDetail, Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockWorksheetDetail()))
    }
    
    func getRecentWorksheet(userId: String, completion: @escaping (Result<WorksheetDetail, Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockWorksheetDetail()))
    }
    
    func createWorksheet(userId: String, name: String, category: String, content: String, completion: @escaping (Result<WorksheetDetail, Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockWorksheetDetail()))
    }
    
    func toggleWorksheetBookmark(worksheetId: Int, completion: @escaping (Result<Worksheet, Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockWorksheets().first!))
    }
    
    func deleteWorksheet(worksheetId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        // Mock data 사용
        completion(.success(EmptyResponse()))
    }
    
    // MARK: - Testsheet
    
    func getTestsheets(userId: String, completion: @escaping (Result<[Testsheet], Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockTestsheets()))
    }
    
    func getTestsheet(testsheetId: Int, completion: @escaping (Result<TestsheetDetail, Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockTestsheetDetail()))
    }
    
    func createTestsheet(worksheetId: Int, completion: @escaping (Result<TestsheetDetail, Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockTestsheetDetail()))
    }
    
    func updateTestsheet(testsheetId: Int, userAnswers1: [String], userAnswers2: [String], completion: @escaping (Result<TestsheetDetail, Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockTestsheetDetail()))
    }
    
    func toggleTestsheetBookmark(testsheetId: Int, completion: @escaping (Result<Testsheet, Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockTestsheets().first!))
    }
    
    func deleteTestsheet(testsheetId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        // Mock data 사용
        completion(.success(EmptyResponse()))
    }
    
    // MARK: - Wrongsheet
    
    func getWrongsheets(userId: String, completion: @escaping (Result<[Wrongsheet], Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockWrongsheets()))
    }
    
    func getWrongsheet(wrongsheetId: Int, completion: @escaping (Result<WrongsheetDetail, Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockWrongsheetDetail()))
    }
    
    func createWrongsheet(questions: [[String: Any]], completion: @escaping (Result<WrongsheetDetail, Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockWrongsheetDetail()))
    }
    
    func toggleWrongsheetBookmark(wrongsheetId: Int, completion: @escaping (Result<Wrongsheet, Error>) -> Void) {
        // Mock data 사용
        completion(.success(getMockWrongsheets().first!))
    }
    
    func deleteWrongsheet(wrongsheetId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        // Mock data 사용
        completion(.success(EmptyResponse()))
    }
    
    // MARK: - Helper Methods
    
    private func performRequest<T: Codable>(urlString: String, method: String = "GET", body: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        // 이 메서드는 mock 데이터를 사용하는 시점에서 필요 없습니다.
    }
    
    private func performRequestWithoutResponse(urlString: String, method: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // 이 메서드는 mock 데이터를 사용하는 시점에서 필요 없습니다.
    }
    
    func getDocuments(userId: String, completion: @escaping (Result<[Document], Error>) -> Void) {
        let group = DispatchGroup()
        var documents: [Document] = []
        var error: Error?
        
        group.enter()
        getWorksheets(userId: userId) { result in
            switch result {
            case .success(let worksheets):
                documents.append(contentsOf: worksheets)
            case .failure(let err):
                error = err
            }
            group.leave()
        }
        
        group.enter()
        getTestsheets(userId: userId) { result in
            switch result {
            case .success(let testsheets):
                documents.append(contentsOf: testsheets)
            case .failure(let err):
                error = err
            }
            group.leave()
        }
        
        group.enter()
        getWrongsheets(userId: userId) { result in
            switch result {
            case .success(let wrongsheets):
                documents.append(contentsOf: wrongsheets)
            case .failure(let err):
                error = err
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(documents))
            }
        }
    }
    
    // MARK: - Mock Data
    
    func getMockWorksheets() -> [Worksheet] {
        return [
            Worksheet(worksheetId: 1, name: "Worksheet 1", category: "Math", worksheetBookmark: true, worksheetCreate_date: Date()),
            Worksheet(worksheetId: 2, name: "Worksheet 2", category: "Science", worksheetBookmark: false, worksheetCreate_date: Date()),
            Worksheet(worksheetId: 3, name: "Worksheet 3", category: "History", worksheetBookmark: true, worksheetCreate_date: Date())
        ]
    }
    
    func getMockWorksheetDetail() -> WorksheetDetail {
        return WorksheetDetail(worksheetId: 1, name: "Worksheet 1", category: "Math", isCompleteAllBlanks: false, isReExtracted: false, answer1: ["Answer 1", "Answer 2"], answer2: ["Answer 3", "Answer 4"])
    }
    
    func getMockTestsheets() -> [Testsheet] {
        return [
            Testsheet(testsheetId: 1, name: "Testsheet 1", category: "Math", testsheetBookmark: true, testsheetCreateDate: Date()),
            Testsheet(testsheetId: 2, name: "Testsheet 2", category: "Science", testsheetBookmark: false, testsheetCreateDate: Date()),
            Testsheet(testsheetId: 3, name: "Testsheet 3", category: "History", testsheetBookmark: true, testsheetCreateDate: Date())
        ]
    }
    
    func getMockTestsheetDetail() -> TestsheetDetail {
        return TestsheetDetail(testsheetId: 1, name: "Testsheet 1", category: "Math", isReExtracted: false, questions1: [
            Question(questionId: 1, question: "Question 1", answer: "Answer 1", userAnswer: nil),
            Question(questionId: 2, question: "Question 2", answer: "Answer 2", userAnswer: nil)
        ], questions2: [
            Question(questionId: 3, question: "Question 3", answer: "Answer 3", userAnswer: nil),
            Question(questionId: 4, question: "Question 4", answer: "Answer 4", userAnswer: nil)
        ])
    }
    
    func getMockWrongsheets() -> [Wrongsheet] {
        return [
            Wrongsheet(wrongsheetId: 1, name: "Wrongsheet 1", category: "Math", wrongsheetBookmark: true, wrongsheetCreate_date: Date()),
            Wrongsheet(wrongsheetId: 2, name: "Wrongsheet 2", category: "Science", wrongsheetBookmark: false, wrongsheetCreate_date: Date()),
            Wrongsheet(wrongsheetId: 3, name: "Wrongsheet 3", category: "History", wrongsheetBookmark: true, wrongsheetCreate_date: Date())
        ]
    }
    
    func getMockWrongsheetDetail() -> WrongsheetDetail {
        return WrongsheetDetail(wrongsheetId: 1, name: "Wrongsheet 1", category: "Math", questions: [
            Question(questionId: 1, question: "Question 1", answer: "Answer 1", userAnswer: nil),
            Question(questionId: 2, question: "Question 2", answer: "Answer 2", userAnswer: nil)
        ])
    }
}
