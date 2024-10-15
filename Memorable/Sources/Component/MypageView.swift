//
//  mypageView.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/30/24.
//

import SnapKit
import Then
import UIKit

protocol MypageViewDelegate: AnyObject {
    func mypageView(_ view: MypageView, didRequestToOpenURL url: URL)
}

class MypageView: UIView {
    weak var delegate: MypageViewDelegate?
    private let scrollView: UIScrollView
    private let contentView: UIView
    
    var titleLabel: UILabel
    
    private let profileView: UIView
    var profileName: UILabel
    var profileEmail: UILabel
    let streakView: UIView
    
    private let notificationBanner: UIView
    
    var toggleViewHeightConstraint: Constraint!
//    private let membershipToggleView = UIView().then {
//        $0.backgroundColor = MemorableColor.Black
//        $0.layer.cornerRadius = 32
//    }
    
    private var titleToggleLabel = UIStackView().then {
        let label = UILabel().then {
            $0.text = "현재 PRO 멤버십 플랜을 사용중이에요"
            $0.textColor = MemorableColor.White
            $0.font = MemorableFont.Body2(size: 20)
        }
        
        $0.addArrangedSubview(label)
        
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 10
    }
    
    private var imageView = UIImageView().then {
//        $0.image = UIImage(systemName: "chevron.down")
        $0.image = UIImage(systemName: "pencil")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = MemorableColor.White
    }

    private var isMembershipExpanded = false
    
//    private let membershipStandardButton: UIView
//    private let membershipProButton: UIView
//    private let membershipPremiumButton: UIView
    
    private let serviceLabel: UILabel
    private let logoutButton: UIButton
    private let inquiryButton: UIButton
    private let guideButton: UIButton
    private let privacyPolicyButton: UIButton
    private let removeUserButton: UIButton
    
    private var selectedMembershipButton: UIView?
//    private let purchaseButton = UIButton(type: .system).then {
//        $0.isHidden = true
//    }

    private let toastLabel = UILabel()
    
    private let inquiryDropdownView: UIView = .init()
    private let phoneLabel: UILabel = .init()
    private let emailLabel: UILabel = .init()
    private var isDropdownVisible = false
    
    override init(frame: CGRect) {
        scrollView = UIScrollView()
        contentView = UIView()
        titleLabel = UILabel()
        
        profileView = UIView()
        profileName = UILabel()
        profileEmail = UILabel()
        streakView = StreakView()
        
        notificationBanner = UIView()
//
//        membershipStandardButton = UIView()
//        membershipProButton = UIView()
//        membershipPremiumButton = UIView()
        
        serviceLabel = UILabel()
        logoutButton = UIButton(type: .system)
        inquiryButton = UIButton(type: .system)
        guideButton = UIButton(type: .system)
        privacyPolicyButton = UIButton(type: .system)
        removeUserButton = UIButton(type: .system)
        
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
//        setupTapGesture()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupTitle()
        setupProfile()
        setupNotificationBanner()
//        setupMemberships()
//        setupMembershipToggle()
        setupService()
        
        setupToastLabel()
    }
    
    private func setupTitle() {
        contentView.addSubview(titleLabel)
        titleLabel.text = "사용자님,\n안녕하세요!"
        titleLabel.numberOfLines = 0
        titleLabel.font = MemorableFont.LargeTitle()
        titleLabel.textColor = MemorableColor.Black
    }
    
