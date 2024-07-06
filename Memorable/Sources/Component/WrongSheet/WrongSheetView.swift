//
//  WrongSheetView.swift
//  Memorable
//
//  Created by 김현기 on 7/1/24.
//

import UIKit

class WrongSheetView: UIView {
    // MARK: - Properties

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

    private var QnA: [Question] = []

    private var wrongSheetContent = UIView()

    var wrongQuestionViews: [WrongQuestionView] = []

    // MARK: - Initialization

    init(frame: CGRect, QnA: [Question]) {
        super.init(frame: frame)
        self.QnA = QnA

        self.createWrongSheetContent()

        self.setupTapGesture()
        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Content Methods

    func createWrongSheetContent() {
        let questionLength = self.QnA.count
        var previousView: UIView?

        for idx in 0 ..< questionLength {
            let wrongQuestionView = WrongQuestionView(
                frame: CGRect.zero,
                idx: idx + 1,
                question: self.QnA[idx].question,
                answer: self.QnA[idx].answer
            )
            self.wrongQuestionViews.append(wrongQuestionView)

            self.wrongSheetContent.addSubview(wrongQuestionView)

            wrongQuestionView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.width.equalToSuperview()

                if let previousView = previousView {
                    make.top.equalTo(previousView.snp.bottom).offset(20) // 뷰 사이의 간격
                } else {
                    make.top.equalToSuperview()
                }

                if idx == questionLength - 1 {
                    make.bottom.equalToSuperview()
                }
            }

            previousView = wrongQuestionView
        }
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
            $0.top.equalTo(self.contentView).offset(30)
            $0.bottom.equalTo(self.contentView).offset(-30)
        }

        self.wrongSheetContent.snp.makeConstraints {
            $0.top.equalTo(self.scrollView).offset(24)
//            $0.leading.equalTo(self.scrollView).offset(32)
//            $0.trailing.equalTo(self.scrollView).offset(-32)
            $0.bottom.equalTo(self.scrollView)
            $0.width.equalTo(self.contentView).offset(-64)
            $0.centerX.equalToSuperview()
        }
    }

    func addSubViewsInScrollView() {
        self.scrollView.addSubview(self.wrongSheetContent)
    }

    // MARK: - TextField Tap Gesture

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        self.endEditing(true)
    }
}
