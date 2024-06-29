//
//  LibraryViewComponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/26/24.
//

import UIKit
import SnapKit

protocol LibraryViewComponentDelegate: AnyObject {
    func didTapTopLeftButton(with documents: [Document])
    func didTapTopRightButton(with documents: [Document])
    func didTapBottomButton(with documents: [Document])
}

class LibraryViewComponent: UIView {
    
    weak var delegate: LibraryViewComponentDelegate?
    
    private let topLeftView: UIView
    private let topRightView: UIView
    private let bottomView: UIView
    
    private var topLeftDocuments: [Document] = []
    private var topRightDocuments: [Document] = []
    private var bottomDocuments: [Document] = []
    
    private lazy var topLeftCollectionView: UICollectionView = self.createCollectionView(isNoteView: false)
    private lazy var topRightCollectionView: UICollectionView = self.createCollectionView(isNoteView: false)
    private lazy var bottomCollectionView: UICollectionView = self.createCollectionView(isNoteView: true)
    
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
        setupButtons()
        setupCollectionViews()
    }
    
    private func setupLabels() {
        let topLeftLabel = createLabel(text: "빈칸학습지", backgroundColor: .systemYellow)
        let topRightLabel = createLabel(text: "나만의 시험지", backgroundColor: .systemBlue)
        let bottomLabel = createLabel(text: "오답노트", backgroundColor: .systemGray)
        
        topLeftView.addSubview(topLeftLabel)
        topRightView.addSubview(topRightLabel)
        bottomView.addSubview(bottomLabel)
        
        [topLeftLabel, topRightLabel, bottomLabel].forEach {
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(20)
                make.leading.equalToSuperview().offset(20)
            }
        }
    }
    
    private func setupButtons() {
        let topLeftButton = createButton(imageName: "goarrow")
        let topRightButton = createButton(imageName: "goarrow")
        let bottomButton = createButton(imageName: "goarrow")
        
        topLeftButton.addTarget(self, action: #selector(topLeftButtonTapped), for: .touchUpInside)
        topRightButton.addTarget(self, action: #selector(topRightButtonTapped), for: .touchUpInside)
        bottomButton.addTarget(self, action: #selector(bottomButtonTapped), for: .touchUpInside)
        
        topLeftView.addSubview(topLeftButton)
        topRightView.addSubview(topRightButton)
        bottomView.addSubview(bottomButton)
        
        [topLeftButton, topRightButton, bottomButton].forEach {
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(23)
                make.trailing.equalToSuperview().offset(-20)
                make.width.height.equalTo(24)
            }
        }
    }
    
    private func createLabel(text: String, backgroundColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.backgroundColor = backgroundColor
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.layer.cornerRadius = 19
        label.clipsToBounds = true
        label.textAlignment = .center
        label.snp.makeConstraints { make in
            make.width.equalTo(101)
            make.height.equalTo(38)
        }
        return label
    }
    
    private func createButton(imageName: String) -> UIButton {
        let button = UIButton()
        if let image = UIImage(named: imageName) {
            button.setImage(image, for: .normal)
        }
        button.contentMode = .scaleAspectFit
        return button
    }
    
    private func setupConstraints() {
        topLeftView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(self.snp.centerX).offset(-10)
            make.height.equalTo(340)
        }
        
        topRightView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(self.snp.centerX).offset(10)
            make.trailing.equalToSuperview()
            make.height.equalTo(340)
        }
        
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(topLeftView.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(209)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupCollectionViews() {
        topLeftView.addSubview(topLeftCollectionView)
        topRightView.addSubview(topRightCollectionView)
        bottomView.addSubview(bottomCollectionView)
        
        [topLeftCollectionView, topRightCollectionView, bottomCollectionView].forEach {
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(74)
                make.leading.equalToSuperview().offset(25)
                make.trailing.equalToSuperview().offset(-25)
                make.bottom.equalToSuperview().offset(-20) // 변경: lessThanOrEqualTo -> equalTo
            }
            
            $0.dataSource = self
            $0.delegate = self
        }
    }
    
    private func createCollectionView(isNoteView: Bool) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(ContentCollectionViewCellComponent.self, forCellWithReuseIdentifier: "ContentCell")
        
        return collectionView
    }
    
    func setDocuments(topLeft: [Document], topRight: [Document], bottom: [Document]) {
        topLeftDocuments = topLeft
        topRightDocuments = topRight
        bottomDocuments = bottom
        
        topLeftCollectionView.reloadData()
        topRightCollectionView.reloadData()
        bottomCollectionView.reloadData()
        
        // 데이터가 설정된 후 reloadData가 호출되는지 확인
        print("Documents set: TopLeft: \(topLeftDocuments.count), TopRight: \(topRightDocuments.count), Bottom: \(bottomDocuments.count)")
    }
    
    @objc private func topLeftButtonTapped() {
        delegate?.didTapTopLeftButton(with: topLeftDocuments)
        
    }
    @objc private func topRightButtonTapped() {
        delegate?.didTapTopRightButton(with: topRightDocuments)
    }

    @objc private func bottomButtonTapped() {
        delegate?.didTapBottomButton(with: bottomDocuments)
    }
}

extension LibraryViewComponent: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath) as! ContentCollectionViewCellComponent
        
        let document: Document
        
        switch collectionView {
        case topLeftCollectionView:
            document = topLeftDocuments[indexPath.item]
        case topRightCollectionView:
            document = topRightDocuments[indexPath.item]
        case bottomCollectionView:
            document = bottomDocuments[indexPath.item]
        default:
            fatalError("Unexpected collection view")
        }
        
        cell.configure(with: document)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        switch collectionView {
        case topLeftCollectionView:
            count = topLeftDocuments.count
        case topRightCollectionView:
            count =  topRightDocuments.count
        case bottomCollectionView:
            count = bottomDocuments.count
        default:
            return 0
        }
        return count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isNoteView = (collectionView == bottomCollectionView)
        let maxItemsPerRow = isNoteView ? 8 : 4
        let totalSpacing = CGFloat(maxItemsPerRow - 1) * 20
        let itemWidth = (collectionView.bounds.width - totalSpacing) / CGFloat(maxItemsPerRow)
        return CGSize(width: itemWidth, height: 115)
    }
}
