//
//  WorkSheetListViewComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/28/24.
//

import UIKit


class WorksheetListViewComponent: UIView {
    private let worksheetTableView: UITableView
    private let filterScrollView: UIScrollView
    private let filterStackView: UIStackView
    private let settingButton: UIButton
    
    private var worksheets: [Document] = []
    private var categories: Set<String> = []
    private var filteredWorksheets: [Document] = []
    
    override init(frame: CGRect) {
        self.worksheetTableView = UITableView(frame: .zero, style: .plain)
        self.filterScrollView = UIScrollView()
        self.filterStackView = UIStackView()
        self.settingButton = UIButton()
        super.init(frame: frame)
        self.backgroundColor = MemorableColor.White
        self.layer.cornerRadius = 40
        self.clipsToBounds = true
        
        setupViews()
        setupTableView()
        setupGradientView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(filterScrollView)
        filterScrollView.addSubview(filterStackView)
        addSubview(settingButton)
        addSubview(worksheetTableView)
        
        filterScrollView.showsHorizontalScrollIndicator = false
        
        filterStackView.axis = .horizontal
        filterStackView.spacing = 8
        filterStackView.alignment = .center
        
        worksheetTableView.register(RecentsheetCell.self, forCellReuseIdentifier: "WorksheetTableViewCell")
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        filterScrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(54)
        }
        
        filterStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(28)
            make.height.equalTo(30)
        }
        
        settingButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(27)
            make.trailing.equalToSuperview().offset(-28)
            make.width.height.equalTo(24)
        }
        
        worksheetTableView.snp.makeConstraints { make in
            make.top.equalTo(filterScrollView.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-56)
        }
    }
    
    func setWorksheets(_ documents: [Document]) {
        worksheets = documents
        filteredWorksheets = documents
        categories = Set(documents.map { $0.category })
        setupFilterButtons()
        setupSettingButton()
        worksheetTableView.reloadData()
    }
    
    private func setupFilterButtons() {
        filterStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let allButton = createFilterButton(title: "전체보기")
        filterStackView.addArrangedSubview(allButton)
        
        for category in categories.sorted() {
            let button = createFilterButton(title: category)
            filterStackView.addArrangedSubview(button)
        }
    }
    
    private func createFilterButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = MemorableFont.BodyCaption()
            return outgoing
        }
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        configuration.cornerStyle = .capsule
        
        if title == "전체보기" {
            configuration.baseBackgroundColor = MemorableColor.Black
            configuration.baseForegroundColor = MemorableColor.White
        } else {
            configuration.baseBackgroundColor = MemorableColor.Gray1
            configuration.baseForegroundColor = MemorableColor.Gray5
        }
        
        button.configuration = configuration
        button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        filterStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                var config = button.configuration
                config?.baseBackgroundColor = MemorableColor.Gray1
                config?.baseForegroundColor = MemorableColor.Gray5
                button.configuration = config
            }
        }
        
        var config = sender.configuration
        config?.baseBackgroundColor = MemorableColor.Black
        config?.baseForegroundColor = MemorableColor.White
        sender.configuration = config
        
        if sender.configuration?.title == "전체보기" {
            filteredWorksheets = worksheets
        } else {
            filteredWorksheets = worksheets.filter { $0.category == sender.configuration?.title }
        }
        
        worksheetTableView.reloadData()
    }
    
    private func setupSettingButton() {
        let image = UIImage(systemName: "ellipsis")?.withRenderingMode(.alwaysTemplate)
        
        settingButton.setImage(image, for: .normal)
        settingButton.tintColor = MemorableColor.Gray1
        
        let editAction = UIAction(title: "수정하기", image: UIImage(systemName: "pencil")) { _ in
            self.handleEditAction()
        }
        
        let deleteAction = UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.handleDeleteAction()
        }
        
        let menu = UIMenu(title: "", children: [editAction, deleteAction])
        
        settingButton.menu = menu
        settingButton.showsMenuAsPrimaryAction = true
    }

    private func handleEditAction() {
        // 수정하기 로직 구현
        print("수정하기 버튼 클릭됨")
    }

    // 삭제하기 액션 핸들러
    private func handleDeleteAction() {
        guard let selectedIndexPaths = worksheetTableView.indexPathsForSelectedRows else {
            print("선택된 셀이 없습니다.")
            return
        }

        // 파일을 삭제하시겠습니까? 확인 메시지 표시
        let alertController = UIAlertController(title: nil, message: "파일을 삭제하시겠습니까?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            print("삭제 작업을 시작합니다.")
            self.worksheetTableView.setEditing(true, animated: true)
            
            // 선택된 셀들을 삭제하는 로직 구현
            let itemsToDelete = selectedIndexPaths.map { self.filteredWorksheets[$0.row] }
            
            // 현재는 로직을 주석 처리했으므로 주석 해제 필요
//            self.filteredWorksheets = self.filteredWorksheets.filter { item in
//                !itemsToDelete.contains { $0 == item }
//            }
            
            // 테이블 뷰에서 선택 해제
            for indexPath in selectedIndexPaths {
                self.worksheetTableView.deselectRow(at: indexPath, animated: true)
            }
            
            // TODO: 서버와 연동하여 삭제 로직 구현
            
            // 테이블 뷰 업데이트
            self.worksheetTableView.deleteRows(at: selectedIndexPaths, with: .automatic)
            
            print("삭제 작업이 완료되었습니다.")
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { _ in
            print("삭제 작업이 취소되었습니다.")
        })
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        // 현재 View Controller를 찾아 alertController를 표시
        if let viewController = self.findViewController() {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }

    private func setupTableView() {
        worksheetTableView.dataSource = self
        worksheetTableView.delegate = self
        worksheetTableView.rowHeight = 62
        worksheetTableView.allowsSelection = true
        worksheetTableView.allowsSelectionDuringEditing = true  // 편집 중에도 셀 선택 가능하도록 설정
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: worksheetTableView.frame.width, height: 22)
        worksheetTableView.tableHeaderView = headerView
    }

    private func setupGradientView() {
        let gradientView = GradientView(startColor: MemorableColor.White ?? .white, endColor: MemorableColor.White ?? .white)
        self.addSubview(gradientView)
        
        gradientView.snp.makeConstraints{ make in
            make.top.equalTo(filterScrollView.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
    }
}

extension WorksheetListViewComponent: UITableViewDataSource, UITableViewDelegate, RecentsheetCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWorksheets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorksheetTableViewCell", for: indexPath) as! RecentsheetCell
        let document = filteredWorksheets[indexPath.row]
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
        
        let document = worksheets[indexPath.row]
        
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
            let testSheetVC = TestSheetViewController()
//            testSheetVC.document = document
            navigateToViewController(testSheetVC)
        case "오답노트":
            let wrongSheetVC = WrongSheetViewController()
            navigateToViewController(wrongSheetVC)
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
    
    func didTapBookmark(for document: Document) {
        // 테이블 뷰 리로드
        // recentTableView.reloadData()
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
