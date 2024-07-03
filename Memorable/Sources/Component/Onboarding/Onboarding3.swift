//
//  Onboarding3.swift
//  Memorable
//
//  Created by 김현기 on 7/3/24.
//

import SnapKit
import Then
import UIKit

class Onboarding3: UIView {
    private let titleLabel = UILabel().then {
        $0.text = "오답노트로 부족한 부분만 모아요"
        $0.font = MemorableFont.LargeTitle()
    }

    private let descriptionLabel = UILabel().then {
        $0.text = "오답노트로 틀린 문제만 모아서 시험 직전에 볼 수 있어요"
        $0.font = MemorableFont.Body1()
        $0.textColor = MemorableColor.Gray1
    }

    private let onboardingImage = UIImageView().then {
        $0.image = UIImage(named: "onboarding3")
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
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(onboardingImage)
    }
    
    private func setupConstraints() {
        snp.makeConstraints { make in
            make.width.equalTo(550)
            make.height.equalTo(550)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-180)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        onboardingImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
            make.width.equalTo(400)
        }
    }
}
