//
//  WrongQuestionView.swift
//  Memorable
//
//  Created by 김현기 on 7/2/24.
//

import SnapKit
import Then
import UIKit

class WrongQuestionView: UIView {
    let questionNumberView = UIView().then {
        $0.backgroundColor = MemorableColor.Blue2
        $0.layer.cornerRadius = 0.5 * 32
        $0.clipsToBounds = true
    }
    
    let questionNumber = UILabel().then {
        $0.textColor = .white
    }
    
    private let questionLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    
    var answerTextField = UITextField().then {
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = true
        $0.borderStyle = .none
        $0.backgroundColor = MemorableColor.Gray5
        $0.textAlignment = .left
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: $0.frame.height))
        $0.leftViewMode = .always
    }
    
    var answerValue: String = ""
    
    var myAnswerWhenChecking = UILabel().then {
        $0.isHidden = true
        $0.textColor = MemorableColor.Gray1
        $0.font = MemorableFont.BodyCaption()
    }
    
    init(frame: CGRect, idx: Int, question: String, answer: String) {
        super.init(frame: frame)
        questionNumber.text = "\(idx)"
        questionLabel.text = question
        answerValue = answer
        
        answerTextField.delegate = self
        
        addSubViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubViews() {
        questionNumberView.addSubview(questionNumber)
        addSubview(questionNumberView)
        
        addSubview(questionLabel)
        addSubview(answerTextField)
        addSubview(myAnswerWhenChecking)
    }
    
    func setupConstraints() {
        snp.makeConstraints { make in
            make.height.equalTo(130)
        }
        
        questionNumberView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.height.equalTo(32)
        }
        questionNumber.snp.makeConstraints { make in
            make.center.equalTo(questionNumberView)
        }
        
        questionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(questionNumberView.snp.centerY)
            make.leading.equalTo(questionNumberView.snp.trailing).offset(10)
        }
        
        answerTextField.snp.makeConstraints { make in
            make.top.equalTo(questionNumberView.snp.bottom).offset(24)
            make.width.equalToSuperview()
            make.height.equalTo(48)
        }
        
        myAnswerWhenChecking.snp.makeConstraints { make in
            make.top.equalTo(answerTextField.snp.bottom).offset(5)
            make.leading.equalTo(answerTextField.snp.leading).offset(24)
        }
    }
}

extension WrongQuestionView: UITextFieldDelegate {
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
