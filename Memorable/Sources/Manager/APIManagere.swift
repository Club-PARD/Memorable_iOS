//
//  APIManagere.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/3/24.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(statusCode: Int, message: String)
}

class APIManagere {
    static let shared = APIManagere()
    private let baseURL = "http://172.30.1.65:8080"
    
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
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let worksheet = try JSONDecoder().decode(Worksheet.self, from: data)
                completion(.success(worksheet))
            } catch {
                completion(.failure(error))
            }
        }.resume()
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
}
