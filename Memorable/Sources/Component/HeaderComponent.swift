//
//  HeaderComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/25/24.
//

import PDFKit
import SnapKit
import UIKit
import UniformTypeIdentifiers
import Vision

protocol HeaderComponentDelegate: AnyObject {
    func didTapBackButton()
    func didTapPlusButton(isMasked: Bool)
    func didTapWorksheetButton(with documents: [Document])
    func didTapTestsheetButton(with documents: [Document])
    func didSearchDocuments(with documents: [Document], searchText: String)
    func didCreateWorksheet(name: String, category: String, content: String)
    func refreshDocumentsAfterCreation()
}

class HeaderComponent: UIView {
    weak var delegate: HeaderComponentDelegate?
    
    private let appLogoImageView = UIImageView()
    private let backButton = UIButton()
    private let searchBar = UISearchBar()
    private let searchButton = UIButton()
    private let backButtonOverlayView = UIView()
    private let searchButtonOverlayView = UIView()
    let plusButton = UIButton()
    private let plusButtonImageView = UIImageView()
    private let subButtonsContainer = UIView()
    private let subButton1 = UIButton()
    let subButton2 = UIButton()
    
    private var isExpanded = false
    private var isMasked = false
    private var searchTrailing: CGFloat = -124
    private var documents: [Document] = []
    private var uploadedFileName = ""
    
    private var pdfDocument: PDFDocument?
    private var extractedText: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isUserInteractionEnabled || isHidden || alpha <= 0.01 {
            return nil
        }
        
        if subButtonsContainer.point(inside: convert(point, to: subButtonsContainer), with: event) {
            return subButtonsContainer.hitTest(convert(point, to: subButtonsContainer), with: event)
        }
        
        if let hitView = searchResultsTableView.hitTest(convert(point, to: searchResultsTableView), with: event) {
            return hitView
        }
        
