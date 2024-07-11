//
//  EditActionSheetView.swift
//  Memorable
//
//  Created by Minhyeok Kim on 7/7/24.
//

import UIKit
import SnapKit

protocol EditActionSheetDelegate: AnyObject {
    func didConfirmDelete(selectedDocuments: [Document])
}

class EditActionSheetView: UIView {
    private let cancelButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)
    private let actionTitle = UILabel()
    
    var onCancel: (() -> Void)?
    var onConfirm: (() -> Void)?
    
    init(title: String) {
        super.init(frame: .zero)
        setupView(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(title: String) {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addSubview(cancelButton)
        addSubview(confirmButton)
        addSubview(actionTitle)
        
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.setTitleColor(.systemRed, for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        
        actionTitle.text = title
        actionTitle.textAlignment = .center
        
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        confirmButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        actionTitle.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc private func cancelTapped() {
        onCancel?()
    }
    
    @objc private func confirmTapped() {
        onConfirm?()
    }
}
