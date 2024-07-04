//
//  ExpandableMembershipView.swift
//  Memorable
//
//  Created by 김현기 on 7/4/24.
//

import SnapKit
import Then
import UIKit

class ExpandableMembershipView: UIView {
    private let containerView = UIView().then {
        $0.backgroundColor = MemorableColor.Black
        $0.layer.cornerRadius = 32
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "현재 PRO 멤버십 플랜을 사용중이에요"
        $0.font = MemorableFont.Body2()
        $0.textColor = MemorableColor.White
        $0.textAlignment = .center
    }

    private let stackView = UIStackView()
    private var isExpanded = false
    private var memberships: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = MemorableColor.Black
        
        addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isHidden = true
        containerView.addSubview(stackView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleExpand))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.height.equalTo(64) // 초기 높이
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalTo(containerView)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(with memberships: [UIView]) {
        for membership in memberships {
//            let membershipView = MembershipItemView()
//            membershipView.configure(with: membership)
            stackView.addArrangedSubview(membership)
        }
    }
    
    @objc private func toggleExpand() {
        isExpanded.toggle()
        UIView.animate(withDuration: 0.3) {
            self.containerView.layer.cornerRadius = self.isExpanded ? 40 : 32
            self.containerView.snp.updateConstraints { make in
                make.height.equalTo(self.isExpanded ? 360 : 64) // 확장 시 높이 조정
            }
            self.stackView.isHidden = !self.isExpanded
            self.layoutIfNeeded()
        }
    }
}