    private func setupProfile() {
        contentView.addSubview(profileView)
        profileView.backgroundColor = MemorableColor.Black
        profileView.layer.cornerRadius = 120 / 2
        
        profileView.addSubview(profileName)
        profileName.text = "사용자 이름"
        profileName.textColor = MemorableColor.White
        profileName.font = MemorableFont.LargeTitle()
        
        profileView.addSubview(profileEmail)
        profileEmail.text = "memorable@ozosama.com"
        profileEmail.textColor = MemorableColor.White
        profileEmail.font = MemorableFont.Body1()
        
        profileView.addSubview(streakView)
        streakView.layer.cornerRadius = 120 / 2
        streakView.layer.masksToBounds = true
        
        // Adding gradient layers
        let streakLeftGradientView = CAGradientLayer()
        streakLeftGradientView.colors = [MemorableColor.White?.withAlphaComponent(0.8).cgColor ?? UIColor.white.withAlphaComponent(0.8).cgColor, MemorableColor.White?.withAlphaComponent(0).cgColor ?? UIColor.white.withAlphaComponent(0).cgColor]
        streakLeftGradientView.startPoint = CGPoint(x: 0, y: 0.5)
        streakLeftGradientView.endPoint = CGPoint(x: 0.5, y: 0.5)
        
        let streakRightGradientView = CAGradientLayer()
        streakRightGradientView.colors = [MemorableColor.White?.withAlphaComponent(0).cgColor ?? UIColor.white.withAlphaComponent(0).cgColor, MemorableColor.White?.withAlphaComponent(0.8).cgColor ?? UIColor.white.withAlphaComponent(0.8).cgColor]
        streakRightGradientView.startPoint = CGPoint(x: 0.5, y: 0.5)
        streakRightGradientView.endPoint = CGPoint(x: 1, y: 0.5)
        
        streakView.layer.addSublayer(streakLeftGradientView)
        streakView.layer.addSublayer(streakRightGradientView)
            
        // Ensure the gradient layers are added after the subviews are added
        streakView.layoutIfNeeded()
        streakLeftGradientView.frame = CGRect(x: 0, y: 0, width: streakView.bounds.width / 2, height: streakView.bounds.height)
        streakRightGradientView.frame = CGRect(x: streakView.bounds.width / 2, y: 0, width: streakView.bounds.width / 2, height: streakView.bounds.height)
        
        // Update the frame of the gradient layers
        streakLeftGradientView.frame = CGRect(x: 0, y: 0, width: streakView.bounds.width / 2, height: streakView.bounds.height)
        streakRightGradientView.frame = CGRect(x: streakView.bounds.width / 2, y: 0, width: streakView.bounds.width / 2, height: streakView.bounds.height)

        profileName.text = "사용자 이름"
        profileEmail.text = "memorable@ozosama.com"
    }

    private func setupNotificationBanner() {
        contentView.addSubview(notificationBanner)
        notificationBanner.backgroundColor = MemorableColor.Yellow1
        notificationBanner.layer.cornerRadius = 18
        
        let notificationLabel = UILabel()
        notificationLabel.text = "이번주에 벌써 3일이나 출석했어요!🎉 짝짝짝!"
        notificationLabel.textColor = MemorableColor.White
        notificationLabel.font = UIFont.systemFont(ofSize: 14)
        notificationBanner.addSubview(notificationLabel)
        
        notificationLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    func updateNotificationMessage() {
        if let streakView = streakView as? StreakView {
            let score = streakView.score
            notificationBanner.subviews.forEach { $0.removeFromSuperview() }
            
            let notificationLabel = UILabel()
            notificationLabel.text = "이번주에 벌써 \(score)일이나 출석했어요!🎉 짝짝짝!"
            notificationLabel.textColor = MemorableColor.Black
            notificationLabel.font = MemorableFont.BodyCaption()
            notificationBanner.addSubview(notificationLabel)
            
            notificationLabel.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
            }
        }
    }
    
//    private func setupMembershipToggle() {
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleMembership(_:)))
//        membershipToggleView.addGestureRecognizer(tapGestureRecognizer)
//        contentView.addSubview(membershipToggleView)
//        membershipToggleView.addSubview(titleToggleLabel)
//        titleToggleLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalToSuperview().offset(20)
//        }
//        titleToggleLabel.addArrangedSubview(imageView)
//    }
//
//    @objc private func toggleMembership(_ sender: UITapGestureRecognizer) {
//        isMembershipExpanded.toggle()
//
//        let newHeight = isMembershipExpanded ? 350 : 0
//
//        if isMembershipExpanded {
//            UIView.animate(withDuration: 0.3) {
//                self.toggleViewHeightConstraint.deactivate()
    ////                self.membershipToggleView.snp.makeConstraints { make in
    ////                    make.top.equalTo(self.profileView.snp.bottom).offset(40)
    ////                    make.leading.trailing.equalTo(self.profileView)
    ////                    self.toggleViewHeightConstraint = make.height.equalTo(newHeight).constraint
    ////                }
