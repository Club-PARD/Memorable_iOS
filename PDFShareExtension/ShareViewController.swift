//
//  ShareViewController.swift
//  PDFShareExtension
//
//  Created by 김현기 on 6/30/24.
//

import SnapKit
import Social
import Then
import UIKit

class ShareViewController: UIViewController {
    private let label = UILabel().then {
        $0.text = "TEST"
        $0.font = .systemFont(ofSize: 20)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray.withAlphaComponent(0.8)
        
        addSubViews()
        setupConstraints()
    }
    
    // MARK: - General Settings

    func addSubViews() {
        view.addSubview(label)
    }
    
    func setupConstraints() {
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
