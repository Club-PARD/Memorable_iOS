//
//  KakaoPAYManager.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/8/24.
//

import Foundation

enum MembershipType {
    case standard
    case pro
    case premium
}

class KakaoPAYManager {
    static let shared = KakaoPAYManager()
    
    private init() {}
    
    func prepareKakaoPayment(for membershipType: MembershipType, completion: @escaping (Bool, String?) -> Void) {
        let url = URL(string: "https://open-api.kakaopay.com/online/v1/payment/ready")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 실제 시크릿 키로 대체하세요
        let secretKey = Bundle.main.object(forInfoDictionaryKey: "KakaoPAY_API_KEY") as? String ?? ""
        request.addValue("SECRET_KEY \(secretKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = getParameters(for: membershipType)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error: \(error.localizedDescription)")
            completion(false, "Failed to prepare payment data")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false, "Network error occurred")
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(false, "No data received from server")
                return
            }
            
            // 응답 처리
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
                completion(true, responseString)
            } else {
                completion(false, "Failed to process server response")
            }
        }
        
        task.resume()
    }
    
    private func getParameters(for membershipType: MembershipType) -> [String: Any] {
        var parameters: [String: Any] = [
            "cid": "TCSEQUENCE",
            "partner_order_id": "partner_order_id",
            "partner_user_id": "partner_user_id",
            "quantity": 1,
            "vat_amount": 900,
            "tax_free_amount": 0,
            "approval_url": "https://developers.kakao.com/success",
            "fail_url": "https://developers.kakao.com/fail",
            "cancel_url": "https://developers.kakao.com/cancel"
        ]
        
        switch membershipType {
        case .standard:
            parameters["item_name"] = "Memorable Standard Membership"
            parameters["total_amount"] = 10000
        case .pro:
            parameters["item_name"] = "Memorable Pro Membership"
            parameters["total_amount"] = 32000
        case .premium:
            parameters["item_name"] = "Memorable Premium Membership"
            parameters["total_amount"] = 48000
        }
        
        return parameters
    }
}
