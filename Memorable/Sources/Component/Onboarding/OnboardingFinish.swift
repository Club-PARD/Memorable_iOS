//
//  OnboardingFinish.swift
//  Memorable
//
//  Created by 김현기 on 7/11/24.
//

import SnapKit
import Then
import UIKit

class OnboardingFinish: UIView {
    private var isFromProfile: Bool = false
    
    private let onboardingImage = UIImageView().then {
        $0.image = UIImage(named: "login_applogo")
        $0.contentMode = .scaleAspectFit
    }
    
    private let startButton = UIButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.titleLabel?.font = MemorableFont.Button()
        $0.backgroundColor = MemorableColor.Black
        $0.layer.cornerRadius = 30
    }
    
    private var destinationVC = HomeViewController()
    
    init(frame: CGRect, isFromProfile: Bool = false) {
        super.init(frame: frame)
        self.isFromProfile = isFromProfile
        
        addSubViews()
        setupConstraints()
        
        setupButton()
        
        startButton.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        if isFromProfile {
            startButton.setTitle("확인", for: .normal)
            destinationVC = HomeViewController()
        }
    }
    
    @objc private func didTapStart() {
        print("Tap")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
            
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            let navigationController = UINavigationController(rootViewController: self.destinationVC)
            window.rootViewController = navigationController
        }, completion: nil)
    }
    
    private func addSubViews() {
        addSubview(onboardingImage)
        addSubview(startButton)
    }
    
    private func setupConstraints() {
        snp.makeConstraints { make in
            make.height.equalTo(700)
            make.width.equalTo(1100)
        }
        
        onboardingImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
            make.width.equalTo(280)
        }
        
        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).multipliedBy(0.9)
            make.width.equalTo(460)
            make.height.equalTo(60)
        }
    }
}
