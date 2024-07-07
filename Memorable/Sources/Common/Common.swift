//
//  Common.swift
//  Memorable
//
//  Created by 김현기 on 7/5/24.
//

import SnapKit
import Then
import UIKit

private let overlayView = UIView().then {
    $0.backgroundColor = .black.withAlphaComponent(0.3)
    $0.isHidden = false
}

let activityIndicator = UIActivityIndicatorView().then {
    $0.style = .large
    $0.hidesWhenStopped = true
}

func setupActivityIndicator(view: UIView) {
    print("Activate Indicator")
    view.addSubview(overlayView)
    view.addSubview(activityIndicator)

    overlayView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
    }
    activityIndicator.snp.makeConstraints { make in
        make.center.equalToSuperview()
    }

    activityIndicator.startAnimating()
}

func removeActivityIndicator() {
    overlayView.isHidden = true
    overlayView.removeFromSuperview()
    activityIndicator.stopAnimating()
    activityIndicator.removeFromSuperview()
}
