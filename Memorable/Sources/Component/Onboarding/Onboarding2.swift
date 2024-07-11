//
//  Onboarding2.swift
//  Memorable
//
//  Created by 김현기 on 7/11/24.
//

import SnapKit
import Then
import UIKit

class Onboarding2: UIView {
    private let onboardingImage = UIImageView().then {
        $0.image = UIImage(named: "onboarding2")
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubViews() {
        addSubview(onboardingImage)
    }
    
    private func setupConstraints() {
        snp.makeConstraints { make in
            make.height.equalTo(700)
            make.width.equalTo(1100)
        }
        
        onboardingImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}
