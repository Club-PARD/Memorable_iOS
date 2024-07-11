//
//  StudyView.swift
//  Memorable
//
//  Created by 김현기 on 6/26/24.
//

import SnapKit
import Then
import UIKit

class WorkSheetView: UIView, UIScrollViewDelegate {
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

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.delegate = self
        return scrollView
    }()
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return workSheetContent
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
        let lines = question.components(separatedBy: .newlines)
        var answerIndex = 0

        for line in lines {
            let lineView = self.createNewLineView()
            self.containerView.addArrangedSubview(lineView)
            
            var remainingLine = line
            var currentLineWidth: CGFloat = 0

            while !remainingLine.isEmpty {
                if let range = answers.indices.contains(answerIndex) ? remainingLine.range(of: answers[answerIndex]) : nil {
                    // Add text before the answer
                    let prefixString = String(remainingLine[..<range.lowerBound])
                    self.addWordsToLineView(words: prefixString.split(separator: " "), to: lineView, currentLineWidth: &currentLineWidth)

                    // Add text field for the answer
                    let answer = answers[answerIndex]
                    let textField = self.createTextField(for: answer)
                    lineView.addArrangedSubview(textField)
                    currentLineWidth += textField.frame.width

                    remainingLine = String(remainingLine[range.upperBound...])
                    answerIndex += 1
                } else {
                    // Add remaining text
                    self.addWordsToLineView(words: remainingLine.split(separator: " "), to: lineView, currentLineWidth: &currentLineWidth)
                    break
                }
            }
        }

        return self.containerView
    }

    private func addWordsToLineView(words: [Substring], to lineView: UIStackView, currentLineWidth: inout CGFloat) {
        for word in words {
            let label = UILabel().then {
                $0.text = String(word) + " "
                $0.textColor = .black
                $0.textAlignment = .center
            }
            let labelWidth = label.intrinsicContentSize.width
            
            lineView.addArrangedSubview(label)
            currentLineWidth += labelWidth
        }
    }

    private func createTextField(for answer: String) -> UITextField {
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
            $0.placeholder = String(repeating: " ", count: answer.count)

            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 30))
            $0.leftView = paddingView
            $0.leftViewMode = .always
            $0.rightView = paddingView
            $0.rightViewMode = .always
        }
        self.userAnswers.append(textField)
        return textField
    }

    // 텍스트 길이에 따른 너비 계산 함수
    func calculateWidth(for text: String, minWidth: CGFloat = 80, maxWidth: CGFloat = 150) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 13)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
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
