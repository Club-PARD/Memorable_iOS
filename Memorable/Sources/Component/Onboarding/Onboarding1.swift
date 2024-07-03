//
//  Onboarding1.swift
//  Memorable
//
//  Created by 김현기 on 7/3/24.
//

import SnapKit
import Then
import UIKit

class Onboarding1: UIView {
    private let titleLabel = UILabel().then {
        $0.text = "중요한 키워드를 반복해서 학습해요"
        $0.font = MemorableFont.LargeTitle()
    }

    private let descriptionLabel = UILabel().then {
        $0.text = "공부자료를 올리면 주요 메모러블이 키워드를 자동 추출 후 빈칸 학습지를 제공해요"
        $0.font = MemorableFont.Body1()
        $0.textColor = MemorableColor.Gray1
    }

    private let onboardingImage = UIImageView().then {
        $0.image = UIImage(named: "onboarding1")
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
