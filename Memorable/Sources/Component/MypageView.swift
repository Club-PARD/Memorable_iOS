//
//  mypageView.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/30/24.
//

import UIKit
import SnapKit

class MypageView: UIView {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 40
        self.layer.masksToBounds = true
    }
    
    private func setupConstraints() {
        
    }
}