        return super.hitTest(point, with: event)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        setupAppLogoImageView()
        setupBackButton()
        setupPlusButton()
        setupSearchButton()
        setupOverlayViews()
        setupSearchBar()
        setupSubButtons()
        // MARK: SearchBar 추가 기능
        setupSearchResultsTableView()
    }
    
    private func setupAppLogoImageView() {
        addSubview(appLogoImageView)
        appLogoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.centerY.equalToSuperview()
            make.width.equalTo(126)
            make.height.equalTo(15.07)
        }
        appLogoImageView.image = UIImage(named: "applogo-v2")
    }
    
    private func setupBackButton() {
        addSubview(backButton)
        let image = UIImage(systemName: "chevron.left")
        backButton.setImage(image, for: .normal)
        backButton.tintColor = MemorableColor.Gray1
        backButton.backgroundColor = MemorableColor.White
        backButton.contentMode = .scaleAspectFit
        backButton.layer.cornerRadius = 0.5 * 44
        backButton.clipsToBounds = true
        backButton.isHidden = true // 초기에는 숨김 상태
        backButtonOverlayView.isHidden = true
        
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(appLogoImageView.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    func showBackButton(_ show: Bool) {
        backButton.isHidden = !show
        backButtonOverlayView.isHidden = !show
    }
    
    private func setupPlusButton() {
        addSubview(plusButton)
        plusButton.addSubview(plusButtonImageView)
        
        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-40)
            make.centerY.equalToSuperview()
            make.width.equalTo(88)
            make.height.equalTo(44)
        }
        
        plusButtonImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        if let originalImage = UIImage(named: "btnPlus") {
            let resizedImage = originalImage.resized(to: CGSize(width: 24, height: 24))
            plusButtonImageView.image = resizedImage
        }
        plusButton.backgroundColor = MemorableColor.Blue2
        plusButton.layer.cornerRadius = 22
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    private func setupSearchButton() {
        addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.trailing.equalTo(plusButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        if let searchImage = UIImage(named: "btnSearch")?.resized(to: CGSize(width: 24, height: 24)) {
            searchButton.setImage(searchImage, for: .normal)
        }
        searchButton.imageView?.contentMode = .center
        searchButton.backgroundColor = MemorableColor.Black
        searchButton.layer.cornerRadius = 22
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    private func setupOverlayViews() {
        searchButtonOverlayView.backgroundColor = MemorableColor.Black
        searchButtonOverlayView.alpha = 0
        addSubview(searchButtonOverlayView)
        searchButtonOverlayView.snp.makeConstraints { make in
            make.edges.equalTo(searchButton)
        }
        searchButtonOverlayView.layer.cornerRadius = 22
        
        backButtonOverlayView.backgroundColor = MemorableColor.Black
        backButtonOverlayView.alpha = 0
        addSubview(backButtonOverlayView)
        backButtonOverlayView.snp.makeConstraints { make in
            make.edges.equalTo(backButton)
        }
        backButtonOverlayView.layer.cornerRadius = 0.5 * 44
    }
    
    private func setupSearchBar() {
        addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.trailing.equalTo(plusButton.snp.leading).offset(-12)
            make.centerY.equalTo(searchButton.snp.centerY)
            make.height.equalTo(44)
            make.width.equalTo(0)
        }
        searchBar.alpha = 0
        setupSearchBarStyle()
    }
    
    private func setupSearchBarStyle() {
        searchBar.barTintColor = MemorableColor.Black
        searchBar.backgroundImage = UIImage()
        searchBar.layer.cornerRadius = 22
        searchBar.layer.masksToBounds = true
        if let searchIcon = UIImage(named: "btnSearch-gray")?.resized(to: CGSize(width: 24, height: 24)) {
            searchBar.setImage(searchIcon, for: UISearchBar.Icon.search, state: .normal)
        }
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = MemorableColor.Black
            textField.textColor = MemorableColor.Black
            textField.layer.cornerRadius = 22
            textField.clipsToBounds = true
            textField.font = MemorableFont.Body1()
        }
        
        searchBar.delegate = self
    }
    
    private func setupSubButtons() {
        addSubview(subButtonsContainer)
        subButtonsContainer.addSubview(subButton1)
        subButtonsContainer.addSubview(subButton2)
        
        subButtonsContainer.alpha = 0
        
        subButtonsContainer.snp.makeConstraints { make in
            make.top.equalTo(plusButton.snp.bottom).offset(8)
            make.trailing.equalTo(plusButton)
            make.width.equalTo(190)
        }
        
        subButton1.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(45)
        }
        
        subButton2.snp.makeConstraints { make in
            make.top.equalTo(subButton1.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(45)
        }
        
        for item in [subButton1, subButton2] {
            item.backgroundColor = MemorableColor.White
            item.setTitleColor(.black, for: .normal)
            item.titleLabel?.font = MemorableFont.Body1()
            item.layer.cornerRadius = 22
            item.alpha = 0
            item.isUserInteractionEnabled = true
        }
        
        subButton1.setTitle("빈칸학습지 생성하기", for: .normal)
        subButton2.setTitle("시험지 생성하기", for: .normal)
        
        subButton1.addTarget(self, action: #selector(createWorksheet), for: .touchUpInside)
        
        subButton2.addTarget(self, action: #selector(createTestsheet), for: .touchUpInside)
        
        subButtonsContainer.isUserInteractionEnabled = true
    }
    
    private func animateSearchBar() {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
            // Move search button
            self.searchButton.snp.updateConstraints { make in
                make.trailing.equalTo(self.plusButton.snp.leading).offset(-818)
            }
            
            // Expand search bar
            let screenWidth = UIScreen.main.bounds.width
            self.searchBar.snp.updateConstraints { make in
                make.width.equalTo(screenWidth - 322)
            }
            
            // Change colors
            self.searchBar.backgroundColor = MemorableColor.White
            self.searchBar.searchTextField.backgroundColor = MemorableColor.White
            self.searchButton.backgroundColor = MemorableColor.White
            
            // Show search bar
            self.searchBar.alpha = 1
            
            // Change plus button to cancel button
            self.plusButtonImageView.isHidden = true
            self.plusButton.setTitle("취소", for: .normal)
            self.plusButton.titleLabel?.font = MemorableFont.Body1()
            self.plusButton.titleLabel?.textColor = MemorableColor.Gray1
            self.plusButton.backgroundColor = MemorableColor.Gray4
            
            self.layoutIfNeeded()
        })
    }
    
    private func hideSearchBar() {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
            // Move search button back
            self.searchButton.snp.updateConstraints { make in
                make.trailing.equalTo(self.plusButton.snp.leading).offset(-20)
            }
            
            // Collapse search bar
            self.searchBar.snp.updateConstraints { make in
                make.width.equalTo(0)
            }
            
            // Change colors back
            self.searchBar.backgroundColor = MemorableColor.Black
            self.searchBar.searchTextField.backgroundColor = MemorableColor.Black
            self.searchButton.backgroundColor = MemorableColor.Black
            
            // Hide search bar
            self.searchBar.alpha = 0
            
            // Change cancel button back to plus button
            self.plusButtonImageView.isHidden = false
            self.plusButton.setTitle(nil, for: .normal)
            self.plusButton.backgroundColor = MemorableColor.Blue2
            
            self.layoutIfNeeded()
        })
    }
    
    private func rotatePlusButton() {
        UIView.animate(withDuration: 0.3) {
            self.plusButton.backgroundColor = MemorableColor.Black
            self.plusButtonImageView.transform = CGAffineTransform(rotationAngle: .pi / 4)
            self.searchButtonOverlayView.alpha = 0.5
            self.backButtonOverlayView.alpha = 0.5
        }
        searchButton.isEnabled.toggle()
    }
    
    private func deRotatePlusButton() {
        UIView.animate(withDuration: 0.3) {
            self.plusButton.backgroundColor = MemorableColor.Blue2
            self.plusButtonImageView.transform = CGAffineTransform.identity
            self.searchButtonOverlayView.alpha = 0
            self.backButtonOverlayView.alpha = 0
        }
        searchButton.isEnabled.toggle()
    }
    
    private func toggleSubButtons() {
        subButtonsContainer.isHidden = false // 항상 보이도록 설정
        UIView.animate(withDuration: 0.3) {
            self.subButtonsContainer.alpha = self.isMasked ? 1 : 0
            self.subButton1.alpha = self.isMasked ? 1 : 0
            self.subButton2.alpha = self.isMasked ? 1 : 0
        } completion: { _ in
            if !self.isMasked {
                self.subButtonsContainer.isHidden = true
            }
        }
    }
    
    func setDocuments(documents: [Document]) {
        self.documents = documents
    }
    
    private func presentDocumentPicker(for fileType: String) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.image], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .formSheet
        documentPicker.view.tintColor = MemorableColor.Blue2 // 다큐먼트픽커 테마색
        
        if let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first?.rootViewController
        {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    func handleDocument(url: URL, fileName: String, fileType: String) {
            let fileCoordinator = NSFileCoordinator()
            var error: NSError?
            fileCoordinator.coordinate(readingItemAt: url, options: [], error: &error) { newURL in
                print("Accessing file at URL: \(newURL)")
                if fileType == "pdf" {
                    self.pdfDocument = PDFDocument(url: newURL)
                    if self.pdfDocument != nil {
                        print("PDF document loaded successfully")
                        self.extractTextFromPDF { [weak self] in
                            self?.showNameAlert(fileName: fileName, previousName: "")
                        }
                    } else {
                        print("Failed to load PDF document from URL: \(newURL)")
                    }
                } else if ["jpg", "jpeg", "png"].contains(fileType) {
                    DispatchQueue.global().async {
                        do {
                            let imageData = try Data(contentsOf: newURL)
                            guard let image = UIImage(data: imageData) else {
                                print("Failed to load image from URL: \(newURL)")
                                return
                            }
                            print("Image loaded successfully from URL: \(newURL)")
                            self.extractTextFromImage(image: image) { [weak self] in
                                DispatchQueue.main.async {
                                    self?.showNameAlert(fileName: fileName, previousName: "")
                                }
                            }
                        } catch {
                            print("Error loading image data: \(error)")
                        }
                    }
                }
            }
            if let error = error {
                print("Failed to access file: \(error.localizedDescription)")
            }
        }
    
   func extractTextFromPDF(completion: @escaping () -> Void) {
        guard let pdfDocument = pdfDocument else {
            print("No PDF to extract text from")
            completion()
            return
        }
        
        extractedText = ""
        let dispatchGroup = DispatchGroup()
        
        for pageIndex in 0 ..< pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex) {
                if let pageText = page.string, !pageText.isEmpty {
                    // PDF에 텍스트 레이어가 있는 경우 이를 사용
                    extractedText += pageText
                } else {
                    // 텍스트 레이어가 없거나 비어있는 경우 OCR 사용
                    let pageImage = page.thumbnail(of: page.bounds(for: .mediaBox).size, for: .mediaBox)
                    dispatchGroup.enter()
                    recognizeTextInImage(image: pageImage) { recognizedText in
                        self.extractedText += recognizedText
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    func extractTextFromImage(image: UIImage, completion: @escaping () -> Void) {
        recognizeTextInImage(image: image) { recognizedText in
            self.extractedText = recognizedText
            completion()
        }
    }

    func recognizeTextInImage(image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            completion(recognizedStrings.joined(separator: "\n"))
        }

        request.recognitionLanguages = ["ko", "en"]

        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
            completion("")
        }
    }
    
    private func showNameAlert(fileName: String, previousName: String) {
        let nameAlertController = UIAlertController(title: "이름 설정하기", message: "해당 학습지의 이름을 설정해 주세요", preferredStyle: .alert)
        nameAlertController.addTextField { textField in
            textField.placeholder = fileName
            textField.text = previousName
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
        }
        let nameConfirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let sheetName = nameAlertController.textFields?.first?.text, !sheetName.isEmpty else { return }
            self?.showCategoryAlert(sheetName: sheetName)
        }
        let nameCancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            self?.isMasked.toggle()
            self?.delegate?.didTapPlusButton(isMasked: self?.isMasked ?? false)
            self?.deRotatePlusButton()
            self?.toggleSubButtons()
        }
        
        nameAlertController.addAction(nameConfirmAction)
        nameAlertController.addAction(nameCancelAction)
        
        presentAlert(nameAlertController)
    }
    
    private func showCategoryAlert(sheetName: String) {
        let existingCategories = getExistingCategories()
        let alertController: UIAlertController
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController = UIAlertController(title: "카테고리 설정하기", message: "해당 학습지의 카테고리를 설정해주세요", preferredStyle: .alert)
        } else {
            alertController = UIAlertController(title: "카테고리 설정하기", message: "해당 학습지의 카테고리를 설정해주세요", preferredStyle: .actionSheet)
        }
        
        for category in existingCategories {
            let action = UIAlertAction(title: category, style: .default) { [weak self] _ in
                self?.saveDocument(sheetName: sheetName, category: category)
            }
            alertController.addAction(action)
        }
        
        if existingCategories.count < 9 {
            let newCategoryAction = UIAlertAction(title: "새 카테고리 만들기", style: .default) { [weak self] _ in
                self?.showNewCategoryAlert(sheetName: sheetName)
            }
            alertController.addAction(newCategoryAction)
        } else {
            let newCategoryAction = UIAlertAction(title: "새 카테고리 만들기", style: .default) { [weak self] _ in
                self?.showCanNotAddCategoryToast(message: "카테고리는 최대 9개만 만들 수 있습니다.")
            }
            alertController.addAction(newCategoryAction)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            self?.showNameAlert(fileName: sheetName, previousName: sheetName)
        }
        alertController.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self
                popoverController.sourceRect = CGRect(x: self.bounds.midX, y: self.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        presentAlert(alertController)
    }
    
    private func showNewCategoryAlert(sheetName: String) {
        let alertController = UIAlertController(title: "새 카테고리", message: "새로운 카테고리 이름을 입력해주세요", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "카테고리 이름"
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
        }
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let category = alertController.textFields?.first?.text, !category.isEmpty else { return }
            self?.saveDocument(sheetName: sheetName, category: category)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            self?.showCategoryAlert(sheetName: sheetName)
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        presentAlert(alertController)
    }
    
    private func presentAlert(_ alertController: UIAlertController) {
        if let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first?.rootViewController
        {
            // 현재 표시된 뷰 컨트롤러를 찾습니다.
            var currentViewController = rootViewController
            while let presentedViewController = currentViewController.presentedViewController {
                currentViewController = presentedViewController
            }
            
            // 찾은 뷰 컨트롤러에서 알림을 표시합니다.
            currentViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func saveDocument(sheetName: String, category: String) {
        print("sheetName: \(sheetName), category: \(category), extractedText: \(extractedText)")
        
        delegate?.didCreateWorksheet(name: sheetName, category: category, content: extractedText)
        
        // UI 상태 변경
        isMasked.toggle()
        delegate?.didTapPlusButton(isMasked: isMasked)
        deRotatePlusButton()
        toggleSubButtons()
    }
    
    @objc private func backButtonTapped() {
        delegate?.didTapBackButton()
    }
    
    @objc private func searchButtonTapped() {
        print("searchButtonTapped")
        isExpanded.toggle()
        
        if isExpanded {
            animateSearchBar()
        }
    }
    
    @objc private func plusButtonTapped() {
        if isExpanded {
            hideSearchBar()
            searchBar.searchTextField.text = ""
            isExpanded.toggle()
        } else {
            isMasked.toggle() // 여기서 isMasked 상태를 변경
            delegate?.didTapPlusButton(isMasked: isMasked)
            if isMasked {
                rotatePlusButton()
            } else {
                deRotatePlusButton()
            }
            toggleSubButtons() // 서브 버튼을 토글
        }
    }
    
    @objc private func createWorksheet() {
        print("Worksheet")
        presentDocumentPicker(for: "Worksheet")
    }
    
    @objc private func createTestsheet() {
        print("Testsheet")
        let workDocuments = documents.filter { $0.fileType == "빈칸학습지" }
        delegate?.didTapWorksheetButton(with: workDocuments)
        isMasked.toggle()
        delegate?.didTapPlusButton(isMasked: isMasked)
        deRotatePlusButton()
        toggleSubButtons()
    }
    
    // 카테고리 설정
    private func getExistingCategories() -> [String] {
        return Array(Set(documents.map { $0.category })).sorted()
    }
    
    private func showCanNotAddCategoryToast(message: String) {
        let window: UIWindow?
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let firstWindow = windowScene.windows.first else { return }
            window = firstWindow
        } else {
            window = UIApplication.shared.windows.first
        }
        
        guard let window = window else { return }
        
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let toastWidth: CGFloat = 250
        let toastHeight: CGFloat = 35
        toastLabel.frame = CGRect(x: window.frame.size.width/2 - toastWidth/2,
                                  y: window.frame.size.height - 100,
                                  width: toastWidth, height: toastHeight)
        
        window.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    // TODO: 검색창 추가기능
    private let searchResultsTableView = UITableView()
    private var searchResults: [Document] = []
    private var tapGesture: UITapGestureRecognizer!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        superview?.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if !searchBar.frame.contains(location) && !searchResultsTableView.frame.contains(location) {
            searchBar.resignFirstResponder()
            searchResultsTableView.isHidden = true
        }
    }
    
    private func setupSearchResultsTableView() {
        insertSubview(searchResultsTableView, belowSubview: searchBar)
        searchResultsTableView.isUserInteractionEnabled = true
        searchResultsTableView.isHidden = true
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        searchResultsTableView.backgroundColor = .white
        searchResultsTableView.layer.cornerRadius = 22
        searchResultsTableView.layer.masksToBounds = true
        
        // 테두리 제거
        searchResultsTableView.layer.borderWidth = 0
        
        // 셀 사이의 구분선 제거
        searchResultsTableView.separatorStyle = .none
        
        // 테이블 뷰 헤더 높이 설정
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: searchResultsTableView.frame.width, height: 40))
        headerView.backgroundColor = MemorableColor.White
        searchResultsTableView.tableHeaderView = headerView
        
        searchResultsTableView.snp.makeConstraints { make in
            
            make.top.equalTo(searchBar.snp.centerY).offset(-15) // searchBar의 중간부터 시작
            make.leading.trailing.equalTo(searchBar)
            make.height.equalTo(310)
        }
    }
    
    private func updateSearchResults(with text: String) {
        searchResults = documents.filter { document in
            document.name.lowercased().contains(text.lowercased()) ||
            document.category.lowercased().contains(text.lowercased())
        }
        searchResultsTableView.reloadData()
        searchResultsTableView.isHidden = searchResults.isEmpty
    }
    // TODO: 검색창 추가기능
}

