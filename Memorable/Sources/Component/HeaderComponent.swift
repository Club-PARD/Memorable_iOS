//
//  SearchBarComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/25/24.
//

import UIKit
import SnapKit
import UniformTypeIdentifiers

protocol HeaderComponentDelegate: AnyObject {
    func didTapPlusButton(isMasked: Bool)
}

class HeaderComponent: UIView {
    
    weak var delegate: HeaderComponentDelegate?
    
    private let appLogoImageView = UIImageView()
    private let searchBar = UISearchBar()
    private let searchButton = UIButton()
    private let searchButtonOverlayView = UIView()
    private let plusButton = UIButton()
    private let plusButtonImageView = UIImageView()
    private let subButtonsContainer = UIView()
    private let subButton1 = UIButton()
    private let subButton2 = UIButton()
    
    private var isExpanded = false
    private var isMasked = false
    private var searchTrailing: CGFloat = -124
    private var uploadedFileName = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        setupAppLogoImageView()
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
            make.width.equalTo(174)
            make.height.equalTo(21.92)
        }
        appLogoImageView.image = UIImage(named: "applogo2")
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
        plusButton.backgroundColor = .cyan
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
        searchButton.backgroundColor = .black
        searchButton.layer.cornerRadius = 22
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    private func setupOverlayViews() {
        searchButtonOverlayView.backgroundColor = .black
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
        searchBar.barTintColor = .black
        searchBar.backgroundImage = UIImage()
        searchBar.layer.cornerRadius = 22
        searchBar.layer.masksToBounds = true
        if let searchIcon = UIImage(named: "btnSearch-gray")?.resized(to: CGSize(width: 24, height: 24)) {
            searchBar.setImage(searchIcon, for: UISearchBar.Icon.search, state: .normal)
        }
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .black
            textField.textColor = .black
            textField.layer.cornerRadius = 22
            textField.clipsToBounds = true
            textField.font = UIFont.systemFont(ofSize: 16)
        }
    }
    
    @objc private func searchButtonTapped() {
        isExpanded.toggle()
        
        if isExpanded {
            animateSearchBar()
        }
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
            $0.backgroundColor = .white
            $0.setTitleColor(.black, for: .normal)
            $0.layer.cornerRadius = 22
            $0.alpha = 0
        }
        
        subButton1.setTitle("빈칸학습지 생성하기", for: .normal)
        subButton2.setTitle("시험지 생성하기", for: .normal)
        
        subButton1.addTarget(self, action: #selector(createWorksheet), for: .touchUpInside)
        
        subButton2.addTarget(self, action: #selector(createTestsheet), for: .touchUpInside)
    }
    
    @objc private func plusButtonTapped() {
        if isExpanded {
            hideSearchBar()
            isExpanded.toggle()
        } else {
            isMasked.toggle() // 여기서 isMasked 상태를 변경합니다.
            delegate?.didTapPlusButton(isMasked: isMasked)
            if isMasked {
                rotatePlusButton()
            } else {
                deRotatePlusButton()
            }
            toggleSubButtons() // 서브 버튼을 토글합니다.
        }
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
            self.searchBar.backgroundColor = .white
            self.searchBar.searchTextField.backgroundColor = .white
            self.searchButton.backgroundColor = .white
            
            // Show search bar
            self.searchBar.alpha = 1
            
            // Change plus button to cancel button
            self.plusButtonImageView.isHidden = true
            self.plusButton.setTitle("취소", for: .normal)
            self.plusButton.backgroundColor = .gray
            
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
            self.searchBar.backgroundColor = .black
            self.searchBar.searchTextField.backgroundColor = .black
            self.searchButton.backgroundColor = .black
            
            // Hide search bar
            self.searchBar.alpha = 0
            
            // Change cancel button back to plus button
            self.plusButtonImageView.isHidden = false
            self.plusButton.setTitle(nil, for: .normal)
            self.plusButton.backgroundColor = .cyan
            
            self.layoutIfNeeded()
        })
    }
    
    private func rotatePlusButton() {
        UIView.animate(withDuration: 0.3) {
            self.plusButton.backgroundColor = .black
            self.plusButtonImageView.transform = CGAffineTransform(rotationAngle: .pi / 4)
            self.searchButtonOverlayView.alpha = 0.5
        }
        self.searchButton.isEnabled.toggle()
    }
    
    private func deRotatePlusButton() {
        UIView.animate(withDuration: 0.3) {
            self.plusButton.backgroundColor = .cyan
            self.plusButtonImageView.transform = CGAffineTransform(rotationAngle: -.pi / 4)
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
    
    @objc private func createWorksheet() {
        print("Worksheet")
        presentDocumentPicker(for: "Worksheet")
    }
    
    @objc private func createTestsheet() {
        print("Testsheet")
        presentDocumentPicker(for: "Testsheet")
    }
    
    private func presentDocumentPicker(for fileType: String) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.image], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .formSheet
        documentPicker.view.tintColor = .black // Customize tint color if needed
        
        if let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    private func handleDocument(url: URL, fileName: String, fileType: String) {
        let alertController = UIAlertController(title: "File Upload", message: "Enter the category for this \(fileType): \(fileName)", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Category"
        }
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            guard let category = alertController.textFields?.first?.text else { return }
            // 파일과 카테고리 처리를 진행합니다.
            self?.saveFile(fileName: fileName, category: category)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        // Use UIWindowScene.windows.first?.rootViewController to present alert
        if let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func saveFile(fileName: String, category: String) {
        // 파일 저장 및 카테고리 설정 로직을 추가합니다.
        // 예를 들어, 파일을 저장하고, UI를 업데이트하는 코드를 작성합니다.
        // 이 예시에서는 저장된 파일 이름을 업데이트하도록 하겠습니다.
        self.uploadedFileName = fileName // Ensure 'self' is used to access instance property
        self.plusButton.setTitle(self.uploadedFileName, for: .normal)
        // 다른 UI 업데이트 로직을 추가할 수 있습니다.
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

