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
        textField.layer.cornerRadius = 19
        textField.layer.masksToBounds = true
        textField.borderStyle = .none
        textField.backgroundColor = MemorableColor.Gray5
        textField.textAlignment = .center
        textField.textColor = MemorableColor.Black
        textField.font = MemorableFont.BodyCaption()
        return textField
    }()
    
    let correctAnswerView: UIView = {
        let correctAnswerView = UIView()
        correctAnswerView.backgroundColor = MemorableColor.Gray5
        correctAnswerView.layer.cornerRadius = 19
        correctAnswerView.layer.masksToBounds = true
        return correctAnswerView
    }()
    
    let correctAnswerLabel: UILabel = {
        let correctAnswerLabel = UILabel()
        correctAnswerLabel.font = MemorableFont.BodyCaption()
        correctAnswerLabel.textColor = MemorableColor.Blue1
        return correctAnswerLabel
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
        
        answerTextField.snp.makeConstraints { make in
            make.top.equalTo(questionNumber.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalToSuperview()
        }
    }
    
    func configure(with question: Question, questionNumberValue: Int) {
        questionNumber.text = "\(questionNumberValue)"
        questionLabel.text = question.question
        answerTextField.text = question.userAnswer
        
        correctAnswerLabel.text = question.answer
        userAnswerLabel.text = "내가 쓴 답: \(question.userAnswer ?? "")"  // Optional이 아닌 문자열로 설정
        
        // 답변 비교 및 색상 설정
        let normalizedCorrectAnswer = correctAnswerLabel.text?.lowercased().replacingOccurrences(of: " ", with: "") ?? ""
        
        if let userAnswerText = userAnswerLabel.text?.replacingOccurrences(of: "내가 쓴 답: ", with: "").lowercased().replacingOccurrences(of: " ", with: "") {
            if normalizedCorrectAnswer == userAnswerText {
                correctAnswerLabel.textColor = MemorableColor.Blue1
            } else {
                correctAnswerLabel.textColor = MemorableColor.Red
            }
        } else {
            correctAnswerLabel.textColor = MemorableColor.Red  // 기본적으로 불일치로 설정
        }
        
        // Add target to handle text changes
        answerTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }


    
    func replaceTextFieldWithLabels() {
        if answerTextField.isHidden {
                return
            }
        answerTextField.isHidden = true
        addSubview(correctAnswerView)
        correctAnswerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(38)
        }
        
        addSubview(correctAnswerLabel)
        correctAnswerLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(correctAnswerView)
        }
        
        addSubview(userAnswerLabel)
        userAnswerLabel.snp.makeConstraints { make in
            make.leading.equalTo(correctAnswerView.snp.leading).offset(-128)
            make.centerY.equalTo(correctAnswerView.snp.centerY)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // Validate and update the userAnswer property
        guard textField.text != nil else { return }
    }
}
