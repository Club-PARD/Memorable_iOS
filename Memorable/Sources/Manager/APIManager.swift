//
//  APIManager.swift
//  Memorable
//
//  Created by 김현기 on 6/30/24.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    let baseURL = "rootUrl"
    
    // 각 function 의 endpoint는 rootUrl 뒤의 나머지
    func fetchData<T: Decodable>(endpoint: String, completion: @escaping (T?, Error?) -> Void) {
        let urlString = "\(baseURL)\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data returned", code: 0, userInfo: nil))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                completion(decodedData, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func postData<T: Encodable>(endpoint: String, body: T, completion: @escaping (Error?) -> Void) {
        let urlString = "\(baseURL)\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            completion(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(body)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { _, _, error in
                if let error = error {
                    completion(error)
                    return
                }
                completion(nil)
            }
            task.resume()
        } catch {
            completion(error)
        }
    }
    
    func deleteData(endpoint: String, completion: @escaping (Error?) -> Void) {
        let urlString = "\(baseURL)\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            completion(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
        task.resume()
    }
}
