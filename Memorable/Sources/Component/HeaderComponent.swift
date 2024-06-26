//
//  SearchBarComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/25/24.
//

import UIKit
import SnapKit

class HeaderComponent: UIView {
    
    private let appLogoImageView = UIImageView()
    private let appLogo = UIImage()
    private let searchBar = UISearchBar()
    private let searchButton = UIButton()
    private let plusButton = UIButton()
    
    private var isExpanded = false
    private var searchTrailing: CGFloat = -124
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        // App Logo
        addSubview(appLogoImageView)
        appLogoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.equalTo(174)
            make.height.equalTo(21.92)
        }
        appLogoImageView.image = UIImage(named: "applogo2")
            
        
        // Plus Button
        addSubview(plusButton)
        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
            make.width.equalTo(88)
            make.height.equalTo(44)
        }
        if let originalImage = UIImage(named: "btnPlus") {
            let resizedImage = originalImage.resized(to: CGSize(width: 24, height: 24))
            plusButton.setImage(resizedImage, for: .normal)
        }
        plusButton.imageView?.contentMode = .center
        plusButton.backgroundColor = .cyan
        plusButton.layer.cornerRadius = 22
        // plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        // Search Button
        addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(searchTrailing)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        if let searchImage = UIImage(named: "btnSearch")?.resized(to: CGSize(width: 24, height: 24)) {
            searchButton.setImage(searchImage, for: .normal)
        }
        searchButton.imageView?.contentMode = .center
        searchButton.backgroundColor = .black
        searchButton.layer.cornerRadius = 22
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        // Search Bar
        addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-168)
            make.centerY.equalTo(searchButton.snp.centerY)
            make.height.equalTo(44)
            make.width.equalTo(0)
        }
        searchBar.alpha = 0
        setupSearchBarStyle()
    }
    
    private func setupSearchBarStyle() {
        searchBar.barTintColor = .black
        searchBar.backgroundImage = UIImage()
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .black
            textField.textColor = .white
            textField.layer.cornerRadius = 22
            textField.clipsToBounds = true
            textField.font = UIFont.systemFont(ofSize: 16)
        }
    }
    
    @objc private func searchButtonTapped() {
        isExpanded.toggle()
        
        let animationDuration: TimeInterval = 0.5
        let _: CGFloat = 88.0
        
//        let targetSearchTrailing = isExpanded
//            ? searchTrailing + movementDistance
//            : searchTrailing - movementDistance
        
        UIView.animate(withDuration: animationDuration) {
//            self.searchTrailing = targetSearchTrailing
            
//            self.searchButton.snp.updateConstraints { make in
//                make.trailing.equalToSuperview().offset(self.searchTrailing)
//            }
            
            if self.isExpanded {
                self.animateSearchBar()
            } else {
                self.hideSearchBar()
            }
            
            self.layoutIfNeeded()
        }
    }
    
    private func animateSearchBar() {
        searchBar.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
            self.searchBar.snp.updateConstraints { make in
                make.width.equalTo(850)
            }
            self.layoutIfNeeded()
        }
    }
    
    private func hideSearchBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
            self.searchBar.snp.updateConstraints { make in
                make.width.equalTo(0)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.searchBar.alpha = 0
        }
    }
}
