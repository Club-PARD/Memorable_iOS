//
//  HomeViewController.swift
//  Memorable
//
//  Created by 김현기 on 6/25/24.
//

import SnapKit
import UIKit

import SafariServices // 카카오 페이

class HomeViewController: UIViewController {
    var userIdentifier: String = ""
    var givenName: String = ""
    var familyName: String = ""
    var email: String = ""
    private var mostRecentWorksheetDetail: WorksheetDetail?
    private var worksheetListDisplayType: WorksheetListViewComponent.DisplayDocumentType?
    private var lastDisplayType: WorksheetListViewComponent.DisplayDocumentType?
    private var lastCategory: String?
    private var category: String = "전체보기"
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMostRecentWorksheet()
        
        // displayType에 따라 적절한 문서 필터링
        fetchDocuments { [weak self] in
            guard let self = self else { return }
                
            let displayDocuments: [Document]
            switch self.lastDisplayType ?? .worksheet {
            case .worksheet:
                displayDocuments = self.documents.filter { $0.fileType == "빈칸학습지" }
            case .testsheet:
                displayDocuments = self.documents.filter { $0.fileType == "나만의 시험지" }
            case .wrongsheet:
                displayDocuments = self.documents.filter { $0.fileType == "오답노트" }
            case .all:
                displayDocuments = self.documents
            }
                
            self.worksheetListViewComponent.setWorksheets(displayDocuments, self.lastCategory ?? "전체보기", displayType: self.lastDisplayType ?? .worksheet)
                
            // WorksheetViewController에서 돌아온 경우에만 마지막 카테고리를 선택
            if self.lastCategory != "전체보기" {
                self.worksheetListViewComponent.selectCategory(self.lastCategory ?? "전체보기")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = MemorableColor.Gray5
        headerComponent.delegate = self
        mypageView.delegate = self
        headerComponent.isUserInteractionEnabled = true
        
        userIdentifier = SignInManager.userIdentifierKey
        
        fetchDocuments()
        fetchMostRecentWorksheet()
        
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
//        hideKeyboardWhenTappedAround()
        
        headerComponent.subButton2.addTarget(self, action: #selector(handleTestCreateClicked), for: .touchUpInside)
        
        view.insertSubview(gradientView, belowSubview: maskView)
    }
    
    func fetchDocuments(completion: (() -> Void)? = nil) {
        print("Fetching documents for user ID: \(userIdentifier)")
        
        let group = DispatchGroup()
        var worksheets: [Document] = []
        var testsheets: [Document] = []
        var wrongsheets: [Document] = []
        
        group.enter()
        APIManagere.shared.getWorksheets(userId: userIdentifier) { result in
            switch result {
            case .success(let fetchedWorksheets):
                worksheets = fetchedWorksheets
            case .failure(let error):
                print("Error fetching worksheets: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        APIManagere.shared.getTestsheets(userId: userIdentifier) { result in
            switch result {
            case .success(let fetchedTestsheets):
                testsheets = fetchedTestsheets
            case .failure(let error):
                print("Error fetching testsheets: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        APIManagere.shared.getWrongsheets(userId: userIdentifier) { result in
            switch result {
            case .success(let fetchedWrongsheets):
                wrongsheets = fetchedWrongsheets
            case .failure(let error):
                print("Error fetching wrongsheets: \(error)")
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.documents = worksheets + testsheets + wrongsheets
            print("Fetched documents: Worksheets (\(worksheets.count)), Testsheets (\(testsheets.count)), Wrongsheets (\(wrongsheets.count))")
            self?.setupDocuments()
            self?.updateSharedCategories()
            completion?()
        }
        
        updateSharedCategories()
    }
    
    private func setupDocuments() {
        setupHeaderComponentDocuments()
        setupLibraryViewComponentDocuments()
        updateStarViewDocuments()
        updateWorksheetListViewDocuments()
        updateSearchedSheetViewDocuments()
    }

    private func setupHeaderComponentDocuments() {
        headerComponent.setDocuments(documents: documents)
    }

    private func setupLibraryViewComponentDocuments() {
        let worksheetDocuments = documents.filter { $0.fileType == "빈칸학습지" }
        let testsheetDocuments = documents.filter { $0.fileType == "나만의 시험지" }
        let wrongsheetDocuments = documents.filter { $0.fileType == "오답노트" }
        
        libraryViewComponent.setDocuments(worksheet: worksheetDocuments,
                                          testsheet: testsheetDocuments,
                                          wrongsheet: wrongsheetDocuments)
    }

    private func updateStarViewDocuments() {
        starView.setDocuments(documents: documents)
    }

    private func updateWorksheetListViewDocuments() {
        worksheetListViewComponent.setWorksheets(documents, category)
    }

    private func updateSearchedSheetViewDocuments() {
        searchedSheetView.setDocuments(documents: documents)
    }
    
    private func updateSharedCategories() {
        let categories = getExistingCategories()
        let userDefaults = UserDefaults(suiteName: "group.io.pard.Memorable24")
        userDefaults?.set(categories, forKey: "ExistingCategories")
        userDefaults?.synchronize()
    }
    
    private func fetchMostRecentWorksheet() {
        APIManagere.shared.getMostRecentWorksheet(userId: userIdentifier) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let worksheetDetail):
                    self?.mostRecentWorksheetDetail = worksheetDetail
                    self?.libraryViewComponent.recentWorksheetName = worksheetDetail.name
                    print(self?.libraryViewComponent.recentWorksheetName)
                    self?.libraryViewComponent.updateRecentView() // 새로운 메서드 추가
                case .failure(let error):
                    print("Error fetching most recent worksheet: \(error)")
                }
            }
        }
    }
    
    func getExistingCategories() -> [String] {
        // 모든 문서의 카테고리를 가져와 중복을 제거하고 정렬합니다.
        let allCategories = documents.map { $0.category }
        let uniqueCategories = Array(Set(allCategories))
        return uniqueCategories.sorted()
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
            make.trailing.equalToSuperview().offset(-40)
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
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(40)
//            make.trailing.equalTo(containerView.snp.leading).offset(-33)
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
        containerView.addSubview(libraryViewComponent)
        setupLibraryViewComponent()
        libraryViewComponent.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        libraryViewComponent.delegate = self
        starView.delegate = self
        worksheetListViewComponent.delegate = self
        searchedSheetView.delegate = self
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
        starView.delegate = self
        worksheetListViewComponent.delegate = self
        searchedSheetView.delegate = self
        
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
            make.trailing.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview()
        }
        
        libraryViewComponent.delegate = self
        starView.delegate = self
        worksheetListViewComponent.delegate = self
        searchedSheetView.delegate = self
        
        containerView.addSubview(libraryViewComponent)
        libraryViewComponent.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // TODO: API 연결중
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
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(40)
//            make.trailing.equalTo(containerView.snp.leading).offset(-33)
            //            make.centerY.equalTo(self.view)
            make.height.equalTo(504)
        }
    }
    
    private func setupDefaultView() {
        // 기본 레이아웃으로 되돌리기
        containerView.snp.remakeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading).offset(-16)
            make.trailing.equalToSuperview().offset(-40)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            //            make.width.equalTo(952)
            make.height.equalTo(569)
        }
        