//
    ////                self.contentView.addSubview(self.purchaseButton)
//
//                self.layoutIfNeeded()
//            }
//            completion: { _ in
//                self.membershipToggleView.addSubview(self.membershipStandardButton)
//                self.membershipToggleView.addSubview(self.membershipProButton)
//                self.membershipToggleView.addSubview(self.membershipPremiumButton)
//
//                self.membershipStandardButton.alpha = 0
//                self.membershipProButton.alpha = 0
//                self.membershipPremiumButton.alpha = 0
//
//                self.membershipProButton.snp.makeConstraints { make in
//                    make.top.equalToSuperview().offset(68)
//                    make.bottom.equalToSuperview().offset(-22)
//                    make.centerX.equalToSuperview()
//                    make.width.equalToSuperview().multipliedBy(0.31)
//                }
//
//                self.membershipStandardButton.snp.makeConstraints { make in
//                    make.top.equalToSuperview().offset(68)
//                    make.bottom.equalToSuperview().offset(-22)
//                    make.leading.equalToSuperview().offset(20)
//                    make.width.equalToSuperview().multipliedBy(0.31)
//                }
//
//                self.membershipPremiumButton.snp.makeConstraints { make in
//                    make.top.equalToSuperview().offset(68)
//                    make.bottom.equalToSuperview().offset(-22)
//                    make.trailing.equalToSuperview().offset(-20)
//                    make.width.equalToSuperview().multipliedBy(0.31)
//                }
//
//                self.layoutIfNeeded()
//
//                UIView.animate(withDuration: 0.2) {
//                    self.membershipStandardButton.alpha = 1
//                    self.membershipProButton.alpha = 1
//                    self.membershipPremiumButton.alpha = 1
//                }
//            }
//        } else {
//            UIView.animate(withDuration: 0.2) {
//                self.membershipStandardButton.removeFromSuperview()
//                self.membershipProButton.removeFromSuperview()
//                self.membershipPremiumButton.removeFromSuperview()
//
//                self.resetAllMembershipButtons()
    ////                self.purchaseButton.removeFromSuperview()
//
//                self.layoutIfNeeded()
//            } completion: { _ in
//                UIView.animate(withDuration: 0.3) {
//                    self.toggleViewHeightConstraint.deactivate()
//                    self.membershipToggleView.snp.makeConstraints { make in
//                        make.top.equalTo(self.profileView.snp.bottom).offset(40)
//                        make.leading.trailing.equalTo(self.profileView)
//                        self.toggleViewHeightConstraint = make.height.equalTo(64).constraint
//                    }
//
//                    self.layoutIfNeeded()
//                }
//            }
//        }
//
//        imageView.image = isMembershipExpanded ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
//    }
    
//    private func setupMemberships() {
//        setupMembershipButton(membershipStandardButton, title: "Standard", details: "· PDF 파일 10개 업로드\n· 빈칸학습지, 시험지 재추출 1회\n· 오답노트 사용 제한", sale: "", price: "")
//        setupMembershipButton(membershipProButton, title: "Pro", details: "· PDF 파일 50개 업로드\n· 빈칸학습지, 시험지 재추출 3회\n· 오답노트 사용 가능", sale: "", price: "", isSelected: true)
//        setupMembershipButton(membershipPremiumButton, title: "Premium", details: "· PDF 파일 업로드 무제한\n· 빈칸학습지, 시험지 재추출 무제한\n· 오답노트 사용 가능\n· 광고배너 삭제 및 추가 업데이트 우선 사용 가능", sale: "", price: "")
//
    ////        setupPurchaseButton()
