//
//  Common.swift
//  Memorable
//
//  Created by 김현기 on 7/3/24.
//

import Then
import UIKit

func toJSON(info: User) throws -> Data {
    let jsonEncoder = JSONEncoder()
    do {
        let jsonData = try jsonEncoder.encode(info)
        return jsonData
    } catch {
        print("Error encoding to JSON: \(error)")
        throw error
    }
}

let activityIndicator = UIActivityIndicatorView().then {
    $0.style = .large
    $0.hidesWhenStopped = true
}