        // titleLabel 보이기
        titleLabel.isHidden = false
        tabBar.snp.remakeConstraints { make in
            make.top.equalTo(containerView)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(40)
//            make.trailing.equalTo(containerView.snp.leading).offset(-33)
            //            make.centerY.equalTo(self.view)
            make.height.equalTo(504)
        }
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
    
    func hideWorksheetListActionSheet() {
        worksheetListViewComponent.hideActionSheet()
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
    
    func didCreateWorksheet(name: String, category: String, content: String) {
        showLoadingViewController(withMessage: "빈칸학습지를 생성하는 중입니다...\n(자료의 양에 따라 소요시간이 증가합니다)")
                
        APIManagere.shared.createWorksheet(userId: userIdentifier, name: name, category: category, content: content) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoadingViewController()
                switch result {
                case .success(let worksheetDetail):
                    print("Successfully created worksheet: \(worksheetDetail)")
                    let workSheetVC = WorkSheetViewController()
                    WorkSheetManager.shared.worksheetDetail = worksheetDetail
                    self?.navigationController?.pushViewController(workSheetVC, animated: true)
                    self?.refreshDocumentsAfterCreation()
                    self?.updateAfterDocumentChange()
                    self?.updateSharedCategories()
                case .failure(let error):
                    print("Error creating worksheet: \(error)")
                    self?.showErrorAlert(message: "학습지 생성에 실패했습니다.")
                }
            }
        }
    }
    
    func updateAfterDocumentChange() {
        fetchDocuments { [weak self] in
            guard let self = self else { return }
            
            self.updateLibraryView()
            self.setupHeaderComponent()
            self.updateWorksheetListView()
            self.updateStarView()
            self.updateSearchedSheetView()
            
            // WorksheetListViewComponent 타이틀 업데이트
            if self.viewStack.last == "worksheet" {
                self.updateWorksheetListViewTitle()
            }
        }
    }
    
    private func updateWorksheetListViewTitle() {
        let displayDocuments: [Document]
        switch lastDisplayType ?? .worksheet {
        case .worksheet:
            displayDocuments = documents.filter { $0.fileType == "빈칸학습지" }
        case .testsheet:
            displayDocuments = documents.filter { $0.fileType == "나만의 시험지" }
        case .wrongsheet:
            displayDocuments = documents.filter { $0.fileType == "오답노트" }
        case .all:
            displayDocuments = documents
        }
        
        let title: String
        switch lastDisplayType ?? .worksheet {
        case .worksheet:
            title = "총 \(displayDocuments.count)개의\n빈칸 학습지가 있어요"
        case .testsheet:
            title = "총 \(displayDocuments.count)개의\n나만의 시험지가 있어요"
        case .wrongsheet:
            title = "총 \(displayDocuments.count)개의\n오답노트가 있어요"
        case .all:
            title = "총 \(displayDocuments.count)개의\n문서가 있어요"
        }
        titleLabel.text = title
    }
    
    func refreshDocumentsAfterCreation() {
        fetchDocuments()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController: LibraryViewComponentDelegate, StarViewDelegate, WorksheetListViewComponentDelegate, SearchedSheetViewDelegate {
    func refreshLibraryView() {
        
        // displayType에 따라 적절한 문서 필터링
        fetchDocuments { [weak self] in
            guard let self = self else { return }
                
            let displayDocuments: [Document]
            switch self.lastDisplayType ?? .worksheet {
            case .worksheet:
                displayDocuments = self.documents.filter { $0.fileType == "빈칸학습지" }
            case .testsheet:
                displayDocuments = self.documents.filter { $0.fileType == "나만의 시험지" }
            case .wrongsheet:
                displayDocuments = self.documents.filter { $0.fileType == "오답노트" }
            case .all:
                displayDocuments = self.documents
            }
                
            self.worksheetListViewComponent.setWorksheets(displayDocuments, self.lastCategory ?? "전체보기", displayType: self.lastDisplayType ?? .worksheet)
                
            // WorksheetViewController에서 돌아온 경우에만 마지막 카테고리를 선택
            if self.lastCategory != "전체보기" {
                self.worksheetListViewComponent.selectCategory(self.lastCategory ?? "전체보기")
            }
        }
        DispatchQueue.main.async {
            self.fetchMostRecentWorksheet()
        }
    }
    
    func didTapWorksheetCell(inCategory category: String, displayType: WorksheetListViewComponent.DisplayDocumentType) {
        lastDisplayType = displayType
        lastCategory = category
        worksheetListDisplayType = displayType
        self.category = category
    }
    
    // worksheetlist
    func didRequestBookmarkUpdate(for document: Document, inCategory category: String, displayType: WorksheetListViewComponent.DisplayDocumentType) {
        print("북마크 업데이트 시작: \(document.id)")
        var updatedDocument = document
        updatedDocument.isBookmarked.toggle()
            
        // API 호출
        switch updatedDocument {
        case let worksheet as Worksheet:
            APIManagere.shared.toggleWorksheetBookmark(worksheetId: worksheet.id) { [weak self] result in
                self?.handleBookmarkToggleResult(result, for: updatedDocument, inCategory: category, displayType: displayType)
            }
        case let testsheet as Testsheet:
            APIManagere.shared.toggleTestsheetBookmark(testsheetId: testsheet.id) { [weak self] result in
                self?.handleBookmarkToggleResult(result, for: updatedDocument, inCategory: category, displayType: displayType)
            }
        case let wrongsheet as Wrongsheet:
            APIManagere.shared.toggleWrongsheetBookmark(wrongsheetId: wrongsheet.id) { [weak self] result in
                self?.handleBookmarkToggleResult(result, for: updatedDocument, inCategory: category, displayType: displayType)
            }
        default:
            print("Unknown document type")
        }
    }
        
    private func handleBookmarkToggleResult<T: Document>(_ result: Result<T, Error>, for document: Document, inCategory category: String, displayType: WorksheetListViewComponent.DisplayDocumentType) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let updatedDocument):
                print("북마크 토글 성공: \(type(of: updatedDocument))")
                self?.updateDocument(updatedDocument)
                    
                // WorksheetListView 업데이트
                if self?.viewStack.last == "worksheet" {
                    let updatedDocuments: [Document]
                    switch displayType {
                    case .all:
                        updatedDocuments = self?.documents ?? []
                    case .worksheet:
                        updatedDocuments = self?.documents.filter { $0.fileType == "빈칸학습지" } ?? []
                    case .testsheet:
                        updatedDocuments = self?.documents.filter { $0.fileType == "나만의 시험지" } ?? []
                    case .wrongsheet:
                        updatedDocuments = self?.documents.filter { $0.fileType == "오답노트" } ?? []
                    }
                    self?.worksheetListViewComponent.setWorksheets(updatedDocuments, self?.category ?? "전체보기", displayType: displayType)
                    self?.worksheetListViewComponent.selectCategory(category)
                }
                    
            case .failure(let error):
                print("북마크 토글 실패: \(error)")
                self?.showBookmarkUpdateErrorAlert()
            }
        }
    }
        
    private func showBookmarkUpdateErrorAlert() {
        let alert = UIAlertController(title: "오류", message: "북마크 업데이트에 실패했습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func didDeleteDocuments(for document: any Document) {
        print("Deleting document: \(document.id)")
        
        // Delete document based on type
        switch document {
        case let worksheet as Worksheet:
            APIManagere.shared.deleteWorksheet(worksheetId: worksheet.id) { [weak self] result in
                self?.handleDeleteResult(result, for: document)
            }
        case let testsheet as Testsheet:
            APIManagere.shared.deleteTestsheet(testsheetId: testsheet.id) { [weak self] result in
                self?.handleDeleteResult(result, for: document)
            }
        case let wrongsheet as Wrongsheet:
            APIManagere.shared.deleteWrongsheet(wrongsheetId: wrongsheet.id) { [weak self] result in
                self?.handleDeleteResult(result, for: document)
            }
        default:
            print("Unknown document type")
        }
    }
    
    func didModifyDocument(for document: any Document, newName: String) {
        print("Modifying document: \(document.id)")
        let updatedDocument = UpdatedDocument(name: newName)
        
        // Modify document based on type
        switch document {
        case let worksheet as Worksheet:
            APIManager.shared.updateData(
                to: "/api/worksheet/edit/\(worksheet.id)",
                body: updatedDocument
            ) { [weak self] result in
                self?.handleModifyResult(result, for: document)
            }
        case let testsheet as Testsheet:
            APIManager.shared.updateData(
                to: "/api/testsheet/edit/\(testsheet.id)",
                body: updatedDocument
            ) { [weak self] result in
                self?.handleModifyResult(result, for: document)
            }
        case let wrongsheet as Wrongsheet:
            APIManager.shared.updateData(
                to: "/api/wrongsheet/edit/\(wrongsheet.id)",
                body: updatedDocument
            ) { [weak self] result in
                self?.handleModifyResult(result, for: document)
            }
        default:
            print("Unknown document type")
        }
    }

    private func handleModifyResult(_ result: Result<Void, Error>, for document: Document) {
        fetchMostRecentWorksheet()
        
        fetchDocuments { [weak self] in
            guard let self = self else { return }
            
            let displayDocuments: [Document]
            switch self.lastDisplayType ?? .worksheet {
            case .worksheet:
                displayDocuments = self.documents.filter { $0.fileType == "빈칸학습지" }
            case .testsheet:
                displayDocuments = self.documents.filter { $0.fileType == "나만의 시험지" }
            case .wrongsheet:
                displayDocuments = self.documents.filter { $0.fileType == "오답노트" }
            case .all:
                displayDocuments = self.documents
            }
            
            self.worksheetListViewComponent.setWorksheets(displayDocuments, self.lastCategory ?? "전체보기", displayType: self.lastDisplayType ?? .worksheet)
            
            if self.lastCategory != "전체보기" {
                self.worksheetListViewComponent.selectCategory(self.lastCategory ?? "전체보기")
            }
            
            let title: String
            switch self.lastDisplayType ?? .worksheet {
            case .worksheet:
                title = "총 \(displayDocuments.count)개의\n빈칸 학습지가 있어요"
            case .testsheet:
                title = "총 \(displayDocuments.count)개의\n나만의 시험지가 있어요"
            case .wrongsheet:
                title = "총 \(displayDocuments.count)개의\n오답노트가 있어요"
            case .all:
                title = "총 \(displayDocuments.count)개의\n문서가 있어요"
            }
            self.titleLabel.text = title
        }
        
        switch result {
        case .success:
            print("Document modified successfully")
        case .failure:
            DispatchQueue.main.async {
                self.showErrorAlert(message: "문서 수정에 실패했습니다.")
            }
        }
    }
    
    private func handleDeleteResult(_ result: Result<APIManagere.EmptyResponse, Error>, for document: Document) {
        fetchMostRecentWorksheet()
        
        // displayType에 따라 적절한 문서 필터링
        fetchDocuments { [weak self] in
            guard let self = self else { return }
            
            let displayDocuments: [Document]
            switch self.lastDisplayType ?? .worksheet {
            case .worksheet:
                displayDocuments = self.documents.filter { $0.fileType == "빈칸학습지" }
            case .testsheet:
                displayDocuments = self.documents.filter { $0.fileType == "나만의 시험지" }
            case .wrongsheet:
                displayDocuments = self.documents.filter { $0.fileType == "오답노트" }
            case .all:
                displayDocuments = self.documents
            }
            
            self.worksheetListViewComponent.setWorksheets(displayDocuments, self.lastCategory ?? "전체보기", displayType: self.lastDisplayType ?? .worksheet)
            
            // WorksheetViewController에서 돌아온 경우에만 마지막 카테고리를 선택
            if self.lastCategory != "전체보기" {
                self.worksheetListViewComponent.selectCategory(self.lastCategory ?? "전체보기")
            }
            
//            // LibraryViewComponent 업데이트
//            self.updateLibraryView()
//
//            // HeaderComponent 업데이트
//            self.setupHeaderComponent()
//
            //
            let title: String
            switch self.lastDisplayType ?? .worksheet {
            case .worksheet:
                title = "총 \(displayDocuments.count)개의\n빈칸 학습지가 있어요"
            case .testsheet:
                title = "총 \(displayDocuments.count)개의\n나만의 시험지가 있어요"
            case .wrongsheet:
                title = "총 \(displayDocuments.count)개의\n오답노트가 있어요"
            case .all:
                title = "총 \(displayDocuments.count)개의\n문서가 있어요"
            }
            self.titleLabel.text = title
        }
        
        if case .failure = result {
            DispatchQueue.main.async {
                self.showDeleteErrorAlert(message: "문서 삭제에 실패했습니다.")
            }
        }
    }
    
    private func showDeleteErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func didUpdateBookmark(for document: Document) {
        print("북마크 업데이트 시작: \(document.id)")
        var updatedDocument = document
        updatedDocument.isBookmarked.toggle()
        
        // API 호출
        switch updatedDocument {
        case let worksheet as Worksheet:
            APIManagere.shared.toggleWorksheetBookmark(worksheetId: worksheet.id) { [weak self] result in
                self?.handleBookmarkToggleResult(result, for: updatedDocument)
            }
        case let testsheet as Testsheet:
            APIManagere.shared.toggleTestsheetBookmark(testsheetId: testsheet.id) { [weak self] result in
                self?.handleBookmarkToggleResult(result, for: updatedDocument)
            }
        case let wrongsheet as Wrongsheet:
            APIManagere.shared.toggleWrongsheetBookmark(wrongsheetId: wrongsheet.id) { [weak self] result in
                self?.handleBookmarkToggleResult(result, for: updatedDocument)
            }
        default:
            print("Unknown document type")
        }
    }

    private func handleBookmarkToggleResult<T: Document>(_ result: Result<T, Error>, for document: Document) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case .success(let updatedDocument):
                print("북마크 토글 성공: \(type(of: updatedDocument))")
                // 문서 업데이트 및 모든 관련 뷰 갱신
                self?.updateDocument(updatedDocument)
            case .failure(let error):
                print("북마크 토글 실패: \(error)")
                // 에러 처리 (예: 사용자에게 알림 표시)
                // 실패 시 원래 상태로 되돌리기
                var revertedDocument = document
                revertedDocument.isBookmarked.toggle()
                self?.updateDocument(revertedDocument)
            }
        }
    }
    
    private func fetchAllDocuments(completion: @escaping () -> Void) {
        fetchDocuments()
    }
    
    func didTapBackButton() {
        hideWorksheetListActionSheet()
        if viewStack.count > 1 {
            viewStack.removeLast()
            showView(config: viewStack.last!)
        }
    }
    
    func didTapWorksheetButton(with documents: [Document]) {
        showWorksheetView(withTitle: "총 \(documents.count)개의\n빈칸 학습지가 있어요", documents: documents, displayType: .worksheet)
    }
    
    func didTapTestsheetButton(with documents: [Document]) {
        showWorksheetView(withTitle: "총 \(documents.count)개의\n나만의 시험지가 있어요", documents: documents, displayType: .testsheet)
    }
    
    func didTapWrongsheetButton(with documents: [Document]) {
        showWorksheetView(withTitle: "총 \(documents.count)개의\n오답노트가 있어요", documents: documents, displayType: .wrongsheet)
    }
    
    func showWorksheetView(withTitle title: String, documents: [Document], displayType: WorksheetListViewComponent.DisplayDocumentType) {
        worksheetListViewComponent.resetFilterButtonState()
        worksheetListViewComponent.setWorksheets(documents, "전체보기", displayType: displayType)
        showView(config: "worksheet")
        titleLabel.text = title
        lastDisplayType = displayType
        lastCategory = "전체보기"
    }
    
    @objc private func handleTestCreateClicked() {
        tabBar.updateUIForFirstTab()
    }
    
    @objc func handleMaskViewTap() {
        headerComponent.plusButton.sendActions(for: .touchUpInside)
    }
    
    func didTapRecentButton() {
        if let worksheetDetail = mostRecentWorksheetDetail {
            let workSheetVC = WorkSheetViewController()
            WorkSheetManager.shared.worksheetDetail = worksheetDetail
            navigationController?.pushViewController(workSheetVC, animated: true)
        } else {
            showCreateErrorAlert(message: "최근 워크시트를 불러오는 데 실패했습니다.")
        }
    }
    
    private func showCreateErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController {
    func showLoadingViewController(withMessage message: String) {
        let loadingVC = LoadingViewController(loadingMessage: message)
        loadingVC.modalPresentationStyle = .overFullScreen
        loadingVC.modalTransitionStyle = .crossDissolve
        present(loadingVC, animated: true, completion: nil)
    }
    
    func hideLoadingViewController() {
        if let loadingVC = presentedViewController as? LoadingViewController {
            loadingVC.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateDocument(_ updatedDocument: Document) {
        print("문서 업데이트 중: \(updatedDocument.id), isBookmarked: \(updatedDocument.isBookmarked)")
        if let index = documents.firstIndex(where: { $0.id == updatedDocument.id && $0.fileType == updatedDocument.fileType }) {
            documents[index] = updatedDocument
        }
        
        // 각 뷰 업데이트
        updateLibraryView()
        updateStarView()
        updateWorksheetListView()
        updateSearchedSheetView()
        setupHeaderComponent()
    }
    
    private func updateLibraryView() {
        print("Updating LibraryView")
        let worksheetDocuments = documents.filter { $0.fileType == "빈칸학습지" }
        let testsheetDocuments = documents.filter { $0.fileType == "나만의 시험지" }
        let wrongsheetDocuments = documents.filter { $0.fileType == "오답노트" }
        
        libraryViewComponent.setDocuments(worksheet: worksheetDocuments,
                                          testsheet: testsheetDocuments,
                                          wrongsheet: wrongsheetDocuments)
    }
    
    private func updateStarView() {
        starView.setDocuments(documents: documents)
        starView.reloadTable()
    }
    
    private func updateWorksheetListView() {
        worksheetListViewComponent.setWorksheets(documents, category)
    }
    
    private func updateSearchedSheetView() {
        searchedSheetView.setDocuments(documents: documents)
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

extension HomeViewController: MypageViewDelegate {
    // 카카오페이 이동
    func mypageView(_ view: MypageView, didRequestToOpenURL url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}
