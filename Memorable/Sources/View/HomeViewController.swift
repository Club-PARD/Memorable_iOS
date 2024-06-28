//
//  HomeViewController.swift
//  Memorable
//
//  Created by 김현기 on 6/25/24.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController, HeaderComponentDelegate {
    
    lazy var userName: String = "민석"
    let tabBar = TabBarComponent()
    let containerView = UIView()
    let titleLabel = UILabel()
    let searchComponent = HeaderComponent()
    let blockView = UIView()
    var plusTrailing = -24
    private let maskView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        setUI()
        
        searchComponent.delegate = self
        
        maskView.backgroundColor = .black
        maskView.alpha = 0
        view.insertSubview(maskView, belowSubview: searchComponent)
        maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setUI() {
        
        // 탭바
        self.view.addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(57)
            make.centerY.equalTo(self.view)
            make.width.equalTo(112)
            make.height.equalTo(504)
        }
        
        // 탭바 구성
        let tabItems: [(String, String, () -> Void)] = [
            ("라이브러리", "home", { self.showView(config: "home") }),
            ("즐겨찾기", "bookmark", { self.showView(config: "star") }),
            ("마이페이지", "mypage", { self.showView(config: "mypage") })
        ]
        
        tabBar.configure(withItems: tabItems)
        
        // 메인뷰
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(tabBar)
            make.width.equalTo(952)
            make.height.equalTo(569)
        }
        
        // 제목
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(containerView.snp.leading)
            make.bottom.equalTo(containerView.snp.top).offset(-28)
        }
        
        // SearchComponent -> header
        self.view.addSubview(searchComponent)
        searchComponent.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(76)
        }
        
        // 제목 스타일
        titleLabel.numberOfLines = 0
        // TO DO: 디자인 시스템
        
        // 임시 홈 화면 (초기화면)
        let newView = LibraryViewComponent()
        containerView.addSubview(newView)
        newView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.text = "\(userName)님,\n오늘도 함께 학습해볼까요?"
    }
    
    func didSelectTab(title: String, action: () -> Void) {
        print("\(title) clicked")
        action()
    }
    
    private func showView(config viewId: String) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        var newView = UIView()
        switch viewId {
        case "home":
            newView = LibraryViewComponent()
            titleLabel.text = "\(userName)님,\n오늘도 함께 학습해볼까요?"
        case "star":
            newView.backgroundColor = .yellow
            titleLabel.text = "\(userName)님이\n즐겨찾기한 파일"
        case "mypage":
            newView.backgroundColor = .green
            titleLabel.text = "안녕하세요 \(userName)님!"
        default:
            newView.backgroundColor = .white
            titleLabel.text = ""
        }
        
        containerView.addSubview(newView)
        newView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - HeaderComponentDelegate
    func didTapPlusButton(isMasked: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.maskView.alpha = isMasked ? 0.5 : 0
        }
    }
}

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: targetSize)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard UIGraphicsGetCurrentContext() != nil else { return nil }
        self.draw(in: rect)
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return resizedImage
    }
}
