//
//  WorksheetTableViewCell.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/28/24.
//

import UIKit
import SnapKit

class WorksheetTableViewCell: UITableViewCell {
    let categoryView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        return label
    }()
    
    let fileNameLabel: UILabel = {
        let label = UILabel()
        // Additional configuration if needed
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        // Additional configuration if needed
        return label
    }()
    
    let bookMarkButton: UIButton = {
        let button = UIButton(type: .system)
        // Additional configuration if needed
        return button
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "WorksheetTableViewCell")
        
        contentView.addSubview(categoryView)
        categoryView.addSubview(categoryLabel)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(bookMarkButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        categoryView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(76)
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(16)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        fileNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryView.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(fileNameLabel.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }
        
        bookMarkButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-36)
            make.centerY.equalToSuperview()
        }
    }
}
