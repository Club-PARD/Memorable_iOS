//
//  LibraryViewComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/26/24.
//

import UIKit
import SnapKit

class LibraryViewComponent: UIView {
    
    private let topLeftView: UIView
    private let topRightView: UIView
    private let bottomView: UIView
    
    override init(frame: CGRect) {
        topLeftView = UIView()
        topRightView = UIView()
        bottomView = UIView()
        
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(topLeftView)
        addSubview(topRightView)
        addSubview(bottomView)
        
        [topLeftView, topRightView, bottomView].forEach {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 40
            $0.layer.masksToBounds = true
        }
        
        setupLabels()
    }
    
    private func setupLabels() {
        let topLeftLabel = createLabel(text: "빈칸 학습지", backgroundColor: .systemYellow)
        let topRightLabel = createLabel(text: "나만의 시험지", backgroundColor: .systemBlue)
        let bottomLabel = createLabel(text: "오답노트", backgroundColor: .systemGray)
        
        topLeftView.addSubview(topLeftLabel)
        topRightView.addSubview(topRightLabel)
        bottomView.addSubview(bottomLabel)
        
        [topLeftLabel, topRightLabel, bottomLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: $0.superview!.topAnchor, constant: 20),
                $0.leadingAnchor.constraint(equalTo: $0.superview!.leadingAnchor, constant: 20)
            ])
        }
    }
    
    private func createLabel(text: String, backgroundColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.backgroundColor = backgroundColor
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return label
    }
    
    private func setupConstraints() {

        topLeftView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(466)
            make.height.equalTo(340)
        }

        topRightView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(topLeftView.snp.trailing).offset(20) // 수정된 부분
            make.width.equalTo(466)
            make.height.equalTo(340)
        }

        bottomView.snp.makeConstraints { make in
            make.top.equalTo(topLeftView.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(209)
        }
    }
}
