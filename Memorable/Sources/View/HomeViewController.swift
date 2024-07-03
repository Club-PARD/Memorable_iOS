//
//  HomeViewController.swift
//  Memorable
//
//  Created by 김현기 on 6/25/24.
//

import SnapKit
import UIKit

class HomeViewController: UIViewController {
    var userIdentifier: String = ""
    var givenName: String = ""
    var familyName: String = ""
    var email: String = ""
    
    let tabBar = TabBarComponent()
    let containerView = UIView()
    let titleLabel = UILabel()
    let headerComponent = HeaderComponent()
    let libraryViewComponent = LibraryViewComponent()
    let starView = StarView()
    let searchedSheetView = SearchedSheetView()
    var serachedSheets: [Document] = []
    let mypageView = MypageView()
    let worksheetListViewComponent = WorksheetListViewComponent()
    let blockView = UIView()
    var plusTrailing = -24
    private let maskView = UIView()
    let gradientView = GradientView(startColor: MemorableColor.Gray5 ?? UIColor.lightGray, endColor: MemorableColor.Gray5 ?? UIColor.lightGray)
    
    private var viewStack: [String] = ["home"]
    
    var documents: [Document] = []
    
    let attendanceRecord: [Bool] = [true, true, true, false, false, true, false, true, false, false, false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDocuments()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = MemorableColor.Gray5
        headerComponent.delegate = self
        
        userIdentifier = UserDefaults.standard.string(forKey: SignInManager.userIdentifierKey)!
        
        if let userData = UserDefaults.standard.data(forKey: "userInfo") {
            if let decodedData = try? JSONDecoder().decode(User.self, from: userData) {
                print("User Info: \(decodedData)")
                givenName = decodedData.givenName
                familyName = decodedData.familyName
                email = decodedData.email
            }
        }
        
        setUI()
        setupViews()
        
        view.addSubview(maskView)
        view.bringSubviewToFront(headerComponent)
        setupMaskView()
        setupHeaderComponent()
        setupLibraryViewComponent()
        hideKeyboardWhenTappedAround()
        
        headerComponent.subButton2.addTarget(self, action: #selector(handleTestCreateClicked), for: .touchUpInside)
        
        view.insertSubview(gradientView, belowSubview: maskView)
    }
    
    func fetchDocuments() {
        APIManagere.shared.getDocuments(userId: userIdentifier) { [weak self] result in
            switch result {
            case .success(let documents):
                self?.documents = documents
                DispatchQueue.main.async {
                    self?.setupHeaderComponent()
                    self?.setupLibraryViewComponent()
                }
            case .failure(let error):
                print("Error fetching documents: \(error)")
                // 에러 처리 로직 추가
            }
        }
    }
    
    func setUI() {
        // header
        view.addSubview(headerComponent)
        headerComponent.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(76)
        }
        
        // 제목
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerComponent.snp.bottom).offset(3)
            make.leading.equalToSuperview().offset(182)
        }
        
        // 제목 스타일
        titleLabel.numberOfLines = 0
        // TO DO: 디자인 시스템
        
        // 메인뷰
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading).offset(-16)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            //            make.width.equalTo(952)
            make.height.equalTo(569)
        }
        
        view.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(containerView)
            make.top.equalTo(containerView)
            make.height.equalTo(15)
        }
        
        // 탭바
        view.addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(109)
            make.trailing.equalTo(containerView.snp.leading).offset(-33)
            //            make.centerY.equalTo(self.view)
            make.height.equalTo(504)
        }
        
        // 탭바 구성
        let tabItems: [(String, String, () -> Void)] = [
            ("라이브러리", "home", { self.showView(config: "home") }),
            ("즐겨찾기", "bookmark", { self.showView(config: "star") }),
            ("마이페이지", "mypage", { self.showView(config: "mypage") })
        ]
        
        tabBar.configure(withItems: tabItems)
        
        // 초기화면
        libraryViewComponent.delegate = self // delegate 설정
        containerView.addSubview(libraryViewComponent)
        libraryViewComponent.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupViews() {
        // 모든 뷰를 미리 생성하고 containerView에 추가
        for view in [libraryViewComponent, worksheetListViewComponent, starView, mypageView, searchedSheetView] {
            containerView.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            view.isHidden = true
        }
        
        libraryViewComponent.delegate = self
        
        // 초기 뷰 설정
        showView(config: "home")
    }
    
    func didSelectTab(title: String, action: () -> Void) {
        print("\(title) clicked")
        action()
    }
    
    func setupMaskView() {
        maskView.backgroundColor = MemorableColor.Black
        maskView.alpha = 0
        maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerComponent.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMaskViewTap))
        maskView.addGestureRecognizer(tapGesture)
    }
    
    func setupHeaderComponent() {
        headerComponent.setDocuments(documents: documents)
    }
    
    func setupLibraryViewComponent() {
        containerView.snp.remakeConstraints { make in
            //            make.top.equalTo(headerComponent.snp.bottom)
            make.top.equalTo(headerComponent.snp.bottom).offset(-15)
            make.leading.equalTo(titleLabel.snp.leading).offset(-16)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview()
        }
        
        libraryViewComponent.delegate = self
        containerView.addSubview(libraryViewComponent)
        libraryViewComponent.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // mockData를 필터링하여 각 타입별로 분류
        let worksheetDocuments = documents.filter { $0.fileType == "빈칸학습지" }
        let testsheetDocuments = documents.filter { $0.fileType == "나만의 시험지" }
        let wrongsheetDocuments = documents.filter { $0.fileType == "오답노트" }
        // LibraryViewComponent에 데이터 설정
        libraryViewComponent.setDocuments(worksheet: worksheetDocuments,
                                          testsheet: testsheetDocuments,
                                          wrongsheet: wrongsheetDocuments)
        
        // titleLabel 숨기기
        titleLabel.isHidden = true
        
        tabBar.snp.remakeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(115.5)
            make.trailing.equalTo(containerView.snp.leading).offset(-33)
            //            make.centerY.equalTo(self.view)
            make.height.equalTo(504)
        }
    }
    
    private func setupDefaultView() {
        // 기본 레이아웃으로 되돌리기
        containerView.snp.remakeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading).offset(-16)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            //            make.width.equalTo(952)
            make.height.equalTo(569)
        }
        
        // titleLabel 보이기
        titleLabel.isHidden = false
        tabBar.snp.remakeConstraints { make in
            make.top.equalTo(containerView)
            make.trailing.equalTo(containerView.snp.leading).offset(-33)
            //            make.centerY.equalTo(self.view)
            make.height.equalTo(504)
        }
    }
    
    func updateStarView() {
        starView.setDocuments(documents: documents)
    }
    
    private func showView(config viewId: String) {
        _ = documents.filter { $0.fileType == "빈칸학습지" }
        _ = documents.filter { $0.fileType == "나만의 시험지" }
        _ = documents.filter { $0.fileType == "오답노트" }
        titleLabel.font = MemorableFont.LargeTitle()
        titleLabel.textColor = MemorableColor.Black
        // 모든 뷰를 숨기고 선택된 뷰만 표시
        [libraryViewComponent, worksheetListViewComponent, starView, mypageView, searchedSheetView].forEach { $0.isHidden = true }
        
        switch viewId {
        case "home", "star", "mypage":
            tabBar.enableFirstTab(true)
        default:
            tabBar.enableFirstTab(false)
        }
        
        switch viewId {
        case "home":
            // mockData를 필터링하여 각 타입별로 분류
            // LibraryViewComponent에 데이터 설정
            viewStack = [viewId]
            headerComponent.showBackButton(false)
            libraryViewComponent.isHidden = false
            gradientView.isHidden = false
            setupLibraryViewComponent()
            titleLabel.text = ""
            libraryViewComponent.titleLabel.text = "\(givenName)님,\n오늘도 함께 학습해 볼까요?"
        case "star":
            viewStack = [viewId]
            headerComponent.showBackButton(false)
            starView.isHidden = false
            titleLabel.isHidden = false
            gradientView.isHidden = true
            setupDefaultView()
            titleLabel.text = "\(givenName)님이\n즐겨찾기한 파일"
            updateStarView() // StarView 업데이트 추가
        case "mypage":
            viewStack = [viewId]
            headerComponent.showBackButton(false)
            mypageView.isHidden = false
            titleLabel.isHidden = false
            gradientView.isHidden = false
            setupLibraryViewComponent()
            titleLabel.text = ""
            mypageView.titleLabel.text = "\(givenName)님,\n안녕하세요!"
            mypageView.profileName.text = givenName
            mypageView.profileEmail.text = email
            if let streakView = mypageView.streakView as? StreakView {
                streakView.setAttendanceRecord(attendanceRecord)
            }
            mypageView.updateNotificationMessage()
        case "searchedSheet":
            viewStack.append(viewId)
            headerComponent.showBackButton(true)
            searchedSheetView.isHidden = false
            titleLabel.isHidden = false
            gradientView.isHidden = true
            setupDefaultView()
            searchedSheetView.resetFilterButtonState()
        case "worksheet":
            viewStack.append(viewId)
            headerComponent.showBackButton(true)
            worksheetListViewComponent.isHidden = false
            titleLabel.isHidden = false
            gradientView.isHidden = true
            setupDefaultView()
        // 여기서 worksheetListViewComponent에 대한 추가 설정을 할 수 있습니다.
        // 예: worksheetListViewComponent.reloadData()
        default:
            break
        }
    }
}

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: targetSize)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard UIGraphicsGetCurrentContext() != nil else { return nil }
        draw(in: rect)
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return resizedImage
    }
}

