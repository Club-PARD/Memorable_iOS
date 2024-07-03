//
//  APIManager.swift
//  Memorable
//
//  Created by 김현기 on 7/3/24.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case noData
    case encodingError
    case decodingError
}

// MARK: - 사용 예시

// MARK: - GET

/*
    do {
        let users: [User] = try await API.get(.path("/users"))
        print(users)
    } catch {
        print("Error: \(error)")
    }
 */

// MARK: - POST

/*
 do {
     let newUser = User(name: "John", age: 30)
     try await API.post(.path("/users"), body: newUser)
     print("User created successfully")
 } catch {
     print("Error: \(error)")
 }
 */

// MARK: - DELETE

/*
 do {
     try await API.delete(.path("/users/1"))
     print("User deleted successfully")
 } catch {
     print("Error: \(error)")
 }
*/

enum APIManager {
    static let baseURL = "rootUrl"
    
    enum Endpoint {
        case path(String)
        
        var url: URL? {
            switch self {
            case .path(let path):
                return URL(string: APIManager.baseURL + path)
            }
        }
    }
    
    static func get<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }
            
        let (data, response) = try await URLSession.shared.data(from: url)
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }
            
        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw APIError.noData
        }
            
        do {
            let decoder = JSONDecoder()
            print("✅ Successfully Got Data! (\(httpResponse.statusCode))")
            
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    static func post<T: Encodable>(_ endpoint: Endpoint, body: T) async throws {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        } catch {
            throw APIError.encodingError
        }
            
        let (_, response) = try await URLSession.shared.data(for: request)
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }
            
        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw APIError.noData
        }
        
        print("✅ Successfully Posted! (\(httpResponse.statusCode))")
    }
    
    static func delete(_ endpoint: Endpoint) async throws {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }
            
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
            
        let (_, response) = try await URLSession.shared.data(for: request)
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noData
        }
            
        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw APIError.noData
        }
        
        print("✅ Successfully Deleted! (\(httpResponse.statusCode))")
    }
}
