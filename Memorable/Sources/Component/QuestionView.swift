//
//  TestQuestionConponent.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/28/24.
//

import UIKit
import SnapKit

class QuestionView: UIView {

    
    let questionNumberView: UIView = {
        let view = UIView()
        view.backgroundColor = MemorableColor.Blue2
        view.layer.cornerRadius = 0.5 * 25
        view.clipsToBounds = true
        return view
    }()
    
    let questionNumber: UILabel = {
        let label = UILabel()
        label.textColor = MemorableColor.White
        label.font = MemorableFont.BodyCaption()
        return label
    }()
    
    let questionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = MemorableColor.Black
        label.font = MemorableFont.Body1()
        return label
    }()
    
    let answerTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 25
        textField.layer.masksToBounds = true
        textField.borderStyle = .none
        textField.backgroundColor = MemorableColor.Gray5
        textField.textAlignment = .left
        textField.textColor = MemorableColor.Black
        textField.font = MemorableFont.Body1()
        textField.attributedPlaceholder = NSAttributedString(
            string: "답안을 입력하세요...",
            attributes: [
                .foregroundColor: MemorableColor.Gray3 ?? .lightGray,
                .font: MemorableFont.Body1()
            ]
        )
        
        // 내부 leading padding 설정
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    let correctAnswerView: UIView = {
        let correctAnswerView = UIView()
        correctAnswerView.backgroundColor = MemorableColor.Gray5
        correctAnswerView.layer.cornerRadius = 25
        correctAnswerView.layer.masksToBounds = true
        return correctAnswerView
    }()
    
    let correctAnswerLabel: UILabel = {
        let correctAnswerLabel = UILabel()
        correctAnswerLabel.font = MemorableFont.BodyCaption()
        correctAnswerLabel.textColor = MemorableColor.Blue1
        return correctAnswerLabel
    }()
    
    let infoIcon: UIImageView = {
        let infoIcon = UIImageView(image: UIImage(named: "info-circle"))
        return infoIcon
    }()
    
    let userAnswerLabel: UILabel = {
        let userAnswerLabel = UILabel()
        userAnswerLabel.textColor = MemorableColor.Gray1
        userAnswerLabel.font = MemorableFont.BodyCaption()
        return userAnswerLabel
    }()
    
    let answerLengthLabel: UILabel = {
        let answerLenghLabel = UILabel()
        answerLenghLabel.textColor = MemorableColor.Gray1
        answerLenghLabel.font = MemorableFont.BodyCaption()
        return answerLenghLabel
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTextFieldCallbacks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = MemorableColor.White
        addSubview(questionNumberView)
        questionNumberView.addSubview(questionNumber)
        addSubview(questionLabel)
        addSubview(answerTextField)
        addSubview(infoIcon)
        addSubview(answerLengthLabel)
        
        questionNumberView.snp.makeConstraints{ make in
            make.leading.equalTo(0)
            make.top.equalTo(0)
            make.width.height.equalTo(25)
        }
        
        questionNumber.snp.makeConstraints{ make in
            make.centerX.centerY.equalToSuperview()
        }
        
        questionLabel.snp.makeConstraints { make in
            make.leading.equalTo(questionNumberView.snp.trailing).offset(8)
            make.centerY.equalTo(questionNumberView)
        }
        
        infoIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-2)
            make.width.height.equalTo(16)
        }
        
        answerLengthLabel.snp.makeConstraints { make in
            make.centerY.equalTo(infoIcon)
            make.leading.equalTo(infoIcon.snp.trailing).offset(2)
        }
        
        answerTextField.snp.makeConstraints { make in
            make.top.equalTo(questionNumber.snp.bottom).offset(16)
//            make.bottom.equalTo(answerLengthLabel.snp.top).offset(-8)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    func configure(with question: Question, questionNumberValue: Int, userAnswer: String?, isCorrect: Bool?) {
        questionNumber.text = "\(questionNumberValue)"
        questionLabel.text = question.question
        answerTextField.text = userAnswer ?? question.userAnswer
        
        correctAnswerLabel.text = question.answer
        userAnswerLabel.text = "사용자가 입력한 답: \(userAnswer ?? question.userAnswer)"
        
        answerLengthLabel.text = "\(question.answer.count)글자로 입력해주세요"
        
        if let isCorrect = isCorrect {
            if isCorrect {
                correctAnswerLabel.textColor = MemorableColor.Blue1
            } else {
                correctAnswerLabel.textColor = MemorableColor.Red
            }
        } else {
            correctAnswerLabel.textColor = MemorableColor.Blue1
        }
        
        // 제출 상태에 따라 UI 업데이트
        if isCorrect != nil {
            replaceTextFieldWithLabels()
        } else {
            resetView(withUserAnswer: userAnswer ?? question.userAnswer)
        }
    }
    
    func replaceTextFieldWithLabels() {
        if answerTextField.isHidden {
            return
        }
        answerTextField.isHidden = true
        answerLengthLabel.isHidden = true
        
        addSubview(correctAnswerView)
        correctAnswerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(questionNumberView.snp.bottom).offset(16)
            make.height.equalTo(50)
        }
        
        addSubview(correctAnswerLabel)
        correctAnswerLabel.snp.makeConstraints { make in
            make.leading.equalTo(correctAnswerView).offset(26)
            make.centerY.equalTo(correctAnswerView)
        }
        
        addSubview(userAnswerLabel)
        userAnswerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(infoIcon)
            make.leading.equalTo(infoIcon.snp.trailing).offset(2)
        }
        
        // 사용자 답변 업데이트
        userAnswerLabel.text = "사용자가 입력한 답: \(answerTextField.text ?? "")"
    }
    
    func resetView(withUserAnswer userAnswer: String? = nil) {
        answerTextField.isHidden = false
        answerLengthLabel.isHidden = false
        correctAnswerView.removeFromSuperview()
        correctAnswerLabel.removeFromSuperview()
        userAnswerLabel.removeFromSuperview()
        
        // 사용자 답변 복원
        answerTextField.text = userAnswer
        
        // 텍스트 필드 상태 초기화
        answerTextField.backgroundColor = MemorableColor.Gray5
        answerTextField.attributedPlaceholder = NSAttributedString(
            string: "답안을 입력하세요...",
            attributes: [
                .foregroundColor: MemorableColor.Gray3 ?? .lightGray,
                .font: MemorableFont.Body1()
            ]
        )
    }
    
    func setupTextFieldCallbacks() {
        answerTextField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        answerTextField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }

    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = MemorableColor.Yellow3
        textField.attributedPlaceholder = NSAttributedString(
            string: "",
            attributes: [
                .foregroundColor: MemorableColor.Gray3 ?? .lightGray,
                .font: MemorableFont.Body1()
            ]
        )
    }

    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = MemorableColor.Gray5
        textField.attributedPlaceholder = NSAttributedString(
            string: "답안을 입력하세요...",
            attributes: [
                .foregroundColor: MemorableColor.Gray3 ?? .lightGray,
                .font: MemorableFont.Body1()
            ]
        )
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // Validate and update the userAnswer property
        guard textField.text != nil else { return }
    }
}
