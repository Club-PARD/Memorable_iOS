//
//  WrongSheetView.swift
//  Memorable
//
//  Created by 김현기 on 7/1/24.
//

import UIKit

class WrongSheetView: UIView {
    // MARK: - Properties

    var userAnswers: [UITextField] = []

    private var viewWidth: CGFloat = 0

    // Create a container view for the text and text fields
    let containerView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .leading
    }

    private let contentView = UIView().then {
        $0.layer.cornerRadius = 40
    }

    private let scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = true
    }

    private var contentString = ""

    private var answers: [String] = []

    private var wrongSheetContent = UIView()

    // MARK: - Initialization

    init(frame: CGRect, viewWidth: CGFloat, text: String, answers: [String]) {
        super.init(frame: frame)
        self.viewWidth = viewWidth
        self.contentString = text
        self.answers = answers

//        self.workSheetContent = self.createFillInTheBlanksUI(
//            question: self.contentString,
//            answers: self.answers
//        )

        self.setupTapGesture()
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        addSubview(self.contentView)

        self.contentView.addSubview(self.scrollView)

        self.contentView.backgroundColor = .white
        self.addSubViewsInScrollView()

        self.contentView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
            $0.width.equalToSuperview()
        }

        self.scrollView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.contentView)
            $0.top.equalTo(self.contentView).offset(72)
            $0.bottom.equalTo(self.contentView).offset(-32)
        }

        self.wrongSheetContent.snp.makeConstraints {
            $0.top.equalTo(self.scrollView)
            $0.leading.equalTo(self.scrollView).offset(32)
            $0.trailing.equalTo(self.scrollView).offset(-32)
            $0.bottom.equalTo(self.scrollView)
            $0.width.equalTo(self.contentView).offset(-64)
        }
    }

    func addSubViewsInScrollView() {
        self.scrollView.addSubview(self.wrongSheetContent)
    }

    // MARK: - Public Methods

    func setContentString(with text: String) {
        self.contentString = text
    }

    // MARK: - TextField Tap Gesture

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        self.endEditing(true)
    }

    // MARK: - Content Methods

    
}
