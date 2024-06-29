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
        view.backgroundColor = .blue
        view.layer.cornerRadius = 0.5 * 39
        view.clipsToBounds = true
        return view
    }()
    
    let questionNumber: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
    let questionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let answerTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(questionNumberView)
        questionNumberView.addSubview(questionNumber)
        addSubview(questionLabel)
        addSubview(answerTextField)
        
        questionNumberView.snp.makeConstraints{ make in
            make.leading.equalTo(0)
            make.top.equalTo(3.5)
            make.width.height.equalTo(39)
        }
        
        questionNumber.snp.makeConstraints{ make in
            make.centerX.centerY.equalToSuperview()
        }
        
        questionLabel.snp.makeConstraints { make in
            make.leading.equalTo(questionNumberView.snp.trailing).offset(8)
            make.centerY.equalTo(questionNumberView)
        }
        
        answerTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalToSuperview().offset(842)
        }
    }
    
    func configure(with question: Question, questionNumberValue: Int) {
        questionNumber.text = "\(questionNumberValue)"
        questionLabel.text = question.question
        answerTextField.text = question.answer
    }
}
