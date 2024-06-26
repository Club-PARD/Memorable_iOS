//
//  TabViewComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/25/24.
//

import UIKit
import SnapKit

protocol TabBarComponentDelegate: AnyObject {
    func didSelectTab(title: String, action: () -> Void)
}

class TabBarComponent: UIView {
    
    weak var delegate: TabBarComponentDelegate?
    
    let homeButton = UIButton()
    let starButton = UIButton()
    let myPageButton = UIButton()
    
    private var buttons: [UIButton] = []
    private var titles: [String] = []
    private var actions: [() -> Void] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .lightGray
        self.layer.cornerRadius = 56
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
        
        buttons = [homeButton, starButton, myPageButton]
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    func configure(withTitles titles: [String], actions: [() -> Void]) {
        guard titles.count == buttons.count && actions.count == buttons.count else {
            fatalError("Titles and actions count must match the number of buttons.")
        }
        
        self.titles = titles
        self.actions = actions
        
        for (index, button) in buttons.enumerated() {
            setupButton(button, title: titles[index])
        }
    }
    
    private func setupButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 33
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.clear.cgColor
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let index = buttons.firstIndex(of: sender) else { return }
        let title = titles[index]
        let action = actions[index]
        
        delegate?.didSelectTab(title: title, action: action)
    }
}
