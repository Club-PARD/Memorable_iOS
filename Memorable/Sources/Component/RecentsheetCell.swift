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
    private let categoryLabel = UILabel()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let bookmarkButton = UIButton()
    
    weak var delegate: RecentsheetCellDelegate?
    private var document: Document?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(categoryLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(bookmarkButton)
        
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
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
        categoryLabel.textColor = .blue
        categoryLabel.backgroundColor = .clear
        categoryLabel.textAlignment = .center
        categoryLabel.layer.cornerRadius = 14
        categoryLabel.layer.masksToBounds = true
        categoryLabel.layer.borderColor = UIColor.blue.cgColor
        categoryLabel.layer.borderWidth = 1

        titleLabel.text = document.fileName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: document.date)
        dateLabel.text = dateString
        
        updateBookmarkButton()
    }
    
    private func updateBookmarkButton() {
        guard let document = document else { return }
        
        let bookmarkImageName: String
        if document.bookmark {
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
        document.bookmark.toggle()
        self.document = document
        updateBookmarkButton()
        delegate?.didTapBookmark(for: document)
    }
}
