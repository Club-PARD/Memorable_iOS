//
//  Common.swift
//  Memorable
//
//  Created by 김현기 on 7/5/24.
//

import Then
import UIKit

let activityIndicator = UIActivityIndicatorView().then {
    $0.style = .large
    $0.hidesWhenStopped = true
}

func setupActivityIndicator(view: UIView) {
    view.addSubview(activityIndicator)
    activityIndicator.center = view.center
}

func removeActivityIndicator() {
    activityIndicator.removeFromSuperview()
}
