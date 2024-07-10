//
//  StudyView.swift
//  Memorable
//
//  Created by 김현기 on 6/26/24.
//

import SnapKit
import Then
import UIKit

class WorkSheetView: UIView {
    // MARK: - Properties

    var userAnswers: [UITextField] = []

    private var viewWidth: CGFloat = 0

    // Create a container view for the text and text fields
    let containerView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .leading
    }

    private var previousLineView: UIStackView?
    private var previousLineViewWidth: CGFloat = 0

    private let contentView = UIView().then {
        $0.layer.cornerRadius = 40
    }

    private let scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = true
    }

    private var contentString = ""

    private var answers: [String] = []

    private var workSheetContent = UIView()

    // MARK: - Initialization

    init(frame: CGRect, viewWidth: CGFloat, text: String, answers: [String]) {
        super.init(frame: frame)
        self.viewWidth = viewWidth
        self.contentString = text
        self.answers = answers

        self.workSheetContent = self.createFillInTheBlanksUI(
            question: self.contentString,
            answers: self.answers
        )

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

        self.workSheetContent.snp.makeConstraints {
            $0.top.equalTo(self.scrollView)
            $0.leading.equalTo(self.scrollView).offset(32)
            $0.trailing.equalTo(self.scrollView).offset(-32)
            $0.bottom.equalTo(self.scrollView)
            $0.width.equalTo(self.contentView).offset(-64)
        }
    }

    func addSubViewsInScrollView() {
        self.scrollView.addSubview(self.workSheetContent)
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

    func createFillInTheBlanksUI(question: String, answers: [String]) -> UIView {
        // Split the question and replace answers with text fields
        var remainingQuestion = question
        var currentLineView: UIStackView?
        var currentLineWidth: CGFloat = 0

        for answer in answers {
            guard let range = remainingQuestion.range(of: answer) else { continue }

            // Split the question into prefix and remaining parts
            let prefixString = String(remainingQuestion[..<range.lowerBound])
            remainingQuestion = String(remainingQuestion[range.upperBound...])

            // Add prefix label
            let words = prefixString.split(separator: " ")

            for word in words {
                let label = UILabel().then {
                    $0.text = String(word) + " "
                    $0.textColor = .black
                    $0.textAlignment = .center
                }
                let labelWidth = label.intrinsicContentSize.width

                if currentLineWidth + labelWidth < self.viewWidth - 250 {
                    if currentLineView == nil {
                        currentLineView = self.createNewLineView()
                        self.containerView.addArrangedSubview(currentLineView!)
                    }
                    currentLineView!.addArrangedSubview(label)
                    currentLineWidth += labelWidth
                }
                // viewWidth 초과했을떄
                else {
                    // 새로운 라인 시작
                    currentLineView = self.createNewLineView()
                    self.containerView.addArrangedSubview(currentLineView!)
                    currentLineView!.addArrangedSubview(label)

                    currentLineWidth = labelWidth
                }
            }

            // 텍스트필드 생성 부분 수정
            let textFieldWidth = self.calculateWidth(for: answer)
            let textField = UITextField().then {
                $0.delegate = self
                $0.textAlignment = .center
                $0.font = .systemFont(ofSize: 13)
                $0.layer.cornerRadius = 15
                $0.backgroundColor = MemorableColor.Gray5

                $0.snp.makeConstraints { make in
                    make.width.equalTo(textFieldWidth)
                    make.height.equalTo(30)
                }
                $0.placeholder = String(repeating: " ", count: answer.count) // 답변 길이만큼 공백으로 플레이스홀더 설정

                // 좌우 여백 추가
                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 30))
                $0.leftView = paddingView
                $0.leftViewMode = .always
                $0.rightView = paddingView
                $0.rightViewMode = .always
            }
            self.userAnswers.append(textField)

            if currentLineWidth + textFieldWidth < self.viewWidth - 250 {
                if currentLineView == nil {
                    currentLineView = self.createNewLineView()
                    self.containerView.addArrangedSubview(currentLineView!)
                }
                currentLineView!.addArrangedSubview(textField)
                currentLineWidth += textFieldWidth
            }
            // viewWidth 초과했을떄
            else {
                // 새로운 라인 시작
                currentLineView = self.createNewLineView()
                self.containerView.addArrangedSubview(currentLineView!)
                currentLineView!.addArrangedSubview(textField)

                currentLineWidth = textFieldWidth
            }

            if self.previousLineViewWidth == 0 {
                self.previousLineView = currentLineView
                self.previousLineViewWidth = currentLineWidth
            }
        }

        // Add the remaining part of the question as a suffix label
        let words = remainingQuestion.split(separator: " ")

        for word in words {
            let label = UILabel().then {
                $0.text = String(word) + ""
                $0.textColor = .black
                $0.textAlignment = .center
            }
            let labelWidth = label.intrinsicContentSize.width

            if currentLineWidth + labelWidth < self.viewWidth - 250 {
                if currentLineView == nil {
                    currentLineView = self.createNewLineView()
                    self.containerView.addArrangedSubview(currentLineView!)
                }
                currentLineView!.addArrangedSubview(label)
                currentLineWidth += labelWidth
            }
            // viewWidth 초과했을떄
            else {
                // 새로운 라인 시작
                currentLineView = self.createNewLineView()
                self.containerView.addArrangedSubview(currentLineView!)
                currentLineView!.addArrangedSubview(label)

                currentLineWidth = labelWidth
            }
        }

        return self.containerView
    }

    // 텍스트 길이에 따른 너비 계산 함수
    func calculateWidth(for text: String, minWidth: CGFloat = 80, maxWidth: CGFloat = 150) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 13)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        print("SIZE: \(size)")
        return min(max(size.width + 50, minWidth), maxWidth) // 30은 여백을 위한 추가 너비
    }

    func calculateLineWidth(_ lineView: UIStackView) -> CGFloat {
        var width: CGFloat = 0
        for arrangedSubview in lineView.arrangedSubviews {
            let viewWidth = arrangedSubview.intrinsicContentSize.width
            width += viewWidth
        }

        return width
    }

    func createNewLineView() -> UIStackView {
        let lineView = UIStackView()
        lineView.axis = .horizontal
        lineView.spacing = 8
        lineView.alignment = .center

        return lineView
    }
}

extension WorkSheetView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = MemorableColor.Yellow3
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = MemorableColor.Gray5
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
