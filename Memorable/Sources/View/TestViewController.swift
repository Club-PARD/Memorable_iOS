//
//  TestViewController.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/28/24.
//

import SnapKit
import Then
import UIKit

class TestViewController: UIViewController {
    private let questionManager = QuestionManager()
    private var currentPage = 0
    private let questionsPerPage = 3
    
    private var questionViews: [QuestionView] = []
    private var nextButton: UIButton!
    private var previousButton: UIButton!
    private var testSheetView: UIView?
    
    private var containerView = UIView().then {
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 40
        $0.clipsToBounds = true
    }
    
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "applogo2")
    }

    private let backButton = UIButton().then {
        let image = UIImage(systemName: "chevron.left")
        $0.setImage(image, for: .normal)
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 0.5 * 44
        $0.clipsToBounds = true
    }

    private let doneButton = UIButton().then {
        $0.setTitle("학습완료", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
    }

    private let titleLabel = UILabel().then {
        $0.text = "사회학개론 1-1"
        $0.font = UIFont.systemFont(ofSize: 34, weight: .bold)
    }

    private let categoryLabel = UILabel().then {
        $0.text = "카테고리명"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        $0.textColor = .gray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        setupUI()
        loadQuestions()
        updateUI()
    }
    
    private func setupUI() {
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(27)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.width.equalTo(174)
            make.height.equalTo(21.92)
        }
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(logoImageView.snp.trailing).offset(22)
            make.height.equalTo(44)
            make.width.equalTo(44)
        }
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-11)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.height.equalTo(44)
            make.width.equalTo(132)
        }

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(28)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
        
        view.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(12)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        
        // Container view
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(149)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(540)
        }
        
        // Question views
        for _ in 0 ..< 3 {
            let questionView = QuestionView()
            containerView.addSubview(questionView)
            questionViews.append(questionView)
        }
        
        // Layout question views
        for (index, questionView) in questionViews.enumerated() {
            questionView.snp.makeConstraints { make in
                if index == 0 {
                    make.top.equalTo(containerView).offset(74) // 첫 번째 문제는 상단에서 74 떨어짐
                } else {
                    make.top.equalTo(questionViews[index - 1].snp.bottom).offset(10) // 나머지 문제들은 이전 문제와 10만큼 떨어짐
                }
                make.leading.trailing.equalTo(containerView).offset(52)
                make.height.equalTo(95)
            }
        }
        
        // Buttons
        previousButton = UIButton(type: .system)
        previousButton.setTitle("이전", for: .normal)
        previousButton.addTarget(self, action: #selector(previousPage), for: .touchUpInside)
        
        nextButton = UIButton(type: .system)
        nextButton.setTitle("다음", for: .normal)
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [previousButton, nextButton])
        buttonStack.distribution = .fillEqually
        
        view.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }
    
    private func loadQuestions() {
        let jsonData: [Int: [String: String]] = [
            1: ["question": "어떤 특정한 행동을 기대하는 것을 무엇이라고 하나요?", "기대치": ""],
            2: ["question": "공통의 가치관을 가진 사람들이 교류하는 집합체를 무엇이라고 하나요?", "answer": "Social group"],
            3: ["question": "정기적으로 상호작용하지만 사회조직에 속해있지 않은 간단한 집합체를 무엇이라고 하나요?", "answer": "Aggregate"],
            4: ["question": "공통의 특성을 가진 사람들의 집합체는 무엇인가요?", "answer": "Social category"],
            5: ["question": "집단에 속하는 구성원들이 공유하는 정체성을 무엇이라고 하나요?", "answer": "정체성"],
            6: ["question": "어떤 특정한 행동을 기대하는 것을 무엇이라고 하나요?", "기대치": ""],
            7: ["question": "공통의 가치관을 가진 사람들이 교류하는 집합체를 무엇이라고 하나요?", "answer": "Social group"],
            8: ["question": "정기적으로 상호작용하지만 사회조직에 속해있지 않은 간단한 집합체를 무엇이라고 하나요?", "answer": "Aggregate"],
            9: ["question": "공통의 특성을 가진 사람들의 집합체는 무엇인가요?", "answer": "Social category"],
            10: ["question": "집단에 속하는 구성원들이 공유하는 정체성을 무엇이라고 하나요?", "answer": "정체성"],
            11: ["question": "어떤 특정한 행동을 기대하는 것을 무엇이라고 하나요?", "기대치": ""],
            12: ["question": "공통의 가치관을 가진 사람들이 교류하는 집합체를 무엇이라고 하나요?", "answer": "Social group"],
            13: ["question": "정기적으로 상호작용하지만 사회조직에 속해있지 않은 간단한 집합체를 무엇이라고 하나요?", "answer": "Aggregate"],
            14: ["question": "공통의 특성을 가진 사람들의 집합체는 무엇인가요?", "answer": "Social category"],
            15: ["question": "집단에 속하는 구성원들이 공유하는 정체성을 무엇이라고 하나요?", "answer": "정체성"],
            16: ["question": "어떤 특정한 행동을 기대하는 것을 무엇이라고 하나요?", "기대치": ""],
            17: ["question": "공통의 가치관을 가진 사람들이 교류하는 집합체를 무엇이라고 하나요?", "answer": "Social group"],
            18: ["question": "정기적으로 상호작용하지만 사회조직에 속해있지 않은 간단한 집합체를 무엇이라고 하나요?", "answer": "Aggregate"],
            19: ["question": "공통의 특성을 가진 사람들의 집합체는 무엇인가요?", "answer": "Social category"],
            20: ["question": "집단에 속하는 구성원들이 공유하는 정체성을 무엇이라고 하나요?", "answer": "정체성"]
        ]
        questionManager.parseQuestions(from: jsonData)
        print("Loaded questions: \(questionManager.questions.count)")
    }
    
    private func updateUI() {
        print("Updating UI, current page: \(currentPage)")
        let startIndex = currentPage * questionsPerPage
        for (index, questionView) in questionViews.enumerated() {
            let questionIndex = startIndex + index
            if questionIndex < questionManager.questions.count {
                let question = questionManager.questions[questionIndex]
                questionView.configure(with: question, questionNumberValue: index + 1)
                questionView.isHidden = false
            } else {
                questionView.isHidden = true
            }
        }
        
        previousButton.isEnabled = currentPage > 0
        nextButton.isEnabled = (currentPage + 1) * questionsPerPage < questionManager.questions.count
    }
    
    @objc private func nextPage() {
        saveCurrentAnswers()
        currentPage += 1
        updateUI()
    }
    
    @objc private func previousPage() {
        saveCurrentAnswers()
        currentPage -= 1
        updateUI()
    }
    
    private func saveCurrentAnswers() {
        let startIndex = currentPage * questionsPerPage
        for (index, questionView) in questionViews.enumerated() {
            let questionIndex = startIndex + index
            if questionIndex < questionManager.questions.count {
                questionManager.questions[questionIndex].answer = questionView.answerTextField.text ?? ""
            }
        }
    }
}
