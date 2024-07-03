//
//  InquiryViewcontroller.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/4/24.
//

import UIKit
import SnapKit

class InquiryViewController: UIViewController {
    
    private let containerView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.lightGray.withAlphaComponent(0) // 배경색 변경
            view.layer.cornerRadius = 14
            view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            return view
        }()
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "문의하기"
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.textAlignment = .center
            label.isHidden = true // 타이틀 숨기기
            return label
        }()
        
    private let phoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("010-0000-0000", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = MemorableColor.Gray4
        button.layer.cornerRadius = 14
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]  // 상단 모서리만 둥글게
        // Change the target to self
        button.addTarget(nil, action: #selector(copyPhone), for: .touchUpInside)
        return button
    }()

    private let emailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("memorable@ozosama.com", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = MemorableColor.Gray4
        button.layer.cornerRadius = 14
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]  // 하단 모서리만 둥글게
        // Change the target to self
        button.addTarget(nil, action: #selector(copyEmail), for: .touchUpInside)
        return button
    }()
        
        private let cancelButton: UIButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = MemorableColor.Gray4
            button.setTitle("Cancel", for: .normal)
            button.setTitleColor(MemorableColor.Blue1, for: .normal)
            button.addTarget(InquiryViewController.self, action: #selector(dismissView), for: .touchUpInside)
            button.layer.cornerRadius = 14
            return button
        }()

    
    private let toastLabel: UILabel = {
            let label = UILabel()
            label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.alpha = 0.0
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            return label
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            setupView()
            view.addSubview(toastLabel)
            
            toastLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(containerView.snp.top).offset(-20)
                make.width.equalTo(300)
                make.height.equalTo(35)
            }
        }
    
    private func setupView() {
            view.backgroundColor = UIColor.black.withAlphaComponent(0)
            view.addSubview(containerView)
            containerView.addSubview(titleLabel)
            containerView.addSubview(phoneButton)
            containerView.addSubview(emailButton)
            containerView.addSubview(cancelButton)
            
            containerView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-34)
                make.width.equalTo(350)
                make.height.equalTo(200)
            }
            
            phoneButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(20)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(44)
            }
            
            emailButton.snp.makeConstraints { make in
                make.top.equalTo(phoneButton.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(44)
            }
            
            cancelButton.snp.makeConstraints { make in
                make.top.equalTo(emailButton.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(44)
            }
        }
    
    @objc private func copyPhone() {
        UIPasteboard.general.string = "010-9544-8491"
        showToast(message: "전화번호가 클립보드에 복사되었습니다.")
//        dismissView()
    }
    
    @objc private func copyEmail() {
        UIPasteboard.general.string = "htms0730@gmail.com"
        showToast(message: "이메일 주소가 클립보드에 복사되었습니다.")
//        dismissView()
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    private func showToast(message: String) {
        toastLabel.text = message
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                self.toastLabel.alpha = 0.0
            }) { _ in
                self.dismissView()
            }
        }
    }
}
