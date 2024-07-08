//
//  SearchView.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/30/24.
//

import UIKit
import SnapKit

protocol SearchedSheetViewDelegate: AnyObject {
    func didUpdateBookmark(for document: Document)
}

class SearchedSheetView: UIView {
    weak var delegate:SearchedSheetViewDelegate?
    let tableView: UITableView
    private let filterButtonsView = UIStackView()
    private var currentFilterButton = UIButton() // MARK: 즐겨찾기 수정
    private let allFilterButton = UIButton(type: .system)
    private let worksheetFilterButton = UIButton(type: .system)
    private let testsheetFilterButton = UIButton(type: .system)
    private let wrongsheetFilterButton = UIButton(type: .system)
    
    private var allDocuments: [Document] = []
    private var filteredDocuments: [Document] = []

    override init(frame: CGRect) {
        tableView = UITableView()
        
        super.init(frame: frame)
        currentFilterButton = allFilterButton // MARK: 즐겨찾기 수정
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = MemorableColor.White
        self.layer.cornerRadius = 40
        self.layer.masksToBounds = true
        
        tableView.register(RecentsheetCell.self, forCellReuseIdentifier: "RecentsheetCell")
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        
        addSubview(filterButtonsView)
        addSubview(tableView)
        
        setupFilterButtons()
    }
    
    private func setupFilterButtons() {
        filterButtonsView.axis = .horizontal
        filterButtonsView.spacing = 8
        filterButtonsView.alignment = .center
        filterButtonsView.distribution = .fill
        
        configureButton(allFilterButton, title: "전체보기")
        configureButton(worksheetFilterButton, title: "빈칸 학습지", imageName: "bookmark-blue")
        configureButton(testsheetFilterButton, title: "나만의 시험지", imageName: "bookmark-yellow")
        configureButton(wrongsheetFilterButton, title: "오답노트", imageName: "bookmark-gray-v2")
        
        filterButtonsView.addArrangedSubview(allFilterButton)
        filterButtonsView.addArrangedSubview(worksheetFilterButton)
        filterButtonsView.addArrangedSubview(testsheetFilterButton)
        filterButtonsView.addArrangedSubview(wrongsheetFilterButton)
        
        allFilterButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        worksheetFilterButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        testsheetFilterButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        wrongsheetFilterButton.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        
        // 초기 상태 설정
        updateButtonState(allFilterButton, isSelected: true)
    }
    
    private func configureButton(_ button: UIButton, title: String, imageName: String? = nil) {
        var config = UIButton.Configuration.filled()
        config.title = title
        
        // 폰트 크기 설정 및 라인 제한
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = MemorableFont.BodyCaption()
            return outgoing
        }
        
        // 타이틀을 한 줄로 제한
        config.titleLineBreakMode = .byTruncatingTail
        config.titleAlignment = .center
        
        if let imageName = imageName, let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal) {
            let resizedImage = image.resized(to: CGSize(width: 16, height: 16))
            config.image = resizedImage
            config.imagePlacement = .leading
            config.imagePadding = 8
        }
        
        config.cornerStyle = .capsule
        
        // 기본 상태 (선택되지 않은 상태)
        config.baseForegroundColor = .gray
        config.baseBackgroundColor = .lightGray
        
        // 콘텐츠 패딩 설정
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        button.configuration = config
        
        // 버튼 크기 설정
        button.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.greaterThanOrEqualTo(80)
        }
    }
    
    private func setupConstraints() {
        
        filterButtonsView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
            make.height.equalTo(30)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterButtonsView.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setDocuments(documents: [Document]) {
        // 모든 문서 결합 후, 날짜를 기준으로 내림차순 정렬
        allDocuments = documents.sorted(by: { $0.createdDate > $1.createdDate })
        filteredDocuments = allDocuments
        tableView.reloadData()
        
        updateButtonState(currentFilterButton, isSelected: true)
        updateCurrentDocuments()
    }

    @objc private func filterButtonTapped(_ sender: UIButton) {
        updateButtonState(sender, isSelected: true)
        currentFilterButton = sender
        updateCurrentDocuments()
    }
    
    private func updateCurrentDocuments() {
        switch currentFilterButton {
        case allFilterButton:
            filteredDocuments = allDocuments
        case worksheetFilterButton:
            filteredDocuments = allDocuments.filter { $0.fileType == "빈칸학습지" }
        case testsheetFilterButton:
            filteredDocuments = allDocuments.filter { $0.fileType == "나만의 시험지" }
        case wrongsheetFilterButton:
            filteredDocuments = allDocuments.filter { $0.fileType == "오답노트" }
        default:
            break
        }
        tableView.reloadData()
    }
    
    private func updateButtonState(_ selectedButton: UIButton, isSelected: Bool) {
        [allFilterButton, worksheetFilterButton, testsheetFilterButton, wrongsheetFilterButton].forEach { button in
            var config = button.configuration
            if button == selectedButton && isSelected {
                config?.baseForegroundColor = MemorableColor.White
                config?.baseBackgroundColor = MemorableColor.Black
            } else {
                config?.baseForegroundColor = MemorableColor.Gray1
                config?.baseBackgroundColor = MemorableColor.Gray5
            }
            button.configuration = config
        }
    }
    
    func resetFilterButtonState() {
        allFilterButton.configuration?.baseBackgroundColor = MemorableColor.Black
        allFilterButton.configuration?.baseForegroundColor = MemorableColor.White
        worksheetFilterButton.configuration?.baseBackgroundColor = MemorableColor.Gray5
        worksheetFilterButton.configuration?.baseForegroundColor = MemorableColor.Gray1
        testsheetFilterButton.configuration?.baseBackgroundColor = MemorableColor.Gray5
        testsheetFilterButton.configuration?.baseForegroundColor = MemorableColor.Gray1
        wrongsheetFilterButton.configuration?.baseBackgroundColor = MemorableColor.Gray5
        wrongsheetFilterButton.configuration?.baseForegroundColor = MemorableColor.Gray1
    }
}

extension SearchedSheetView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDocuments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentsheetCell", for: indexPath) as! RecentsheetCell
        let document = filteredDocuments[indexPath.row]
        cell.configure(with: document)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    // 라우팅
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let document = filteredDocuments[indexPath.row]
        
        switch document.fileType {
        case "빈칸학습지":
            if let worksheet = document as? Worksheet {
                // Fetch WorksheetDetail before navigating
                APIManagere.shared.getWorksheet(worksheetId: worksheet.id) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let worksheetDetail):
                            let workSheetVC = WorkSheetViewController()
                            workSheetVC.worksheetDetail = worksheetDetail
                            self.navigateToViewController(workSheetVC)
                        case .failure(let error):
                            print("Error fetching worksheet detail: \(error)")
                            // Handle error (e.g., show an alert to the user)
                        }
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
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else if let presentingViewController = self.window?.rootViewController {
            presentingViewController.present(viewController, animated: true, completion: nil)
        }
    }
}

extension SearchedSheetView: RecentsheetCellDelegate {
    func didTapBookmark<T: Document>(for document: T) {
        if let index = allDocuments.firstIndex(where: { $0.id == document.id }) {
            allDocuments[index] = document
        }
        tableView.reloadData()
        // 현재 필터를 적용하여 currentDocuments 업데이트
        updateCurrentDocuments()
        delegate?.didUpdateBookmark(for: document)
    }
}