//    }
    
//    private func setupMembershipButton(_ button: UIView, title: String, details: String, sale: String, price: String, isSelected: Bool = false) {
//        button.backgroundColor = MemorableColor.White
//        button.layer.cornerRadius = 40
//
//        let titleLabel = UILabel()
//        titleLabel.text = title
//        titleLabel.textAlignment = .center
//        titleLabel.textColor = MemorableColor.White
//        titleLabel.font = MemorableFont.Body1()
//        titleLabel.backgroundColor = MemorableColor.Black
//        titleLabel.layer.cornerRadius = 16.5
//        titleLabel.clipsToBounds = true
//
//        let detailsLabel = UILabel()
//        detailsLabel.text = details
//        detailsLabel.textColor = MemorableColor.Gray1
//        detailsLabel.font = MemorableFont.BodyCaption()
//        detailsLabel.numberOfLines = 0
//
//        let saleLabel = UILabel()
//        saleLabel.text = sale
//        saleLabel.textColor = MemorableColor.Gray3
//        saleLabel.font = MemorableFont.Title()
//        saleLabel.attributedText = saleLabel.text?.strikeThrough()
//
//        let priceLabel = UILabel()
//        priceLabel.text = price
//        priceLabel.font = MemorableFont.LargeTitle()
//        priceLabel.textColor = MemorableColor.Black
//
//        let periodLabel = UILabel()
//        periodLabel.text = "연간"
//        periodLabel.textColor = MemorableColor.Gray1
//        periodLabel.font = MemorableFont.BodyCaption()
//
//        let optionLabel = UILabel()
//        optionLabel.text = "VAT 별도"
//        optionLabel.textColor = MemorableColor.Gray1
//        optionLabel.font = MemorableFont.BodyCaption()
//
//        button.addSubview(titleLabel)
//        button.addSubview(detailsLabel)
//        button.addSubview(saleLabel)
//        button.addSubview(priceLabel)
//        button.addSubview(periodLabel)
//        button.addSubview(optionLabel)
//
//        if isSelected {
//            let selectedLabel = UILabel()
//            selectedLabel.text = "사용중인 플랜"
//            selectedLabel.textAlignment = .center
//            selectedLabel.font = MemorableFont.Body1()
//            selectedLabel.textColor = .gray
//            selectedLabel.backgroundColor = MemorableColor.Gray5
//            selectedLabel.layer.cornerRadius = 16.5
//            selectedLabel.clipsToBounds = true
//            button.addSubview(selectedLabel)
//
//            selectedLabel.snp.makeConstraints { make in
//                make.leading.equalTo(titleLabel.snp.trailing).offset(8)
//                make.centerY.equalTo(titleLabel)
//                make.width.equalTo(106)
//                make.height.equalTo(33)
//            }
//        }
//
//        titleLabel.snp.makeConstraints { make in
//            make.top.leading.equalToSuperview().offset(24)
//            make.height.equalTo(33)
//            make.width.equalTo(titleLabel.intrinsicContentSize.width + 16)
//        }
//
//        detailsLabel.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(16)
//            make.leading.equalTo(titleLabel)
//        }
//
//        priceLabel.snp.makeConstraints { make in
//            make.bottom.leading.equalToSuperview().inset(24)
//        }
//
//        saleLabel.snp.makeConstraints { make in
//            make.leading.equalTo(priceLabel)
//            make.bottom.equalTo(priceLabel.snp.top)
//        }
//
//        periodLabel.snp.makeConstraints { make in
//            make.leading.equalTo(priceLabel.snp.trailing).offset(4)
//            make.centerY.equalTo(priceLabel)
//        }
//
//        optionLabel.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().offset(-24)
//            make.centerY.equalTo(priceLabel)
//        }
//
//        // 버튼에 탭 제스처 추가
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(membershipButtonTapped(_:)))
//        button.addGestureRecognizer(tapGesture)
//        button.isUserInteractionEnabled = true
//
//        // 태그 설정 (버튼 식별을 위해)
    ////        button.tag = [membershipStandardButton, membershipProButton, membershipPremiumButton].firstIndex(of: button) ?? 0
