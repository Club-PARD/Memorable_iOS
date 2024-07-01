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
    
    private var worksheets: [Document] = []
    private var categories: Set<String> = []
    private var filteredWorksheets: [Document] = []
    
    override init(frame: CGRect) {
        self.worksheetTableView = UITableView(frame: .zero, style: .plain)
        self.filterScrollView = UIScrollView()
        self.filterStackView = UIStackView()
        super.init(frame: frame)
        self.backgroundColor = .white
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
            outgoing.font = UIFont.systemFont(ofSize: 14)
            return outgoing
        }
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        configuration.cornerStyle = .capsule
        
        if title == "전체보기" {
            configuration.baseBackgroundColor = .black
            configuration.baseForegroundColor = .white
        } else {
            configuration.baseBackgroundColor = .lightGray
            configuration.baseForegroundColor = .gray
        }
        
        button.configuration = configuration
        button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        filterStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                var config = button.configuration
                config?.baseBackgroundColor = .lightGray
                config?.baseForegroundColor = .gray
                button.configuration = config
            }
        }
        
        var config = sender.configuration
        config?.baseBackgroundColor = .black
        config?.baseForegroundColor = .white
        sender.configuration = config
        
        if sender.configuration?.title == "전체보기" {
            filteredWorksheets = worksheets
        } else {
            filteredWorksheets = worksheets.filter { $0.category == sender.configuration?.title }
        }
        
        worksheetTableView.reloadData()
    }
    
    private func setupTableView() {
        worksheetTableView.dataSource = self
        worksheetTableView.delegate = self
        worksheetTableView.rowHeight = 62
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: worksheetTableView.frame.width, height: 22)
        worksheetTableView.tableHeaderView = headerView
    }
    
    private func setupGradientView() {
        let gradientView = GradientView(startColor: .white, endColor: .white)
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
            let workSheetVC = WorkSheetViewController()
//            workSheetVC.document = document
            navigateToViewController(workSheetVC)
        case "나만의 시험지":
            let testSheetVC = TestSheetViewController()
//            testSheetVC.document = document
            navigateToViewController(testSheetVC)
        case "오답노트":
            // 오답노트에 대한 처리를 여기에 추가할 수 있습니다.
            break
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
