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
        $0.backgroundColor = .blue
        $0.layer.cornerRadius = 0.5 * 39
        $0.clipsToBounds = true
    }
    
    let questionNumber = UILabel().then {
        $0.textColor = .white
    }
    
    private let questionLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    
    var answerTextField = UITextField().then {
        $0.layer.cornerRadius = 19
        $0.layer.masksToBounds = true
        $0.borderStyle = .none
        $0.backgroundColor = .lightGray.withAlphaComponent(0.5)
        $0.textAlignment = .center
    }
    
    var answerValue: String = ""
    
    var myAnswerWhenChecking = UILabel().then {
        $0.isHidden = true
        $0.textColor = .lightGray.withAlphaComponent(0.5)
    }
    
    init(frame: CGRect, idx: Int, question: String, answer: String) {
        super.init(frame: frame)
        questionNumber.text = "\(idx)"
        questionLabel.text = question
        answerValue = answer
        
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
            make.height.equalTo(120)
        }
        
        questionNumberView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.height.equalTo(39)
        }
        questionNumber.snp.makeConstraints { make in
            make.center.equalTo(questionNumberView)
        }
        
        questionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(questionNumberView.snp.centerY)
            make.leading.equalTo(questionNumberView.snp.trailing).offset(10)
        }
        
        answerTextField.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(38)
        }
        
        myAnswerWhenChecking.snp.makeConstraints { make in
            make.trailing.equalTo(answerTextField.snp.leading).offset(-10)
            make.centerY.equalTo(answerTextField.snp.centerY)
        }
    }
}
