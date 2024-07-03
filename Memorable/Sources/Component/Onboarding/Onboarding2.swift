//
//  Onboarding2.swift
//  Memorable
//
//  Created by 김현기 on 7/3/24.
//

import SnapKit
import Then
import UIKit

class Onboarding2: UIView {
    private let titleLabel = UILabel().then {
        $0.text = "나만의 시험지로 내 실력을 파악해요"
        $0.font = MemorableFont.LargeTitle()
    }

    private let descriptionLabel = UILabel().then {
        $0.text = "빈칸 시험지로 실제 시험을 치기 전 미리 내 실력을 파악할 수 있어요"
        $0.font = MemorableFont.Body1()
        $0.textColor = MemorableColor.Gray1
    }

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
            make.bottom.equalToSuperview()
            make.width.equalTo(400)
        }
    }
}