//    }
    
    private func setupService() {
        contentView.addSubview(serviceLabel)
        serviceLabel.text = "서비스"
        serviceLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        setupServiceButton(logoutButton, title: "로그아웃하기", imageName: "logout", action: #selector(showLogoutAlert))
        setupServiceButton(inquiryButton, title: "문의하기", imageName: "inquiry", action: #selector(showInquiryActionSheet))
        setupServiceButton(guideButton, title: "사용가이드 보기", imageName: "guide", action: #selector(showUserGuide))
        setupServiceButton(privacyPolicyButton, title: "개인정보처리방침", imageName: "privacy", action: #selector(seePrivacyPolicy))
        setupServiceButton(removeUserButton, title: "회원 탈퇴하기", imageName: "removeuser", action: #selector(showRemoveUserAlert))
        
        contentView.addSubview(logoutButton)
        contentView.addSubview(inquiryButton)
        contentView.addSubview(guideButton)
        contentView.addSubview(privacyPolicyButton)
        contentView.addSubview(removeUserButton)
    }
    
//    private func setupPurchaseButton() {
//        purchaseButton.setTitle("구매하기", for: .normal)
//        purchaseButton.setTitleColor(MemorableColor.White, for: .normal)
//        purchaseButton.titleLabel?.font = MemorableFont.Button()
//        purchaseButton.backgroundColor = MemorableColor.Blue1
//        purchaseButton.layer.cornerRadius = 30
//        purchaseButton.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
//        contentView.addSubview(purchaseButton)
//    }
    
//    private func setupTapGesture() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        addGestureRecognizer(tapGesture)
//    }
    
    private func setupServiceButton(_ button: UIButton, title: String, imageName: String, action: Selector) {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.title = title
        buttonConfig.titleAlignment = .leading
        
        if let originalImage = UIImage(named: imageName) {
            let desiredSize = CGSize(width: 24, height: 24) // 원하는 이미지 크기
            UIGraphicsBeginImageContextWithOptions(desiredSize, false, 0.0)
            originalImage.draw(in: CGRect(origin: .zero, size: desiredSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let configuredImage = resizedImage?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .regular))
            buttonConfig.image = configuredImage
        }
        
        buttonConfig.baseForegroundColor = MemorableColor.Black
        buttonConfig.imagePadding = 12
        buttonConfig.imagePlacement = .leading
        buttonConfig.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        
        buttonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = MemorableFont.Body2()
            return outgoing
        }
        
        button.configuration = buttonConfig
        
        // UIButton에 직접 적용
        button.contentHorizontalAlignment = .leading
        
        button.backgroundColor = MemorableColor.White
        button.layer.cornerRadius = 40
        button.clipsToBounds = true
        
        // 텍스트 크기 자동 조절 (선택사항)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        
        // 버튼에 타겟 액션 추가
        button.addTarget(self, action: action, for: .touchUpInside)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.greaterThanOrEqualTo(scrollView.snp.height).offset(200) // Ensure contentView is taller than scrollView
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(19)
            make.leading.equalToSuperview().offset(16)
        }
        
        profileView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        
        profileName.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.centerY.equalToSuperview()
        }
        
        profileEmail.snp.makeConstraints { make in
            make.leading.equalTo(profileName.snp.trailing).offset(12)
            make.centerY.equalTo(profileName)
        }
        
        streakView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(494)
        }
        
        notificationBanner.snp.makeConstraints { make in
            make.bottom.equalTo(profileView.snp.top).offset(-12)
            make.trailing.equalTo(profileView.snp.trailing).offset(-30)
            make.width.equalTo(283)
            make.height.equalTo(36)
        }
        
//        membershipToggleView.snp.makeConstraints { make in
//            make.top.equalTo(profileView.snp.bottom).offset(40)
//            make.leading.trailing.equalTo(profileView)
//            self.toggleViewHeightConstraint = make.height.equalTo(64).constraint
//        }
//
        serviceLabel.snp.makeConstraints { make in
//            make.top.equalTo(membershipToggleView.snp.bottom).offset(40)
            make.top.equalTo(profileView.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(20)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(serviceLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview()
            make.width.equalTo(inquiryButton)
            make.height.equalTo(80)
        }
        
        inquiryButton.snp.makeConstraints { make in
            make.top.equalTo(logoutButton)
            make.leading.equalTo(logoutButton.snp.trailing).offset(20)
            make.trailing.equalToSuperview()
            make.width.equalTo(logoutButton)
            make.height.equalTo(80)
        }
        
        guideButton.snp.makeConstraints { make in
            make.top.equalTo(logoutButton.snp.bottom).offset(20)
            make.leading.equalTo(logoutButton)
            make.width.equalTo(logoutButton)
            make.height.equalTo(80)
        }
        
        privacyPolicyButton.snp.makeConstraints { make in
            make.top.equalTo(guideButton)
            make.leading.equalTo(guideButton.snp.trailing).offset(20)
            make.width.equalTo(logoutButton)
            make.height.equalTo(80)
        }
        
        removeUserButton.snp.makeConstraints { make in
            make.top.equalTo(privacyPolicyButton.snp.bottom).offset(20)
            make.leading.equalTo(privacyPolicyButton)
            make.width.equalTo(logoutButton)
            make.height.equalTo(80)
        }
    }
    
    private func setupToastLabel() {
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        addSubview(toastLabel)
        
        toastLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
            make.width.equalTo(300)
            make.height.equalTo(35)
        }
    }
    
    private func showToast(message: String) {
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        
        let maxSize = CGSize(width: frame.width - 40, height: CGFloat.greatestFiniteMagnitude)
        let expectedSize = toastLabel.sizeThatFits(maxSize)
        
        toastLabel.snp.updateConstraints { make in
            make.width.equalTo(min(expectedSize.width + 20, self.frame.width - 40))
            make.height.equalTo(expectedSize.height + 10)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                self.toastLabel.alpha = 0.0
            })
        }
    }
    
    private func resetButtonUI(_ button: UIView) {
        button.backgroundColor = MemorableColor.White
        button.layer.borderWidth = 0
        for view in button.subviews {
            if let label = view as? UILabel {
                label.isHidden = false
                if label == button.subviews.first {
                    label.backgroundColor = MemorableColor.Black
                    label.textColor = MemorableColor.White
                }
                if label.text == "사용중인 플랜" {
                    label.backgroundColor = MemorableColor.Gray5
                }
            }
        }
    }
    
