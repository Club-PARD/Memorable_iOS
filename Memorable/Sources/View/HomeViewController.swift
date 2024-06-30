//
//  HomeViewController.swift
//  Memorable
//
//  Created by 김현기 on 6/25/24.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    lazy var userName: String = "민석"
    let tabBar = TabBarComponent()
    let containerView = UIView()
    let titleLabel = UILabel()
    let headerComponent = HeaderComponent()
    let libraryViewComponent = LibraryViewComponent()
    let worksheetListViewComponent = WorksheetListViewComponent()
    let blockView = UIView()
    var plusTrailing = -24
    private let maskView = UIView()
    
    let mockData = [
        Document(fileName: "Document1", fileType: "빈칸학습지"),
        Document(fileName: "Document2", fileType: "빈칸학습지"),
        Document(fileName: "Document3", fileType: "빈칸학습지"),
        Document(fileName: "Document4", fileType: "빈칸학습지"),
        Document(fileName: "Document5", fileType: "빈칸학습지"),
        Document(fileName: "Document6", fileType: "빈칸학습지"),
        Document(fileName: "Document7", fileType: "빈칸학습지"),
        Document(fileName: "Test1", fileType: "나만의 시험지"),
        Document(fileName: "Test2", fileType: "나만의 시험지"),
        Document(fileName: "Test3", fileType: "나만의 시험지"),
        Document(fileName: "Test4", fileType: "나만의 시험지"),
        Document(fileName: "Test5", fileType: "나만의 시험지"),
        Document(fileName: "Test6", fileType: "나만의 시험지"),
        Document(fileName: "Wrong1", fileType: "오답노트"),
        Document(fileName: "Wrong2", fileType: "오답노트"),
        Document(fileName: "Wrong3", fileType: "오답노트"),
        Document(fileName: "Wrong4", fileType: "오답노트"),
        Document(fileName: "Wrong5", fileType: "오답노트"),
        Document(fileName: "Wrong6", fileType: "오답노트"),
        Document(fileName: "Wrong7", fileType: "오답노트"),
        Document(fileName: "Wrong8", fileType: "오답노트")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        headerComponent.delegate = self
        
        setUI()
        
        maskView.backgroundColor = .black
        maskView.alpha = 0
        view.insertSubview(maskView, belowSubview: headerComponent)
        maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerComponent.isUserInteractionEnabled = true
        
        setupHeaderComponent()
        setupLibraryViewComponent()
        
        headerComponent.subButton2.addTarget(self, action: #selector(handleTestCreateClicked), for: .touchUpInside)
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
        self.view.addSubview(headerComponent)
        headerComponent.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.height.equalTo(76)
        }
        
        // 제목 스타일
        titleLabel.numberOfLines = 0
        // TO DO: 디자인 시스템
        
        
        
        // 초기화면
        libraryViewComponent.delegate = self  // delegate 설정
        containerView.addSubview(libraryViewComponent)
        libraryViewComponent.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.text = "\(userName)님,\n오늘도 함께 학습해볼까요?"
    }
    
    func didSelectTab(title: String, action: () -> Void) {
        print("\(title) clicked")
        action()
    }
    
    func setupHeaderComponent() {
        let workDocuments = mockData.filter { $0.fileType == "빈칸학습지"}
        
        headerComponent.setDocuments(
            workDocuments: workDocuments
        )
    }
    
    func setupLibraryViewComponent() {
        containerView.snp.remakeConstraints { make in
            make.top.equalTo(headerComponent.snp.bottom)
            make.leading.equalTo(tabBar.snp.trailing).offset(49)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview()
        }
        
        libraryViewComponent.delegate = self
        containerView.addSubview(libraryViewComponent)
        libraryViewComponent.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // titleLabel 숨기기
        titleLabel.isHidden = true
    }
    
    private func setupDefaultView() {
        // 기본 레이아웃으로 되돌리기
        containerView.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(tabBar)
            make.leading.equalTo(tabBar).offset(49)
            make.height.equalTo(569)
        }
        
        // titleLabel 보이기
        titleLabel.isHidden = false
    }
    
    private func showView(config viewId: String) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        switch viewId {
        case "home":
            setupLibraryViewComponent()
            titleLabel.text = "\(userName)님,\n오늘도 함께 학습해볼까요?"
        case "star":
            setupDefaultView()
            titleLabel.text = "\(userName)님이\n즐겨찾기한 파일"
        case "mypage":
            setupDefaultView()
            titleLabel.text = "안녕하세요 \(userName)님!"
        default:
            setupDefaultView()
            titleLabel.text = ""
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

extension HomeViewController: HeaderComponentDelegate {
    // MARK: - HeaderComponentDelegate
    func didTapPlusButton(isMasked: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.maskView.alpha = isMasked ? 0.5 : 0
        }
    }
}

extension HomeViewController: LibraryViewComponentDelegate {

    func didTapTopLeftButton(with documents: [Document]) {
        print("didTapTopLeftButton")
        showWorksheetView(withTitle: "총 \(documents.count)개의\n빈칸 학습지가 있어요", documents: documents)
    }

    func didTapTopRightButton(with documents: [Document]) {
        showWorksheetView(withTitle: "총 \(documents.count)개의\n나만의 시험지가 있어요", documents: documents)
    }

    func didTapBottomButton(with documents: [Document]) {
        showWorksheetView(withTitle: "총 \(documents.count)개의\n오답노트가 있어요", documents: documents)
    }
    
    func showWorksheetView(withTitle title: String, documents: [Document]) {
        print("showWorksheetView")
        // 기존 LibraryViewComponent 제거
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        // 새로운 WorksheetListViewComponent 추가
        worksheetListViewComponent.setWorksheets(documents)
        containerView.addSubview(worksheetListViewComponent)
        worksheetListViewComponent.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // titleLabel 업데이트
        titleLabel.text = title
    }
    
    @objc private func handleTestCreateClicked() {
        tabBar.updateUIForFirstTab()
    }
}
