//
//  ContentCollectionViewCellComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/27/24.
//

import UIKit
import SnapKit

class ContentCollectionViewCellComponent: UICollectionViewCell {
    private let imageView = UIImageView()
    private let fileNameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(fileNameLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(89)
        }
        
        fileNameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
        
        fileNameLabel.textAlignment = .center
        fileNameLabel.font = UIFont.systemFont(ofSize: 12)
    }
    
    func configure(with document: Document) {
        fileNameLabel.text = document.fileName
        
        switch document.fileType {
        case "빈칸학습지":
            imageView.image = UIImage(named: "worksheet-normal")
        case "나만의 시험지":
            imageView.image = UIImage(named: "testsheet-normal")
        case "오답노트":
            imageView.image = UIImage(named: "wrongsheet-normal")
        default:
            imageView.image = nil
        }
        
        contentView.backgroundColor = .white  // 셀의 배경색을 설정하여 셀이 보이도록 합니다.
    }
}
