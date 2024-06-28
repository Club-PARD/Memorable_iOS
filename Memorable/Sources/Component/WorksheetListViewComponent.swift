//
//  WorkSheetListViewComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/28/24.
//

import UIKit


class WorksheetListViewComponent: UIView {
    
    private let worksheetTableView: UITableView
    
    private var worksheets: [Document] = []
    
    override init(frame: CGRect) {
        self.worksheetTableView = UITableView(frame: .zero, style: .plain)
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 40
        self.clipsToBounds = true
        
        setupViews()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(worksheetTableView)
        worksheetTableView.register(WorksheetTableViewCell.self, forCellReuseIdentifier: "WorksheetTableViewCell")
        
        setupTableView()
    }
    
    func setWorksheets(_ documents: [Document]) {
        worksheets = documents
        print("Worksheets set: \(worksheets.count)")
        worksheetTableView.reloadData()
    }
    
    private func createTableView() -> UITableView {
        worksheetTableView.backgroundColor = .clear
        return worksheetTableView
    }
    
    private func setupTableView() {
        
        worksheetTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(76)
            make.leading.equalToSuperview().offset(35)
            make.trailing.equalToSuperview().offset(-36)
            make.bottom.equalToSuperview().offset(-56)
        }
        worksheetTableView.dataSource = self
        worksheetTableView.delegate = self
        worksheetTableView.rowHeight = 62
    }
}

extension WorksheetListViewComponent: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return worksheets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = worksheetTableView.dequeueReusableCell(withIdentifier: "WorksheetTableViewCell", for: indexPath) as? WorksheetTableViewCell else {
            fatalError("Unable to dequeue WorksheetTableViewCell")
        }
        let document = worksheets[indexPath.row]
        cell.fileNameLabel.text = document.fileName
        cell.categoryLabel.text = "카테고리 n"
//        cell.categoryLabel.text = document.category
//        날짜 설정 (만약 Document 모델에 날짜 속성이 있다면)
//        cell.dateLabel.text = document.date
        cell.dateLabel.text = "2024. 10. 10"
        return cell
    }
    
    
}
