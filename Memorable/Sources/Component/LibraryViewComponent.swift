//
//  LibraryViewComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/26/24.
//

import SnapKit
import UIKit

protocol LibraryViewComponentDelegate: AnyObject {
    func didTapWorksheetButton(with documents: [Document])
    func didTapTestsheetButton(with documents: [Document])
    func didTapWrongsheetButton(with documents: [Document])
    func didTapRecentButton()
    func didUpdateBookmark(for document: Document)
    func refreshLibraryView()
}

class LibraryViewComponent: UIView {
    weak var delegate: LibraryViewComponentDelegate?
    var recentWorksheetName: String?
    
    private let scrollView: UIScrollView
    private let contentView: UIView
    var titleLabel: UILabel
    private let recentView: UIView
    private let recentLabel: UILabel
    private let recentButton: UIButton
    private let sheetLabel: UILabel
    private let worksheetButton: UIButton
    private let testsheetButton: UIButton
    private let wrongsheetButton: UIButton
    private let recentsheetLabel: UILabel
    private let recentsheetView: UIView
    
    private var worksheetDocuments: [Document] = []
    private var testsheetDocuments: [Document] = []
    private var wrongsheetDocuments: [Document] = []
    private var currentDocuments: [Document] = []
    
    private var filterButtonsView = UIStackView()
    private var currentFilterButton = UIButton() // MARK: 즐겨찾기 수정
    private let allFilterButton = UIButton(type: .system)
    private let worksheetFilterButton = UIButton(type: .system)
    private let testsheetFilterButton = UIButton(type: .system)
    private let wrongsheetFilterButton = UIButton(type: .system)
    lazy var recentTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RecentsheetCell.self, forCellReuseIdentifier: "RecentsheetCell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override init(frame: CGRect) {
        scrollView = UIScrollView()
        contentView = UIView()
        titleLabel = UILabel()
        recentView = UIView()
        recentLabel = UILabel()
        recentButton = UIButton()
        sheetLabel = UILabel()
        worksheetButton = UIButton()
        testsheetButton = UIButton()
        wrongsheetButton = UIButton()
        recentsheetLabel = UILabel()
        recentsheetView = UIView()
        