//    private func resetAllMembershipButtons() {
//        for button in [membershipStandardButton, membershipProButton, membershipPremiumButton] {
//            resetButtonUI(button)
//        }
//        selectedMembershipButton = nil
    ////        purchaseButton.isHidden = true
//    }
    
    // updateButtonUI 메서드 수정
    private func updateButtonUI(_ button: UIView) {
        button.backgroundColor = MemorableColor.Blue3
        button.layer.borderColor = MemorableColor.Blue2?.cgColor
        button.layer.borderWidth = 1

        for view in button.subviews {
            if let label = view as? UILabel {
                switch label.text {
                case "사용중인 플랜":
                    label.backgroundColor = MemorableColor.Gray5
                    label.textColor = MemorableColor.Gray1
                case _ where label == button.subviews.first:
                    label.backgroundColor = MemorableColor.Blue2
                    label.textColor = MemorableColor.White
                case _ where label.text == "사용중인 플랜":
                    label.isHidden = false
                default:
                    label.isHidden = false
                }
            }
        }

//        if let _ = button.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.text == "사용중인 플랜" }) {
//            purchaseButton.setTitle("결제 관리하기", for: .normal)
//        } else {
//            purchaseButton.setTitle("구매하기", for: .normal)
//        }
//
//        var buttonConfig = purchaseButton.configuration
//        buttonConfig?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -4, bottom: 0, trailing: 0)
//        purchaseButton.configuration = buttonConfig
    }
    
