//
//  WorkSheetListViewComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/28/24.
//

import SnapKit
import UIKit

class WorksheetListViewComponent: UIView {
    private let worksheetTableView: UITableView
    private let filterScrollView: UIScrollView
    private let filterStackView: UIStackView
    private let settingButton: UIButton
    private var editButton: UIBarButtonItem?
    private var doneButton: UIBarButtonItem?
    
    private var worksheets: [Document] = []
    private var categories: Set<String> = []
    private var filteredWorksheets: [Document] = []
    
    private var isEditingMode: Bool = false {
        didSet {
            worksheetTableView.setEditing(isEditingMode, animated: true)
            updateEditingUI()
        }
    }
    
    override init(frame: CGRect) {
        self.worksheetTableView = UITableView(frame: .zero, style: .plain)
        self.filterScrollView = UIScrollView()
        self.filterStackView = UIStackView()
        self.settingButton = UIButton()
        super.init(frame: frame)
        self.backgroundColor = MemorableColor.White
        layer.cornerRadius = 40
        self.clipsToBounds = true
        
        setupViews()
        setupTableView()
        setupGradientView()
        setupEditingButtons()
    }
    
    @available(*, unavailable)
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
    
    private func setupTableView() {
        worksheetTableView.dataSource = self
        worksheetTableView.delegate = self
        worksheetTableView.rowHeight = 62
        worksheetTableView.allowsSelection = true
        worksheetTableView.allowsMultipleSelectionDuringEditing = true
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: worksheetTableView.frame.width, height: 22)
        worksheetTableView.tableHeaderView = headerView
    }
    
    private func setupGradientView() {
        let gradientView = GradientView(startColor: MemorableColor.White ?? .white, endColor: MemorableColor.White ?? .white)
        addSubview(gradientView)
        
        gradientView.snp.makeConstraints { make in
            make.top.equalTo(filterScrollView.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    private func setupEditingButtons() {
        editButton = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(toggleEditingMode))
        doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(toggleEditingMode))
        
        if let viewController = findViewController() as? UIViewController {
            viewController.navigationItem.rightBarButtonItem = editButton
        }
    }
    
    @objc private func toggleEditingMode() {
        isEditingMode.toggle()
    }
    
    private func updateEditingUI() {
        if let viewController = findViewController() as? UIViewController {
            viewController.navigationItem.rightBarButtonItem = isEditingMode ? doneButton : editButton
        }
        
        if isEditingMode {
            let deleteButton = UIBarButtonItem(title: "삭제", style: .plain, target: self, action: #selector(deleteSelectedItems))
            let editButton = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(editSelectedItem))
            if let viewController = findViewController() as? UIViewController {
                viewController.navigationItem.leftBarButtonItems = [deleteButton, editButton]
            }
        } else {
            if let viewController = findViewController() as? UIViewController {
                viewController.navigationItem.leftBarButtonItems = nil
            }
        }
    }
    
    @objc private func deleteSelectedItems() {
        guard let selectedIndexPaths = worksheetTableView.indexPathsForSelectedRows, !selectedIndexPaths.isEmpty else {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: "선택한 항목을 삭제하시겠습니까?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            let itemsToDelete = selectedIndexPaths.map { self.filteredWorksheets[$0.row] }
            
            // TODO: 서버에 삭제 요청
            // let documentIds = itemsToDelete.map { $0.id }
            // APIManager.shared.deleteDocuments(documentIds: documentIds) { result in
            //     DispatchQueue.main.async {
            //         switch result {
            //         case .success:
            //             self.filteredWorksheets = self.filteredWorksheets.filter { !itemsToDelete.contains($0) }
            //             self.worksheetTableView.deleteRows(at: selectedIndexPaths, with: .automatic)
            //         case .failure(let error):
            //             print("Error deleting documents: \(error)")
            //             // 에러 처리 (예: 사용자에게 알림 표시)
            //         }
            //     }
            // }
            
            // 임시로 로컬에서만 삭제
//            self.filteredWorksheets = self.filteredWorksheets.filter { !itemsToDelete.contains($0) }
//            self.worksheetTableView.deleteRows(at: selectedIndexPaths, with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if let viewController = findViewController() {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc private func editSelectedItem() {
        guard let selectedIndexPaths = worksheetTableView.indexPathsForSelectedRows, selectedIndexPaths.count == 1,
              let indexPath = selectedIndexPaths.first
        else {
            // 하나의 항목만 선택되었을 때 수정 가능
            return
        }
        
        let document = filteredWorksheets[indexPath.row]
        
        let alertController = UIAlertController(title: "파일 이름 수정", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = document.name
        }
        
        let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            guard let self = self,
                  let newTitle = alertController.textFields?.first?.text,
                  !newTitle.isEmpty else { return }
            
            // 로컬에서 이름 변경
//            document.name = newTitle
            
            // TODO: 서버에 이름 변경 요청
            // APIManager.shared.updateDocumentTitle(documentId: document.id, newTitle: newTitle) { result in
            //     DispatchQueue.main.async {
            //         switch result {
            //         case .success:
            //             self.worksheetTableView.reloadRows(at: [indexPath], with: .automatic)
            //         case .failure(let error):
            //             print("Error updating document title: \(error)")
            //             // 에러 처리 (예: 사용자에게 알림 표시)
            //         }
            //     }
            // }
            
            // 임시로 로컬에서만 변경
            self.worksheetTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        if let viewController = findViewController() {
            viewController.present(alertController, animated: true, completion: nil)
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
        for view in filterStackView.arrangedSubviews {
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
            self.toggleEditingMode()
        }
        
        let deleteAction = UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.toggleEditingMode()
        }
        
        let menu = UIMenu(title: "", children: [editAction, deleteAction])
        
        settingButton.menu = menu
        settingButton.showsMenuAsPrimaryAction = true
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
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditingMode {
            updateEditingUI()
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let document = worksheets[indexPath.row]
                    
            switch document.fileType {
            case "빈칸학습지":
                if let worksheet = document as? Worksheet {
                    // Fetch WorksheetDetail before navigating
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
                            workSheetVC.worksheetDetail = detail
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
                                            
                        //                    let wrongSheetVC = WrongSheetViewController()
                        //                    wrongSheetVC.wrongsheetDetail = detail
                        //                    self.navigateToViewController(wrongSheetVC)
                    }
                }
            default:
                print("Unknown file type")
            }
        }
    }
        
    private func navigateToViewController(_ viewController: UIViewController) {
        if let navigationController = window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else if let presentingViewController = window?.rootViewController {
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
        if let nextResponder = next as? UIViewController {
            return nextResponder
        } else if let nextResponder = next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