        super.init(frame: frame)
        currentFilterButton = allFilterButton // MARK: 즐겨찾기 수정
        setupViews()
        setupConstraints()
        configureRefreshControl()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureRefreshControl() {
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        delegate?.refreshLibraryView()
        
        DispatchQueue.main.async {
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    private func setupViews() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(recentView)
        contentView.addSubview(sheetLabel)
        contentView.addSubview(worksheetButton)
        contentView.addSubview(testsheetButton)
        contentView.addSubview(wrongsheetButton)
        contentView.addSubview(recentsheetLabel)
        
        for item in [worksheetButton, testsheetButton, wrongsheetButton] {
            item.backgroundColor = MemorableColor.White
            item.layer.cornerRadius = 40
            item.layer.masksToBounds = true
        }
        
        setupRecentView()
        
        setupLabels()
        setupButtons()
        
        setupRecentsheetView()
        setupFilterButtons()
        setupGradientView()
    }
    
    private func setupRecentView() {
        recentView.backgroundColor = MemorableColor.Black
        recentView.layer.cornerRadius = 46
        recentView.clipsToBounds = true
        
        let backgroundImageView = UIImageView(image: UIImage(named: "recentview-background"))
        backgroundImageView.contentMode = .scaleAspectFill
        recentView.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let fullText = "가장 최근에 학습한\n\(recentWorksheetName ?? "Unknown") 학습지로 바로 이동할까요?"
        let coloredText = recentWorksheetName ?? "Unknown"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // 전체 텍스트를 흰색으로 설정
        attributedString.addAttribute(.foregroundColor, value: MemorableColor.White ?? .white, range: NSRange(location: 0, length: fullText.count))
        
        // coloredText 부분만 파란색으로 설정
        let range = (fullText as NSString).range(of: coloredText)
        attributedString.addAttribute(.foregroundColor, value: MemorableColor.Blue2 ?? .blue, range: range)
        
        recentLabel.font = MemorableFont.Body2()
        recentLabel.attributedText = attributedString
        recentLabel.numberOfLines = 0
        
        var recentButtonConfig = UIButton.Configuration.filled()
        recentButtonConfig.title = "시작하기"
        if let image = UIImage(systemName: "chevron.right")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)) {
            recentButtonConfig.image = image
        }
        recentButtonConfig.baseForegroundColor = MemorableColor.White
        recentButtonConfig.baseBackgroundColor = MemorableColor.Blue2
        recentButtonConfig.imagePadding = 4
        recentButtonConfig.cornerStyle = .capsule
        recentButtonConfig.imagePlacement = .trailing
        // Attributed title 설정
        let titleFont = MemorableFont.Button() // 원하는 폰트와 사이즈 설정
        let titleColor = MemorableColor.White // 원하는 색상 설정
        let attributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: titleColor ?? .white
        ]
        let attributedTitle = NSAttributedString(string: "시작하기", attributes: attributes)
        // NSAttributedString을 AttributedString으로 변환
        if let attributedTitle = try? AttributedString(attributedTitle) {
            recentButtonConfig.attributedTitle = attributedTitle
        }
        
        recentButton.configuration = recentButtonConfig
        
        recentView.addSubview(recentLabel)
        recentView.addSubview(recentButton)
    
        // TODO: API 연결중
        recentButton.addTarget(self, action: #selector(recentButtonTapped), for: .touchUpInside)
    }
    
    func updateRecentView() {
        let fullText = "가장 최근에 학습한\n\(recentWorksheetName ?? "Unknown") 학습지로 바로 이동할까요?"
        let coloredText = recentWorksheetName ?? "Unknown"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // 전체 텍스트를 흰색으로 설정
        attributedString.addAttribute(.foregroundColor, value: MemorableColor.White ?? .white, range: NSRange(location: 0, length: fullText.count))
        
        // coloredText 부분만 파란색으로 설정
        let range = (fullText as NSString).range(of: coloredText)
        attributedString.addAttribute(.foregroundColor, value: MemorableColor.Blue2 ?? .blue, range: range)
        
        recentLabel.attributedText = attributedString
    }
    
    @objc private func recentButtonTapped() {
        delegate?.didTapRecentButton()
    }
    
    // TODO: API 연결중 이까지
    
    private func setupLabels() {
        // titleLabel
        titleLabel.numberOfLines = 0
        titleLabel.text = "사용자님,\n오늘도 함께 학습해볼까요?"
        titleLabel.font = MemorableFont.LargeTitle()
        titleLabel.textColor = MemorableColor.Black
        
        // sheetLabel
        sheetLabel.text = "학습하기"
        sheetLabel.font = MemorableFont.Title()
        sheetLabel.textColor = MemorableColor.Black
        
        recentsheetLabel.text = "최근 본 파일"
        recentsheetLabel.font = MemorableFont.Title()
        recentsheetLabel.textColor = MemorableColor.Black
    }
    
    private func setupButtons() {
        // worksheetButton
        worksheetButton.backgroundColor = MemorableColor.White
        worksheetButton.layer.cornerRadius = 40
        worksheetButton.layer.masksToBounds = true
        
        let worksheetButtonImage: UIImageView
        if let image = UIImage(named: "btnWorksheet") {
            worksheetButtonImage = UIImageView(image: image)
            worksheetButton.addSubview(worksheetButtonImage)
            worksheetButtonImage.snp.makeConstraints { make in
                make.width.height.equalTo(60)
                make.top.leading.equalToSuperview().offset(24)
            }
        }
        
        let worksheetButtonLabel2 = createLabel(text: "AI가 자료에서 중요한 단어를 추출하여\n자동으로 빈칸을 생성해줘요📚", font: MemorableFont.BodyCaption(), color: MemorableColor.Gray1 ?? .lightGray)
        worksheetButtonLabel2.numberOfLines = 0
        worksheetButton.addSubview(worksheetButtonLabel2)
        worksheetButtonLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        let worksheetButtonLabel1 = createLabel(text: "빈칸학습지", font: MemorableFont.LargeTitle(), color: MemorableColor.Black ?? .black)
        worksheetButton.addSubview(worksheetButtonLabel1)
        worksheetButtonLabel1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalTo(worksheetButtonLabel2.snp.top).offset(-4)
        }
        
        // testsheetButton
        testsheetButton.backgroundColor = MemorableColor.White
        testsheetButton.layer.cornerRadius = 40
        testsheetButton.layer.masksToBounds = true
        
        let testsheetButtonImage: UIImageView
        if let image = UIImage(named: "btnTestsheet") { // 이미지 이름 변경에 주의
            testsheetButtonImage = UIImageView(image: image)
            testsheetButton.addSubview(testsheetButtonImage)
            testsheetButtonImage.snp.makeConstraints { make in
                make.width.height.equalTo(60)
                make.top.leading.equalToSuperview().offset(24)
            }
        }
        
        let testsheetButtonLabel2 = createLabel(text: "빈칸 학습지로 학습 후 맞춤형 시험지로\n시험을 칠 수 있어요📝", font: MemorableFont.BodyCaption(), color: MemorableColor.Gray1 ?? .lightGray)
        testsheetButtonLabel2.numberOfLines = 0
        testsheetButtonLabel2.font = MemorableFont.BodyCaption()
        testsheetButton.addSubview(testsheetButtonLabel2)
        testsheetButtonLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        let testsheetButtonLabel1 = createLabel(text: "나만의 시험지", font: MemorableFont.LargeTitle(), color: MemorableColor.Black ?? .black)
        testsheetButton.addSubview(testsheetButtonLabel1)
        testsheetButtonLabel1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalTo(testsheetButtonLabel2.snp.top).offset(-4)
        }
        
        // wrongsheetButton
        wrongsheetButton.backgroundColor = .white
        wrongsheetButton.layer.cornerRadius = 40
        wrongsheetButton.layer.masksToBounds = true
        
        let wrongsheetButtonImage: UIImageView
        if let image = UIImage(named: "btnWrongsheet") { // 이미지 이름 변경에 주의
            wrongsheetButtonImage = UIImageView(image: image)
            wrongsheetButton.addSubview(wrongsheetButtonImage)
            wrongsheetButtonImage.snp.makeConstraints { make in
                make.width.height.equalTo(60)
                make.top.leading.equalToSuperview().offset(24)
            }
        }
        
        let wrongsheetButtonLabel2 = createLabel(text: "오답노트로 틀린 문제만 모아서\n시험 직전에 볼 수 있어요🖍", font: MemorableFont.BodyCaption(), color: MemorableColor.Gray1 ?? .lightGray)
        wrongsheetButtonLabel2.numberOfLines = 0
        
        wrongsheetButton.addSubview(wrongsheetButtonLabel2)
        wrongsheetButtonLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        let wrongsheetButtonLabel1 = createLabel(text: "오답노트", font: MemorableFont.LargeTitle(), color: MemorableColor.Black ?? .black)
        wrongsheetButton.addSubview(wrongsheetButtonLabel1)
        wrongsheetButtonLabel1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalTo(wrongsheetButtonLabel2.snp.top).offset(-4)
        }
        
        worksheetButton.addTarget(self, action: #selector(worksheetButtonTapped), for: .touchUpInside)
        
        testsheetButton.addTarget(self, action: #selector(testsheetButtonTapped), for: .touchUpInside)
        wrongsheetButton.addTarget(self, action: #selector(wrongsheetButtonTapped), for: .touchUpInside)
    }
    
    private func createLabel(text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        return label
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.greaterThanOrEqualTo(scrollView.snp.height).offset(400) // Ensure contentView is taller than scrollView
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(19)
            make.leading.equalToSuperview().offset(16)
        }
        
        recentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(92)
        }
        
        recentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(28)
            make.centerY.equalToSuperview()
        }
        
        recentButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(220)
            make.height.equalTo(68)
        }
        
        sheetLabel.snp.makeConstraints { make in
            make.top.equalTo(recentView.snp.bottom).offset(44)
            make.leading.equalToSuperview().offset(16)
        }
        
        worksheetButton.snp.makeConstraints { make in
            make.top.equalTo(sheetLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview()
            make.width.equalTo(testsheetButton)
            make.height.equalTo(260)
        }
        
        testsheetButton.snp.makeConstraints { make in
            make.top.equalTo(sheetLabel.snp.bottom).offset(16)
            make.leading.equalTo(worksheetButton.snp.trailing).offset(20)
            make.width.equalTo(wrongsheetButton)
            make.height.equalTo(worksheetButton)
        }
        
        wrongsheetButton.snp.makeConstraints { make in
            make.top.equalTo(sheetLabel.snp.bottom).offset(16)
            make.leading.equalTo(testsheetButton.snp.trailing).offset(20)
            make.trailing.equalToSuperview()
            make.width.equalTo(worksheetButton)
            make.height.equalTo(worksheetButton)
        }
        
        recentsheetLabel.snp.makeConstraints { make in
            make.top.equalTo(worksheetButton.snp.bottom).offset(44)
            make.leading.equalToSuperview().offset(16)
        }
        
        recentsheetView.snp.makeConstraints { make in
            make.top.equalTo(recentsheetLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(456)
        }
    }
    
    private func setupRecentsheetView() {
        contentView.addSubview(recentsheetView)
        
        recentsheetView.backgroundColor = .white
        recentsheetView.layer.cornerRadius = 40
        recentsheetView.layer.masksToBounds = true
        
        recentsheetView.addSubview(recentTableView)
        
        recentTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        recentTableView.dataSource = self
        recentTableView.delegate = self
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: recentTableView.frame.width, height: 22)
        recentTableView.tableHeaderView = headerView
    }
    
    private func setupFilterButtons() {
        filterButtonsView = UIStackView(arrangedSubviews: [
            allFilterButton,
            worksheetFilterButton,
            testsheetFilterButton,
            wrongsheetFilterButton
        ])
        
        filterButtonsView.axis = .horizontal
        filterButtonsView.spacing = 8
        filterButtonsView.alignment = .center
        filterButtonsView.distribution = .fill // fillEqually에서 fill로 변경
        
        recentsheetView.addSubview(filterButtonsView)
        filterButtonsView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(28)
            make.height.equalTo(30)
        }
        
        configureButton(allFilterButton, title: "전체보기")
        configureButton(worksheetFilterButton, title: "빈칸 학습지", imageName: "bookmark-blue")
        configureButton(testsheetFilterButton, title: "나만의 시험지", imageName: "bookmark-yellow")
        configureButton(wrongsheetFilterButton, title: "오답노트", imageName: "bookmark-gray-v2")
        
        // 초기 선택 상태 설정
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
        config.baseForegroundColor = MemorableColor.Gray1
        config.baseBackgroundColor = MemorableColor.Gray5
        
        // 콘텐츠 패딩 설정
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        button.configuration = config
        button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        
        // 버튼 크기 설정
        button.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        
        // 내부 콘텐츠에 맞춰 크기 조정
        button.sizeToFit()
        
        // 최소 너비 설정 (옵션)
        button.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(80)
        }
    }
    
    private func updateButtonState(_ selectedButton: UIButton, isSelected: Bool) {
        for button in [allFilterButton, worksheetFilterButton, testsheetFilterButton, wrongsheetFilterButton] {
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
    
    func setDocuments(worksheet: [Document], testsheet: [Document], wrongsheet: [Document]) {
        worksheetDocuments = worksheet
        testsheetDocuments = testsheet
        wrongsheetDocuments = wrongsheet
        
        // 초기 상태로 모든 문서를 표시
        
        updateButtonState(currentFilterButton, isSelected: true)
        updateCurrentDocuments()
    }
    
    private func setupGradientView() {
        let gradientView = GradientView(startColor: MemorableColor.White ?? .white, endColor: MemorableColor.White ?? .white)
        recentsheetView.addSubview(gradientView)
        
        gradientView.snp.makeConstraints { make in
            make.top.equalTo(filterButtonsView.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    @objc private func worksheetButtonTapped() {
        currentDocuments = worksheetDocuments
        recentTableView.reloadData()
        delegate?.didTapWorksheetButton(with: worksheetDocuments)
    }
    
    @objc private func testsheetButtonTapped() {
        currentDocuments = testsheetDocuments
        recentTableView.reloadData()
        delegate?.didTapTestsheetButton(with: testsheetDocuments)
    }
    
    @objc private func wrongsheetButtonTapped() {
        currentDocuments = wrongsheetDocuments
        recentTableView.reloadData()
        delegate?.didTapWrongsheetButton(with: wrongsheetDocuments)
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        updateButtonState(sender, isSelected: true)
        currentFilterButton = sender
        updateCurrentDocuments()
    }
    
    private func updateCurrentDocuments() {
        switch currentFilterButton {
        case allFilterButton:
            currentDocuments = (worksheetDocuments + testsheetDocuments + wrongsheetDocuments).sorted { $0.createdDate > $1.createdDate }
        case worksheetFilterButton:
            currentDocuments = worksheetDocuments
        case testsheetFilterButton:
            currentDocuments = testsheetDocuments
        case wrongsheetFilterButton:
            currentDocuments = wrongsheetDocuments
        default:
            currentDocuments = (worksheetDocuments + testsheetDocuments + wrongsheetDocuments).sorted { $0.createdDate > $1.createdDate }
        }
        recentTableView.reloadData()
    }
}

extension LibraryViewComponent: UITableViewDataSource, UITableViewDelegate, RecentsheetCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDocuments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentsheetCell", for: indexPath) as! RecentsheetCell
        cell.delegate = self
        let document = currentDocuments[indexPath.row]
        cell.configure(with: document)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let document = currentDocuments[indexPath.row]
        
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
                        
                        print("---GET WorkSheet---")
                        print("NAME: \(detail.name)")
                        print("CATE: \(detail.category)")
                        print("isComplete: \(detail.isCompleteAllBlanks)")
                        print("isAddWorksheet: \(detail.isAddWorksheet)")
                        print("isMakeTestSheet: \(detail.isMakeTestSheet)")
                    
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
    // TODO: API 연결중 이까지
    
    private func navigateToViewController(_ viewController: UIViewController) {
        if let navigationController = window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else if let presentingViewController = window?.rootViewController {
            presentingViewController.present(viewController, animated: true, completion: nil)
        }
    }
    
    func didTapBookmark<T: Document>(for document: T) {
        if let index = currentDocuments.firstIndex(where: { $0.id == document.id && $0.fileType == document.fileType }) {
            currentDocuments[index] = document
            
            let indexPath = IndexPath(row: index, section: 0)
            recentTableView.reloadRows(at: [indexPath], with: .none)
        }
        
        updateCurrentDocuments()
        delegate?.didUpdateBookmark(for: document)
    }
}