//    @objc private func membershipButtonTapped(_ gesture: UITapGestureRecognizer) {
//        guard let tappedView = gesture.view else { return }
//
//        // 이전에 선택된 버튼이 현재 탭된 버튼과 같다면 리셋
//        if selectedMembershipButton == tappedView {
//            resetAllMembershipButtons()
//            return
//        }
//
//        // 이전에 선택된 버튼의 UI 복원
//        if let previousButton = selectedMembershipButton {
//            resetButtonUI(previousButton)
//        }
//
//        // 새로운 버튼 선택
//        selectedMembershipButton = tappedView
//        updateButtonUI(tappedView)
//
    ////        // purchaseButton 설정
    ////        purchaseButton.removeFromSuperview()
    ////        contentView.addSubview(purchaseButton)
    ////        purchaseButton.snp.makeConstraints { make in
    ////            make.centerX.equalTo(tappedView.snp.centerX)
    ////            make.leading.equalTo(tappedView.snp.leading).offset(24)
    ////            make.trailing.equalTo(tappedView.snp.trailing).offset(-24)
    ////            make.bottom.equalTo(tappedView.snp.bottom).offset(-24)
    ////            make.height.equalTo(60)
    ////        }
    ////        purchaseButton.isHidden = false
//        layoutIfNeeded()
//
//        // titleLabel, detailsLabel, selectedLabel을 보여줌
//        for view in tappedView.subviews {
//            if let label = view as? UILabel {
//                label.isHidden = false
//            }
//        }
//    }
    
    // purchaseButtonTapped 메서드 수정
//    @objc private func purchaseButtonTapped() {
//        guard let selectedButton = selectedMembershipButton else { return }
//        _ = ["Standard", "Pro", "Premium"][selectedButton.tag]
//
//        if purchaseButton.title(for: .normal) == "결제 관리하기" {
//            showToast(message: "추후 결제 및 관리는 다음 버전 출시 시 사용가능합니다.")
//        } else {
//            showToast(message: "다음 버전 출시 시 멤버십 플랜이 업데이트 됩니다.")
//        }
//    }
//    @objc private func purchaseButtonTapped() {
//        guard let selectedButton = selectedMembershipButton else { return }
//        let membershipType: MembershipType
//
//        switch selectedButton.tag {
//        case 0:
//            membershipType = .standard
//        case 1:
//            membershipType = .pro
//        case 2:
//            membershipType = .premium
//        default:
//            return
//        }
//
//        if purchaseButton.title(for: .normal) == "결제 관리하기" {
//            let now = Date()
//            let calendar = Calendar.current
//
//            let currentYear = calendar.component(.year, from: now)
//            let currentMonth = calendar.component(.month, from: now)
//            let currentDay = calendar.component(.day, from: now)
//
//            var nextBillingMonth = currentMonth
//            var nextBillingYear = currentYear
//
//            if currentDay > 10 {
//                nextBillingMonth += 1
//                if nextBillingMonth > 12 {
//                    nextBillingMonth = 1
//                    nextBillingYear += 1
//                }
//            }
//
//            let message = "다음 자동 결제일은 \(nextBillingMonth)월 10일 입니다."
//            showToast(message: message)
//        } else {
//            KakaoPAYManager.shared.prepareKakaoPayment(for: membershipType) { [weak self] success, message in
//                guard let self = self else { return }
//                DispatchQueue.main.async {
//                    if success, let responseData = message?.data(using: .utf8) {
//                        do {
//                            if let jsonResult = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
//                                if let webURL = jsonResult["next_redirect_pc_url"] as? String ?? jsonResult["next_redirect_mobile_url"] as? String,
//                                   let url = URL(string: webURL)
//                                {
//                                    self.delegate?.mypageView(self, didRequestToOpenURL: url)
//                                } else {
//                                    self.showToast(message: "결제 페이지 URL을 찾을 수 없습니다.")
//                                }
//                            } else {
//                                self.showToast(message: "결제 정보를 처리하는 데 실패했습니다.")
//                            }
//                        } catch {
//                            self.showToast(message: "결제 정보를 처리하는 데 실패했습니다: \(error.localizedDescription)")
//                        }
//                    } else {
//                        self.showToast(message: "결제 준비 중 오류가 발생했습니다: \(message ?? "")")
//                    }
//                }
//            }
//        }
//    }
    
