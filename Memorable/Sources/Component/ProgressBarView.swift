//
//  ProgressBarView.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/29/24.
//

import UIKit
import SnapKit

class ProgressBarView: UIView {
    private let totalPages: Int
    private var currentPage: Int
    private let spacing: CGFloat = 4
    private let itemHeight: CGFloat = 8
    private let currentItemWidth: CGFloat = 31.56
    private let otherItemWidth: CGFloat = 23.11
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.distribution = .fill
        return stackView
    }()
    
    init(frame: CGRect, totalPages: Int, currentPage: Int) {
        self.totalPages = totalPages
        self.currentPage = currentPage
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        for _ in 0..<totalPages {
            let itemImageView = UIImageView()
            itemImageView.contentMode = .scaleToFill
            stackView.addArrangedSubview(itemImageView)
            
            itemImageView.snp.makeConstraints { make in
                make.width.equalTo(otherItemWidth)
                make.height.equalTo(itemHeight)
            }
        }
        
        // Set an explicit height for ProgressBarView
        self.snp.makeConstraints { make in
            make.height.equalTo(itemHeight)
        }
        
        updateCurrentPage(currentPage)
    }
    
    func updateCurrentPage(_ page: Int) {
        currentPage = page
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            if let imageView = view as? UIImageView {
                if index == currentPage - 1 {  // Current page
                    imageView.image = UIImage(named: "progressbar-current")
                    imageView.snp.remakeConstraints { make in
                        make.width.equalTo(currentItemWidth)
                        make.height.equalTo(itemHeight)
                    }
                } else if index < currentPage - 1 {  // Before current page
                    imageView.image = UIImage(named: "progressbar-other")
                    imageView.snp.remakeConstraints { make in
                        make.width.equalTo(otherItemWidth)
                        make.height.equalTo(itemHeight)
                    }
                } else {  // After current page
                    imageView.image = UIImage(named: "progressbar-other-left")
                    imageView.snp.remakeConstraints { make in
                        make.width.equalTo(otherItemWidth)
                        make.height.equalTo(itemHeight)
                    }
                }
            }
        }
        layoutIfNeeded()
    }
}
