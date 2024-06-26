//
//  HomeViewController.swift
//  Memorable
//
//  Created by 김현기 on 6/25/24.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController, TabBarComponentDelegate {
    
    lazy var userName: String = "민석"
    let tabBar = TabBarComponent()
    let containerView = UIView()
    let titleLabel = UILabel()
    let searchComponent = SearchComponent()
    let blockView = UIView()
    var plusTrailing = -24
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setUI()
    }
    
    func setUI() {
        // 탭바
        self.view.addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(86)
            make.centerY.equalTo(self.view)
            make.width.equalTo(112)
            make.height.equalTo(504)
        }
        
        // 탭바 action 설정
        let titles = ["홈", "즐겨찾기", "마이페이지"]
        let actions: [() -> Void] = [
            { self.showView(config: "home") },
            { self.showView(config: "star") },
            { self.showView(config: "mypage") }
        ]
        
        tabBar.configure(withTitles: titles, actions: actions)
        tabBar.delegate = self
        
        // 메인뷰
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(tabBar.snp.trailing).offset(50)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(tabBar)
            make.height.equalTo(550)
        }
        
        // 제목
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(containerView.snp.leading)
            make.bottom.equalTo(containerView.snp.top).offset(-28)
            make.height.equalTo(90)
        }
        
        // SearchComponent
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
        let newView = UIView()
        newView.backgroundColor = .red
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
        
        let newView = UIView()
        switch viewId {
        case "home":
            newView.backgroundColor = .red
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