extension HomeViewController: HeaderComponentDelegate {
    func didTapPlusButton(isMasked: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.maskView.alpha = isMasked ? 0.5 : 0
        }
    }
    
    func didSearchDocuments(with documents: [Document], searchText: String) {
        print("didSearchDocuments")
        searchedSheetView.setDocuments(documents: documents)
        showView(config: "searchedSheet")
        titleLabel.text = "총 \(documents.count)개의\n\"\(searchText)\" 검색결과가 있어요"
    }
}

extension HomeViewController: LibraryViewComponentDelegate {
    func didTapBackButton() {
        if viewStack.count > 1 {
            viewStack.removeLast()
            showView(config: viewStack.last!)
        }
    }
    
    func didTapWorksheetButton(with documents: [Document]) {
        showWorksheetView(withTitle: "총 \(documents.count)개의\n빈칸 학습지가 있어요", documents: documents)
    }
    
    func didTapTestsheetButton(with documents: [Document]) {
        showWorksheetView(withTitle: "총 \(documents.count)개의\n나만의 시험지가 있어요", documents: documents)
    }
    
    func didTapWrongsheetButton(with documents: [Document]) {
        showWorksheetView(withTitle: "총 \(documents.count)개의\n오답노트가 있어요", documents: documents)
    }
    
    func showWorksheetView(withTitle title: String, documents: [Document]) {
        print("showWorksheetView")
        
        worksheetListViewComponent.setWorksheets(documents)
        showView(config: "worksheet")
        
        // titleLabel 업데이트
        titleLabel.text = title
    }
    
    @objc private func handleTestCreateClicked() {
        tabBar.updateUIForFirstTab()
    }
    
    @objc func handleMaskViewTap() {
        headerComponent.plusButton.sendActions(for: .touchUpInside)
    }
}

extension HomeViewController: RecentsheetCellDelegate {
    func didTapBookmark(for document: Document) {
        // TODO: 클백
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
