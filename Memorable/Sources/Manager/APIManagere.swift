//
//  APIManagere.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/3/24.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case encodingError(Error)
    case networkError(Error)
    case serverError(statusCode: Int, message: String)
    case noData
    case decodingError(Error)
}

class APIManagere {
    static let shared = APIManagere()
    private let baseURL = "https://memorable-study.site"
    
    struct EmptyResponse: Codable {}
    
    private init() {}
    
    // MARK: - Worksheet
    
    // 1-1. 빈칸 학습지 간략 정보 불러오기
    func getWorksheets(userId: String, completion: @escaping (Result<[Worksheet], Error>) -> Void) {
        let urlString = "\(baseURL)/api/worksheet/user/\(userId)"
        print("Requesting worksheets from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(APIError.networkError(error)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                // Check for non-200 status codes
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Server error with status code: \(httpResponse.statusCode)")
                    completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode, message: "Server error")))
                    return
                }
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(APIError.serverError(statusCode: 0, message: "No data received")))
                return
            }
            
            print("Received data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
            
            do {
                let worksheets = try JSONDecoder().decode([Worksheet].self, from: data)
                print("Successfully decoded \(worksheets.count) worksheets")
                completion(.success(worksheets))
            } catch {
                print("Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key)' not found: \(context.debugDescription)")
                    case .valueNotFound(let value, let context):
                        print("Value '\(value)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type '\(type)' mismatch: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }
    
    // 1-2. 빈칸 학습지 텍스트, 정답 불러오기
    func getWorksheet(worksheetId: Int, completion: @escaping (Result<WorksheetDetail, Error>) -> Void) {
        let urlString = "\(baseURL)/api/worksheet/ws/\(worksheetId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let worksheetDetail = try decoder.decode(WorksheetDetail.self, from: data)
                
                completion(.success(worksheetDetail))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // 3. 가장 최근에 이용한 빈칸학습지 불러오기
    func getMostRecentWorksheet(userId: String, completion: @escaping (Result<WorksheetDetail, Error>) -> Void) {
        let urlString = "\(baseURL)/api/worksheet/recentDate/\(userId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let worksheetDetail = try decoder.decode(WorksheetDetail.self, from: data)
                completion(.success(worksheetDetail))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // 1-4. 학습지 생성
    func createWorksheet(userId: String, name: String, category: String, content: String, completion: @escaping (Result<WorksheetDetail, Error>) -> Void) {
        let urlString = "\(baseURL)/api/worksheet"
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let body: [String: Any] = [
            "userId": userId,
            "name": name,
            "category": category,
            "content": content
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(APIError.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.serverError(statusCode: 0, message: "No data received")))
                return
            }
            
            do {
                let worksheetDetail = try JSONDecoder().decode(WorksheetDetail.self, from: data)
                completion(.success(worksheetDetail))
            } catch {
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }
    
    // 1-5. 즐겨찾기 토글 기능
    func toggleWorksheetBookmark(worksheetId: Int, completion: @escaping (Result<Worksheet, Error>) -> Void) {
        let urlString = "\(baseURL)/api/worksheet/\(worksheetId)"
        toggleBookmark(urlString: urlString) { result in
            switch result {
            case .success(let document):
                if let worksheet = document as? Worksheet {
                    completion(.success(worksheet))
                } else {
                    completion(.failure(APIError.decodingError(NSError(domain: "Unexpected document type", code: 0, userInfo: nil))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 1-6. 빈칸학습지 마지막 이용 시간 서버에 Patch
    func updateWorksheetRecentDate(worksheetId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseURL)/api/worksheet/recentDate/\(worksheetId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }
        
        task.resume()
    }
    
    // 2-1. 홈화면 들어왔을 때. testsheet
    func getTestsheets(userId: String, completion: @escaping (Result<[Testsheet], Error>) -> Void) {
        let urlString = "\(baseURL)/api/testsheet/user/\(userId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(APIError.networkError(error)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(APIError.serverError(statusCode: 0, message: "No data received")))
                return
            }
            
            print("Received data: \(String(data: data, encoding: .utf8) ?? "")")
            
            do {
                let testsheets = try JSONDecoder().decode([Testsheet].self, from: data)
                print("Successfully decoded \(testsheets.count) testsheets")
                completion(.success(testsheets))
            } catch {
                print("Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key)' not found: \(context.debugDescription)")
                    case .valueNotFound(let value, let context):
                        print("Value '\(value)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type '\(type)' mismatch: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }
    
    // 2-2. 나만의 시험지 상세 정보 불러오기
    func getTestsheet(testsheetId: Int, completion: @escaping (Result<TestsheetDetail, Error>) -> Void) {
        let urlString = "\(baseURL)/api/testsheet/\(testsheetId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(APIError.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                completion(.failure(APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0, message: "Invalid response")))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.serverError(statusCode: 0, message: "No data received")))
                return
            }
            
            do {
                let testsheetDetail = try JSONDecoder().decode(TestsheetDetail.self, from: data)
                completion(.success(testsheetDetail))
            } catch {
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }
    
    // 2-4. 나만의 시험지 채점시 / 재응시 하기 확인 클릭시 / 재추출시
    func updateTestsheet(testsheetId: Int, isReExtracted: Bool, isCompleteAllBlanks: [Bool], userAnswers1: [String], userAnswers2: [String], isCorrect: [Bool], completion: @escaping (Result<TestsheetGrade, Error>) -> Void) {
        let urlString = "\(baseURL)/api/testsheet/\(testsheetId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "isReExtracted": isReExtracted,
            "isCompleteAllBlanks": isCompleteAllBlanks,
            "userAnswers1": userAnswers1,
            "userAnswers2": userAnswers2,
            "isCorrect": isCorrect
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(APIError.encodingError(error)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(APIError.networkError(error)))
                return
            }
                
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(APIError.serverError(statusCode: 0, message: "Invalid response")))
                return
            }
                
            print("Server response status code: \(httpResponse.statusCode)")
                
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            // Print raw response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw server response: \(responseString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let testsheetResponse = try decoder.decode(TestsheetGrade.self, from: data)
                completion(.success(testsheetResponse))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }
    
    // 2-5 테스트 sheet 북마크
    func toggleTestsheetBookmark(testsheetId: Int, completion: @escaping (Result<Testsheet, Error>) -> Void) {
        let urlString = "\(baseURL)/api/testsheet/bookmark/\(testsheetId)"
        toggleBookmark(urlString: urlString) { result in
            switch result {
            case .success(let document):
                if let testsheet = document as? Testsheet {
                    completion(.success(testsheet))
                } else {
                    completion(.failure(APIError.decodingError(NSError(domain: "Unexpected document type", code: 0, userInfo: nil))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 3-1. 홈화면 들어왔을 떄(Wrongsheet)
    func getWrongsheets(userId: String, completion: @escaping (Result<[Wrongsheet], Error>) -> Void) {
        let urlString = "\(baseURL)/api/wrongsheet/user/\(userId)"
        print("Requesting wrongsheets from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(APIError.networkError(error)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Server error with status code: \(httpResponse.statusCode)")
                    completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode, message: "Server error")))
                    return
                }
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(APIError.serverError(statusCode: 0, message: "No data received")))
                return
            }
            
            print("Received data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
            
            do {
                let wrongsheets = try JSONDecoder().decode([Wrongsheet].self, from: data)
                print("Successfully decoded \(wrongsheets.count) wrongsheets")
                completion(.success(wrongsheets))
            } catch {
                print("Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key)' not found: \(context.debugDescription)")
                    case .valueNotFound(let value, let context):
                        print("Value '\(value)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type '\(type)' mismatch: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }
    
    // 3-2. 오답노트 들어갈 때
    
    // 3-3. 오답노트 내보내기  alert 확인 버튼 클릭했을 때
    func createWrongSheet(questions: [[String: Any]], completion: @escaping (Result<WrongsheetDetail, Error>) -> Void) {
        let urlString = "\(baseURL)/api/wrongsheet"
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["questions": questions])
        } catch {
            completion(.failure(APIError.encodingError(error)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(APIError.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.serverError(statusCode: 0, message: "No data received")))
                return
            }
            
            do {
                let wrongsheetDetail = try JSONDecoder().decode(WrongsheetDetail.self, from: data)
                completion(.success(wrongsheetDetail))
            } catch {
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }
    
    // 3-4 오답노트 북마크
    func toggleWrongsheetBookmark(wrongsheetId: Int, completion: @escaping (Result<Wrongsheet, Error>) -> Void) {
        let urlString = "\(baseURL)/api/wrongsheet/\(wrongsheetId)"
        toggleBookmark(urlString: urlString) { result in
            switch result {
            case .success(let document):
                if let wrongsheet = document as? Wrongsheet {
                    completion(.success(wrongsheet))
                } else {
                    completion(.failure(APIError.decodingError(NSError(domain: "Unexpected document type", code: 0, userInfo: nil))))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func toggleBookmark(urlString: String, completion: @escaping (Result<Document, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(APIError.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.serverError(statusCode: 0, message: "No data received")))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                if let worksheet = try? decoder.decode(Worksheet.self, from: data) {
                    print("북마크 토글 성공: Worksheet")
                    completion(.success(worksheet))
                } else if let testsheet = try? decoder.decode(Testsheet.self, from: data) {
                    print("북마크 토글 성공: Testsheet")
                    completion(.success(testsheet))
                } else if let wrongsheet = try? decoder.decode(Wrongsheet.self, from: data) {
                    print("북마크 토글 성공: Wrongsheet")
                    completion(.success(wrongsheet))
                } else {
                    throw APIError.decodingError(NSError(domain: "Unable to decode document", code: 0, userInfo: nil))
                }
            } catch {
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }
    
    // delete
    func deleteWorksheet(worksheetId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/api/worksheet/\(worksheetId)"
        deleteDocument(urlString: urlString, completion: completion)
    }
    
    func deleteTestsheet(testsheetId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/api/testsheet/\(testsheetId)"
        deleteDocument(urlString: urlString, completion: completion)
    }
    
    func deleteWrongsheet(wrongsheetId: Int, completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/api/wrongsheet/\(wrongsheetId)"
        deleteDocument(urlString: urlString, completion: completion)
    }
    
    private func deleteDocument(urlString: String, completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(APIError.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                completion(.failure(APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0, message: "Invalid response")))
                return
            }
            
            completion(.success(EmptyResponse()))
        }.resume()
    }
}