//    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
//        let location = gesture.location(in: self)
//        if !membershipStandardButton.frame.contains(location) &&
//            !membershipProButton.frame.contains(location) &&
//            !membershipPremiumButton.frame.contains(location)
//        {
//            resetAllMembershipButtons()
//        }
//    }
    
    // 로그아웃 알림창 표시 메서드
    @objc private func showLogoutAlert() {
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "예", style: .default, handler: { _ in
            // 로그아웃 처리 코드
            self.signOut()
        }))
        alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: nil))
        if let viewController = window?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    // 회원 탈퇴 알림창 표시 메서드
    @objc private func showRemoveUserAlert() {
        let alert = UIAlertController(title: "회원 탈퇴", message: "가입하신 모든 정보가 삭제되며 업로드된 파일 정보가 모두 지워집니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "아니오", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "예", style: .destructive, handler: { _ in
            print("Identifier: \(SignInManager.userIdentifierKey)")
            // 회원 탈퇴 처리 코드
            APIManager.shared.deleteData(endpoint: "/api/users/\(SignInManager.userIdentifierKey)") { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("사용자 삭제 실패: \(error.localizedDescription)")
                    } else {
                        print("사용자 삭제 성공")
                        UserDefaults.standard.removeObject(forKey: SignInManager.userIdentifierKey)
                        
                        guard let navigationController = self.window?.rootViewController as? UINavigationController else { return }
                        navigationController.setViewControllers([LoginViewController()], animated: true)
                    }
                }
            }
        }))
        if let viewController = window?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func seePrivacyPolicy() {
        print("Privacy Policy")
        if let viewController = window?.rootViewController {
            viewController.present(PrivacyPolicyViewController(), animated: true, completion: nil)
        }
    }
    
    @objc func signOut() {
        print("❎ Signed Out")

        UserDefaults.standard.removeObject(forKey: "login")
        
        guard let navigationController = window?.rootViewController as? UINavigationController else { return }
        navigationController.setViewControllers([LoginViewController()], animated: false)
    }
    
    @objc private func showInquiryActionSheet() {
        let inquiryVC = InquiryViewController()
        inquiryVC.modalPresentationStyle = .overFullScreen
        inquiryVC.modalTransitionStyle = .coverVertical
        
        if let viewController = window?.rootViewController {
            viewController.present(inquiryVC, animated: true, completion: nil)
        }
    }
    
    @objc private func showUserGuide() {
        print("SHOW User Guide")
        guard let navigationController = window?.rootViewController as? UINavigationController else { return }
        navigationController.pushViewController(OnboardingViewController(isFromProfile: true), animated: true)
    }
    
    // 문의하기 토스트 메시지 표시 메서드
    @objc private func showInquiryToast() {
        showToast(message: "전화번호 010-9544-8491\n이메일 htms0730@gmail.com")
    }
}

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
}
