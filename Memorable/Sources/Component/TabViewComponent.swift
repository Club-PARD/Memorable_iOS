import UIKit
import SnapKit

class TabBarComponent: UIView {
    
    private var buttons: [UIButton] = []
    private var actions: [() -> Void] = []
    private var selectedIndex: Int = 0
    private var imageNames: [String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .gray
        self.layer.cornerRadius = 56
        self.layer.masksToBounds = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 56 // 버튼 사이의 간격
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 58, left: 0, bottom: 58, right: 0))
        }
        
        for _ in 0..<3 {
            let button = createButton()
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func createButton() -> UIButton {
        let button = UIButton()
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 33
        imageView.clipsToBounds = true
        button.addSubview(imageView)
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        button.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(66)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4) // 이미지와 텍스트 사이 간격
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        button.snp.makeConstraints { make in
            make.width.equalTo(66)
            make.height.equalTo(88) // 66(이미지) + 4(간격) + 18(텍스트 예상 높이)
        }
        
        return button
    }
    
    func configure(withItems items: [(title: String, image: String, action: () -> Void)]) {
        guard items.count == buttons.count else {
            fatalError("Items count must match the number of buttons.")
        }
        
        for (index, (title, image, action)) in items.enumerated() {
            setupButton(buttons[index], title: title, image: image, at: index)
            actions.append(action)
            imageNames.append(image)
        }
        
        updateButtonStates()
    }
    
    private func setupButton(_ button: UIButton, title: String, image: String, at index: Int) {
        if let imageView = button.subviews.first as? UIImageView,
           let label = button.subviews.last as? UILabel {
            imageView.image = UIImage(named: image + "-gray")
            label.text = title
        }
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let index = buttons.firstIndex(of: sender) else { return }
        selectedIndex = index
        updateButtonStates()
        actions[index]()
    }
    
    private func updateButtonStates() {
        for (index, button) in buttons.enumerated() {
            let isSelected = index == selectedIndex
            if let imageView = button.subviews.first as? UIImageView,
               let label = button.subviews.last as? UILabel {
                let imageName = imageNames[index] + (isSelected ? "-white" : "-gray")
                imageView.image = UIImage(named: imageName)
                imageView.backgroundColor = isSelected ? .systemBlue : .systemGray5

            }
        }
    }
}
