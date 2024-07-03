////
////  APIManager.swift
////  Memorable
////
////  Created by 김현기 on 7/3/24.
////
//
// import Foundation
//
// enum APIError: Error {
//    case invalidURL
//    case noData
//    case encodingError
//    case decodingError
// }
//
//// MARK: - 사용 예시
//
//// MARK: - GET
//
/// *
//    do {
//        let users: [User] = try await API.get(.path("/users"))
//        print(users)
//    } catch {
//        print("Error: \(error)")
//    }
// */
//
//// MARK: - POST
//
/// *
// do {
//     let newUser = User(name: "John", age: 30)
//     try await API.post(.path("/users"), body: newUser)
//     print("User created successfully")
// } catch {
//     print("Error: \(error)")
// }
// */
//
//// MARK: - DELETE
//
/// *
// do {
//     try await API.delete(.path("/users/1"))
//     print("User deleted successfully")
// } catch {
//     print("Error: \(error)")
// }
// */
//
// enum APIManager {
//    static let baseURL = "172.30.1.11:8080"
//
//    static func get<T: Decodable>(path: String) async throws -> T {
//        guard let url = URL(string: "\(baseURL)\(path)") else {
//            throw APIError.invalidURL
//        }
//
//        let (data, response) = try await URLSession.shared.data(from: url)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw APIError.noData
//        }
//
//        guard (200 ... 299).contains(httpResponse.statusCode) else {
//            throw APIError.noData
//        }
//
//        do {
//            let decoder = JSONDecoder()
//            print("✅ Successfully Got Data! (\(httpResponse.statusCode))")
//
//            return try decoder.decode(T.self, from: data)
//        } catch {
//            throw APIError.decodingError
//        }
//    }
//
//    static func post<T: Encodable>(path: String, body: T) async throws {
//        let urlString = "\(baseURL)\(path)"
//        print(urlString)
//        guard let url = URL(string: urlString) else {
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let encoder = JSONEncoder()
//            request.httpBody = try encoder.encode(body)
//        } catch {
//            throw APIError.encodingError
//        }
//
//        let (_, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw APIError.noData
//        }
//
//        guard (200 ... 299).contains(httpResponse.statusCode) else {
//            throw APIError.noData
//        }
//
//        print("✅ Successfully Posted! (\(httpResponse.statusCode))")
//    }
//
//    static func update<T: Encodable>(path: String, body: T) async throws {
//        guard let url = URL(string: "\(baseURL)\(path)") else {
//            throw APIError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "PATCH"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let encoder = JSONEncoder()
//            request.httpBody = try encoder.encode(body)
//        } catch {
//            throw APIError.encodingError
//        }
//
//        let (_, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw APIError.noData
//        }
//
//        guard (200 ... 299).contains(httpResponse.statusCode) else {
//            throw APIError.noData
//        }
//
//        print("✅ Successfully Updated! (\(httpResponse.statusCode))")
//    }
//
//    static func delete(path: String) async throws {
//        guard let url = URL(string: "\(baseURL)\(path)") else {
//            throw APIError.invalidURL
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//
//        let (_, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw APIError.noData
//        }
//
//        guard (200 ... 299).contains(httpResponse.statusCode) else {
//            throw APIError.noData
//        }
//
//        print("✅ Successfully Deleted! (\(httpResponse.statusCode))")
//    }
// }
//
// extension APIManager {
//    // GET 래퍼 함수
//    static func get<T: Decodable>(path: String, completion: @escaping (Result<T, Error>) -> Void) {
//        Task {
//            do {
//                let result: T = try await get(path: path)
//                completion(.success(result))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//
//    // POST 래퍼 함수
//    static func post<T: Encodable>(path: String, body: T, completion: @escaping (Result<Void, Error>) -> Void) {
//        print("Path: \(path)")
//        Task {
//            do {
//                try await post(path: path, body: body)
//                completion(.success(()))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//
//    // UPDATE 래퍼 함수
//    static func update<T: Encodable>(path: String, body: T, completion: @escaping (Result<Void, Error>) -> Void) {
//        Task {
//            do {
//                try await update(path: path, body: body)
//                completion(.success(()))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
//
//    // DELETE 래퍼 함수
//    static func delete(path: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        Task {
//            do {
//                try await delete(path: path)
//                completion(.success(()))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
// }
