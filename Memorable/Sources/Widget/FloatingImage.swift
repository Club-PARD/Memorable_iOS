//
//  FloatingLabel.swift
//  Memorable
//
//  Created by 김현기 on 6/30/24.
//

import UIKit

class FloatingImage: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAnimation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAnimation()
    }

    private func setupAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.values = [-5, 5, -5]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = 2
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        layer.add(animation, forKey: "floating")
    }
}
