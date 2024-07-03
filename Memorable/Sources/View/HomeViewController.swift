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
    lazy var userEmail: String = "memorable@ozosama.com"
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
    
    let mockData = [
        // 빈칸학습지
        Document(fileName: "Document1", fileType: "빈칸학습지", category: "카테고리1", bookmark: true, date: makeDate(year: 2024, month: 1, day: 1)),
        Document(fileName: "Document2", fileType: "빈칸학습지", category: "카테고리2", bookmark: false, date: makeDate(year: 2024, month: 1, day: 2)),
        Document(fileName: "Document3", fileType: "빈칸학습지", category: "카테고리3", bookmark: true, date: makeDate(year: 2024, month: 1, day: 3)),
        Document(fileName: "Document4", fileType: "빈칸학습지", category: "카테고리4", bookmark: false, date: makeDate(year: 2024, month: 1, day: 4)),
        Document(fileName: "Document5", fileType: "빈칸학습지", category: "카테고리5", bookmark: true, date: makeDate(year: 2024, month: 1, day: 5)),
        Document(fileName: "Document6", fileType: "빈칸학습지", category: "카테고리6", bookmark: false, date: makeDate(year: 2024, month: 1, day: 6)),
        Document(fileName: "Document7", fileType: "빈칸학습지", category: "카테고리7", bookmark: true, date: makeDate(year: 2024, month: 1, day: 7)),
        Document(fileName: "Document8", fileType: "빈칸학습지", category: "카테고리8", bookmark: false, date: makeDate(year: 2024, month: 1, day: 8)),
        Document(fileName: "Document9", fileType: "빈칸학습지", category: "카테고리9", bookmark: true, date: makeDate(year: 2024, month: 1, day: 9)),
        Document(fileName: "Document10", fileType: "빈칸학습지", category: "카테고리1", bookmark: false, date: makeDate(year: 2024, month: 1, day: 10)),
        
        // 나만의 시험지
        Document(fileName: "Test1", fileType: "나만의 시험지", category: "카테고리2", bookmark: true, date: makeDate(year: 2024, month: 2, day: 1)),
        Document(fileName: "Test2", fileType: "나만의 시험지", category: "카테고리3", bookmark: false, date: makeDate(year: 2024, month: 2, day: 2)),
        Document(fileName: "Test3", fileType: "나만의 시험지", category: "카테고리4", bookmark: true, date: makeDate(year: 2024, month: 2, day: 3)),
        Document(fileName: "Test4", fileType: "나만의 시험지", category: "카테고리5", bookmark: false, date: makeDate(year: 2024, month: 2, day: 4)),
        Document(fileName: "Test5", fileType: "나만의 시험지", category: "카테고리6", bookmark: true, date: makeDate(year: 2024, month: 2, day: 5)),
        Document(fileName: "Test6", fileType: "나만의 시험지", category: "카테고리7", bookmark: false, date: makeDate(year: 2024, month: 2, day: 6)),
        
        // 오답노트
        Document(fileName: "Wrong1", fileType: "오답노트", category: "카테고리8", bookmark: true, date: makeDate(year: 2024, month: 3, day: 1)),
        Document(fileName: "Wrong2", fileType: "오답노트", category: "카테고리9", bookmark: false, date: makeDate(year: 2024, month: 3, day: 2)),
        Document(fileName: "Wrong3", fileType: "오답노트", category: "카테고리1", bookmark: true, date: makeDate(year: 2024, month: 3, day: 3)),
        Document(fileName: "Wrong4", fileType: "오답노트", category: "카테고리2", bookmark: false, date: makeDate(year: 2024, month: 3, day: 4)),
        Document(fileName: "Wrong5", fileType: "오답노트", category: "카테고리3", bookmark: true, date: makeDate(year: 2024, month: 3, day: 5)),
        Document(fileName: "Wrong6", fileType: "오답노트", category: "카테고리4", bookmark: false, date: makeDate(year: 2024, month: 3, day: 6)),
        Document(fileName: "Wrong7", fileType: "오답노트", category: "카테고리5", bookmark: true, date: makeDate(year: 2024, month: 3, day: 7)),
        Document(fileName: "Wrong8", fileType: "오답노트", category: "카테고리6", bookmark: false, date: makeDate(year: 2024, month: 3, day: 8))
    ]
    
    let attendanceRecord: [Bool] = [true, true, true, false, false, true, false, true, false, false, false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = MemorableColor.Gray5
        headerComponent.delegate = self
        
        setUI()
        setupViews()
        
        maskView.backgroundColor = MemorableColor.Black
        maskView.alpha = 0
        view.insertSubview(maskView, belowSubview: headerComponent)
        maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerComponent.isUserInteractionEnabled = true
        
        setupHeaderComponent()
        setupLibraryViewComponent()
        hideKeyboardWhenTappedAround()
        
        headerComponent.subButton2.addTarget(self, action: #selector(handleTestCreateClicked), for: .touchUpInside)
        
        view.insertSubview(gradientView, belowSubview: maskView)
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
        
        // header
        self.view.addSubview(headerComponent)
        headerComponent.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(76)
        }
        
        view.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(containerView)
            make.top.equalTo(containerView)
            make.height.equalTo(15)
        }
        
        // 제목
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerComponent.snp.bottom).offset(3)
            make.leading.equalTo(tabBar.snp.trailing).offset(65)
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
    }
    
    func setupViews() {
        // 모든 뷰를 미리 생성하고 containerView에 추가
        [libraryViewComponent, worksheetListViewComponent, starView, mypageView, searchedSheetView].forEach { view in
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
    
    func setupHeaderComponent() {
        let documents = mockData
        headerComponent.setDocuments(documents: documents)
    }
    
    
    func setupLibraryViewComponent() {
        containerView.snp.remakeConstraints { make in
//            make.top.equalTo(headerComponent.snp.bottom)
            make.top.equalTo(headerComponent.snp.bottom).offset(-15)
            make.leading.equalTo(tabBar.snp.trailing).offset(49)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview()
        }
        
        libraryViewComponent.delegate = self
        containerView.addSubview(libraryViewComponent)
        libraryViewComponent.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // mockData를 필터링하여 각 타입별로 분류
        let worksheetDocuments = mockData.filter { $0.fileType == "빈칸학습지" }
        let testsheetDocuments = mockData.filter { $0.fileType == "나만의 시험지" }
        let wrongsheetDocuments = mockData.filter { $0.fileType == "오답노트" }
        
        // LibraryViewComponent에 데이터 설정
        libraryViewComponent.setDocuments(worksheet: worksheetDocuments,
                                          testsheet: testsheetDocuments,
                                          wrongsheet: wrongsheetDocuments)
        
        // titleLabel 숨기기
        titleLabel.isHidden = true
    }
    
    private func setupDefaultView() {
        // 기본 레이아웃으로 되돌리기
        containerView.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalTo(tabBar)
            make.leading.equalTo(tabBar.snp.trailing).offset(49)
            make.height.equalTo(580)
        }
        
        // titleLabel 보이기
        titleLabel.isHidden = false
    }
    
    private func showView(config viewId: String) {
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
            viewStack = [viewId]
            headerComponent.showBackButton(false)
            libraryViewComponent.isHidden = false
            gradientView.isHidden = false
            setupLibraryViewComponent()
            titleLabel.text = ""
            libraryViewComponent.titleLabel.text = "\(userName)님,\n오늘도 함께 학습해 볼까요?"
        case "star":
            viewStack = [viewId]
            headerComponent.showBackButton(false)
            starView.isHidden = false
            titleLabel.isHidden = false
            gradientView.isHidden = true
            setupDefaultView()
            titleLabel.text = "\(userName)님이\n즐겨찾기한 파일"
            let worksheetDocuments = mockData.filter { $0.fileType == "빈칸학습지" }
            let testsheetDocuments = mockData.filter { $0.fileType == "나만의 시험지" }
            let wrongsheetDocuments = mockData.filter { $0.fileType == "오답노트" }
            
            // LibraryViewComponent에 데이터 설정
            starView.setDocuments(worksheet: worksheetDocuments,
                                  testsheet: testsheetDocuments,
                                  wrongsheet: wrongsheetDocuments)
        case "mypage":
            viewStack = [viewId]
            headerComponent.showBackButton(false)
            mypageView.isHidden = false
            titleLabel.isHidden = false
            gradientView.isHidden = false
            setupLibraryViewComponent()
            titleLabel.text = ""
            mypageView.titleLabel.text = "\(userName)님,\n안녕하세요!"
            mypageView.profileName.text = userName
            mypageView.profileEmail.text = userEmail
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
        self.draw(in: rect)
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
