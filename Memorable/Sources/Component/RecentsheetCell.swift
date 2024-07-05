//
//  RecentsheetCell.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/30/24.
//

import UIKit
import SnapKit

protocol RecentsheetCellDelegate: AnyObject {
    func didTapBookmark(for document: Document)
}

class RecentsheetCell: UITableViewCell {
    private let categoryImageView = UIImageView()
    private let categoryLabel = UILabel()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let bookmarkButton = UIButton()
    
    weak var delegate: RecentsheetCellDelegate?
    private var document: Document?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(categoryImageView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(bookmarkButton)
        
        categoryImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(28)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(75)
            make.height.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryLabel.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-32)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with document: Document) {
        self.document = document
        
        categoryLabel.text = document.category
        categoryLabel.textColor = MemorableColor.Blue2
        categoryLabel.font = MemorableFont.BodyCaption()
        categoryLabel.backgroundColor = .clear
        categoryLabel.textAlignment = .center
        categoryLabel.layer.cornerRadius = 14
        categoryLabel.layer.masksToBounds = true
        categoryLabel.layer.borderColor = MemorableColor.Blue2?.cgColor
        categoryLabel.layer.borderWidth = 1

        titleLabel.text = document.name
        titleLabel.font = MemorableFont.Body1()
        titleLabel.textColor = MemorableColor.Black
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: document.createdDate)
        dateLabel.text = dateString
        dateLabel.font = MemorableFont.BodyCaption()
        dateLabel.textColor = MemorableColor.Gray1
        
        switch document.fileType {
        case "빈칸학습지":
            categoryImageView.image = UIImage(named: "work-list")
        case "나만의 시험지":
            categoryImageView.image = UIImage(named: "test-list")
        case "오답노트":
            categoryImageView.image = UIImage(named: "wrong-list")
        default:
            categoryImageView.image = nil
        }
        
        updateBookmarkButton()
    }
    
    private func updateBookmarkButton() {
        guard let document = document else { return }
        
        let bookmarkImageName: String
        if document.isBookmarked {
            switch document.fileType {
            case "빈칸학습지":
                bookmarkImageName = "bookmark-blue"
            case "나만의 시험지":
                bookmarkImageName = "bookmark-yellow"
            case "오답노트":
                bookmarkImageName = "bookmark-gray-v2"
            default:
                bookmarkImageName = "bookmark-empty"
            }
        } else {
            bookmarkImageName = "bookmark-empty"
        }
        
        bookmarkButton.setImage(UIImage(named: bookmarkImageName), for: .normal)
    }
    
    @objc private func bookmarkTapped() {
        guard var document = document else { return }
        
        if let worksheet = document as? Worksheet {
            APIManagere.shared.toggleWorksheetBookmark(worksheetId: worksheet.id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let updatedWorksheet):
                        document = updatedWorksheet
                        self?.document = updatedWorksheet
                        self?.updateBookmarkButton()
                        self?.delegate?.didTapBookmark(for: updatedWorksheet)
                    case .failure(let error):
                        print("Error toggling bookmark: \(error)")
                        // Handle error (e.g., show an alert to the user)
                    }
                }
            }
        } else {
            // Handle other document types if necessary
            document.isBookmarked.toggle()
            self.document = document
            updateBookmarkButton()
            delegate?.didTapBookmark(for: document)
        }
    }
}