extension HeaderComponent: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        let fileName = selectedURL.lastPathComponent
        let fileType = selectedURL.pathExtension.lowercased()
        
        handleDocument(url: selectedURL, fileName: fileName, fileType: fileType)
    }
}

extension HeaderComponent: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button clicked")
        var searchText = searchBar.text ?? ""
        searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredDocuments = documents.filter { document in
            searchText.isEmpty || document.name.contains(searchText) || document.fileType.contains(searchText)
        }
        
        delegate?.didSearchDocuments(with: filteredDocuments, searchText: searchText)
        searchBar.resignFirstResponder() // 키보드 숨기기
    }
    
    // MARK: SearchBar 추가 기능
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(with: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchResultsTableView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchResultsTableView.isHidden = true
    }
    // MARK: SearchBar 추가 기능
    
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// MARK: SearchBar 추가 기능
extension HeaderComponent: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let document = searchResults[indexPath.row]
        cell.textLabel?.text = "\(document.name) - \(document.fileType)"
        cell.textLabel?.textColor = MemorableColor.Gray1
        cell.textLabel?.font = MemorableFont.Body1()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hi")
        tableView.deselectRow(at: indexPath, animated: true)
        
        let document = searchResults[indexPath.row]
        
        switch document.fileType {
        case "빈칸학습지":
            if let worksheet = document as? Worksheet {
                APIManager.shared.getData(to: "/api/worksheet/ws/\(worksheet.id)") { (sheetDetail: WorksheetDetail?, error: Error?) in
                    
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error fetching data: \(error)")
                            return
                        }
                        
                        guard let detail = sheetDetail else {
                            print("No data received")
                            return
                        }
                        
                        let workSheetVC = WorkSheetViewController()
                        WorkSheetManager.shared.worksheetDetail = detail
                        self.navigateToViewController(workSheetVC)
                    }
                }
            }
        case "나만의 시험지":
            if let testsheet = document as? Testsheet {
                APIManagere.shared.getTestsheet(testsheetId: testsheet.id) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let testsheetDetail):
                            let testSheetVC = TestSheetViewController()
                            testSheetVC.testsheetDetail = testsheetDetail
                            self.navigateToViewController(testSheetVC)
                        case .failure(let error):
                            print("Error fetching testsheet detail: \(error)")
                        }
                    }
                }
            }
        case "오답노트":
            // TODO: API 검증해야함.
            APIManager.shared.getData(to: "/api/wrongsheet/\(document.id)") { (sheetDetail: WrongsheetDetail?, error: Error?) in
                DispatchQueue.main.async {
                    // 3. 받아온 데이터 처리
                    if let error = error {
                        print("Error fetching data: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let detail = sheetDetail else {
                        print("No data received")
                        return
                    }
                    
                    // wrong sheet detail
                    print("GET: \(detail.name)")
                    print("GET: \(detail.category)")
                    print("GET: \(detail.questions)")
                    
                    let wrongSheetVC = WrongSheetViewController()
                    wrongSheetVC.wrongsheetDetail = detail
                    self.navigateToViewController(wrongSheetVC)
                }
            }
        default:
            print("Unknown file type")
        }
    }
    private func navigateToViewController(_ viewController: UIViewController) {
        if let navigationController = window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else if let presentingViewController = window?.rootViewController {
            presentingViewController.present(viewController, animated: true, completion: nil)
        }
    }
}
