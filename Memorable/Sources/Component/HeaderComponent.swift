//
//  SearchBarComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/25/24.
//

import UIKit
import SnapKit
import PDFKit
import Vision
import UniformTypeIdentifiers

protocol HeaderComponentDelegate: AnyObject {
    func didTapBackButton()
    func didTapPlusButton(isMasked: Bool)
    func didTapWorksheetButton(with documents: [Document])
    func didTapTestsheetButton(with documents: [Document])
    func didSearchDocuments(with documents: [Document], searchText: String)
}

class HeaderComponent: UIView {
    
    weak var delegate: HeaderComponentDelegate?
    
    private let appLogoImageView = UIImageView()
    private let backButton = UIButton()
    private let searchBar = UISearchBar()
    private let searchButton = UIButton()
    private let searchButtonOverlayView = UIView()
    private let plusButton = UIButton()
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
        if !self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01 {
            return nil
        }
        
        if self.subButtonsContainer.point(inside: self.convert(point, to: self.subButtonsContainer), with: event) {
            return self.subButtonsContainer.hitTest(self.convert(point, to: self.subButtonsContainer), with: event)
        }
        
        return super.hitTest(point, with: event)
    }
    
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
    }
    
    private func setupAppLogoImageView() {
        addSubview(appLogoImageView)
        appLogoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
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
        
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(appLogoImageView.snp.trailing).offset(45)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    func showBackButton(_ show: Bool) {
        backButton.isHidden = !show
    }
    
    private func setupPlusButton() {
        addSubview(plusButton)
        plusButton.addSubview(plusButtonImageView)
        
        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
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
            make.trailing.equalTo(plusButton.snp.leading).offset(-20)
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
    }
    
    private func setupSearchBar() {
        addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-124)
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
        
        [subButton1, subButton2].forEach {
            $0.backgroundColor = MemorableColor.White
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = MemorableFont.Body1()
            $0.layer.cornerRadius = 22
            $0.alpha = 0
            $0.isUserInteractionEnabled = true
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
            self.searchBar.snp.updateConstraints { make in
                make.width.equalTo(850)
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
        }
        self.searchButton.isEnabled.toggle()
    }
    
    private func deRotatePlusButton() {
        UIView.animate(withDuration: 0.3) {
            self.plusButton.backgroundColor = MemorableColor.Blue2
            self.plusButtonImageView.transform = CGAffineTransform.identity
            self.searchButtonOverlayView.alpha = 0
        }
        self.searchButton.isEnabled.toggle()
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
            .first?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    private func handleDocument(url: URL, fileName: String, fileType: String) {
        if fileType == "PDF" {
            pdfDocument = PDFDocument(url: url)
            extractTextFromPDF { [weak self] in
                self?.showNameAlert(fileName: fileName, previousName: "")
            }
        } else if ["jpg", "jpeg", "png"].contains(fileType.lowercased()) {
            if let image = UIImage(contentsOfFile: url.path) {
                extractTextFromImage(image: image) { [weak self] in
                    self?.showNameAlert(fileName: fileName, previousName: "")
                }
            }
        }
    }
    
    private func extractTextFromPDF(completion: @escaping () -> Void) {
        guard let pdfDocument = pdfDocument else {
            print("No PDF to extract text from")
            completion()
            return
        }
        
        extractedText = ""
        let dispatchGroup = DispatchGroup()
        
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex) {
                if let pageText = page.string {
                    extractedText += pageText
                }
                
                let pageImage = page.thumbnail(of: page.bounds(for: .mediaBox).size, for: .mediaBox)
                dispatchGroup.enter()
                recognizeTextInImage(image: pageImage) { recognizedText in
                    self.extractedText += recognizedText
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func extractTextFromImage(image: UIImage, completion: @escaping () -> Void) {
        recognizeTextInImage(image: image) { recognizedText in
            self.extractedText = recognizedText
            completion()
        }
    }
    
    private func recognizeTextInImage(image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
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
        let categoryAlertController = UIAlertController(title: "카테고리 설정하기", message: "학습지의 카테고리를 설정해 주세요", preferredStyle: .alert)
        categoryAlertController.addTextField { textField in
            textField.placeholder = "카테고리"
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
        }
        let categoryConfirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let category = categoryAlertController.textFields?.first?.text, !category.isEmpty else { return }
            self?.saveDocument(sheetName: sheetName, category: category)
        }
        let categoryCancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            self?.showNameAlert(fileName: sheetName, previousName: sheetName)
        }
        
        categoryAlertController.addAction(categoryConfirmAction)
        categoryAlertController.addAction(categoryCancelAction)
        
        presentAlert(categoryAlertController)
    }
    
    private func presentAlert(_ alertController: UIAlertController) {
        if let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func saveDocument(sheetName: String, category: String) {
        print("sheetName: \(sheetName), category: \(category), extractedText: \(extractedText)")
        
        //TODO: 클백작업해야함
        
        // 원래 홈뷰로 이동
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
}

extension HeaderComponent: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            print("No URL selected")
            return
        }
        
        let fileExtension = url.pathExtension.lowercased()
        if fileExtension == "pdf" {
            // Handle PDF document
            handleDocument(url: url, fileName: url.lastPathComponent, fileType: "PDF")
        } else if ["jpg", "jpeg", "png"].contains(fileExtension) {
            // Handle image document
            handleDocument(url: url, fileName: url.lastPathComponent, fileType: "Image")
        } else {
            print("Selected file is not supported (PDF, JPG, JPEG, PNG)")
        }
    }
}

extension HeaderComponent: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button clicked")
        var searchText = searchBar.text ?? ""
        searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredDocuments = documents.filter { document in
            searchText.isEmpty || document.fileName.contains(searchText) || document.fileType.contains(searchText)
        }
        
        delegate?.didSearchDocuments(with: filteredDocuments, searchText: searchText)
        searchBar.resignFirstResponder() // 키보드 숨기기
    }
}



