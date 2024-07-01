//
//  GradientView.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/1/24.
//

import UIKit

class GradientView: UIView {

    private let gradientLayer = CAGradientLayer()
    
    init(startColor: UIColor, endColor: UIColor) {
        super.init(frame: .zero)
        setupGradientLayer(startColor: startColor, endColor: endColor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupGradientLayer(startColor: UIColor, endColor: UIColor) {
        gradientLayer.colors = [
            startColor.cgColor,
            endColor.withAlphaComponent(0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.addSublayer(gradientLayer)
    }
}
