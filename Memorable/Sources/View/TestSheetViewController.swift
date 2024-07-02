//
//  TestViewController.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/28/24.
//

import SnapKit
import Then
import UIKit

class TestSheetViewController: UIViewController {
    private let questionManager = QuestionManager()
    private var currentPage = 0
    private let questionsPerPage = 3
    
    private var questionViews: [QuestionView] = []
    private var nextButton: UIButton!
    private var previousButton: UIButton!
    private var testSheetView: UIView?
    private var progressBarView: ProgressBarView?
    
    private var containerView = UIView().then {
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 40
        $0.clipsToBounds = true
    }
    
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "applogo-v2")
    }
    
    private let backButton = UIButton().then {
        let image = UIImage(systemName: "chevron.left")
        $0.setImage(image, for: .normal)
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 0.5 * 44
        $0.clipsToBounds = true
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
    
    private let pagingLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .gray
    }
    
    private let submitButton = UIButton().then {
        $0.setTitle("제출하기", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
    }
    
    private let retryButton = UIButton().then {
        $0.setTitle("재응시하기", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private let sendWrongAnswersButton = UIButton().then {
        $0.setTitle("오답노트 보내기", for: .normal)
        $0.backgroundColor = .systemGreen
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private let remakeButton = UIButton().then {
        $0.setTitle("재추출하기", for: .normal)
        $0.backgroundColor = .systemGreen
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private let resultLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        $0.textColor = .black
        $0.isHidden = true // 초기에는 숨김 처리
    }
    
    private let scoreLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .black
        $0.isHidden = true // 초기에는 숨김 처리
        $0.text = "점수"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .lightGray
        setupUI()
        loadQuestions()
        updateUI()
        
        // 키보드 내리기 (작성 밖 터치)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(51)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.width.equalTo(126)
            make.height.equalTo(15.07)
        }
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalTo(logoImageView.snp.trailing).offset(22)
            make.height.equalTo(44)
            make.width.equalTo(44)
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
            make.top.equalToSuperview().offset(173)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(540)
        }
        
        view.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.top).offset(-28)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
        
        view.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints{ make in
            make.trailing.equalTo(resultLabel.snp.leading).offset(-12)
            make.centerY.equalTo(resultLabel)
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
                make.leading.equalTo(containerView).offset(52)
                make.trailing.equalTo(containerView).offset(-52)
                make.height.equalTo(95)
                
                switch index {
                case 0: // 첫 번째 문제
                    make.top.equalTo(containerView).offset(74)
                case 1: // 두 번째 문제
                    make.centerY.equalTo(containerView)
                case 2: // 세 번째 문제
                    make.bottom.equalTo(containerView).offset(-74)
                default:
                    break
                }
            }
        }
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        containerView.addSubview(pagingLabel)
        pagingLabel.snp.makeConstraints{ make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        // Previous Button
        previousButton = UIButton()
        let previousButtonImage = UIImage(systemName: "chevron.left")
        previousButton.setImage(previousButtonImage, for: .normal)
        previousButton.backgroundColor = .white
        previousButton.contentMode = .scaleAspectFit
        previousButton.layer.cornerRadius = 32 // 64의 절반
        previousButton.clipsToBounds = true
        previousButton.addTarget(self, action: #selector(previousPage), for: .touchUpInside)
        
        view.addSubview(previousButton)
        previousButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-21)
            make.width.height.equalTo(64)
        }
        
        // Next Button
        nextButton = UIButton()
        let nextButtonImage = UIImage(systemName: "chevron.right")
        nextButton.setImage(nextButtonImage, for: .normal)
        nextButton.backgroundColor = .white
        nextButton.contentMode = .scaleAspectFit
        nextButton.layer.cornerRadius = 32 // 64의 절반
        nextButton.clipsToBounds = true
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-21)
            make.width.height.equalTo(64)
        }
        
        // Submit Button
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-31)
            make.width.equalTo(132)
            make.height.equalTo(44)
        }
        submitButton.addTarget(self, action: #selector(submitAnswers), for: .touchUpInside)
        submitButton.isHidden = true  // 초기에는 숨김 처리
        
        view.addSubview(sendWrongAnswersButton)
        sendWrongAnswersButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-31)
            make.width.equalTo(132)
            make.height.equalTo(44)
        }
        sendWrongAnswersButton.addTarget(self, action: #selector(sendWrongAnswers), for: .touchUpInside)
        
        view.addSubview(retryButton)
        retryButton.snp.makeConstraints { make in
            make.trailing.equalTo(sendWrongAnswersButton.snp.leading).offset(-8)
            make.bottom.equalToSuperview().offset(-31)
            make.width.equalTo(132)
            make.height.equalTo(44)
        }
        retryButton.addTarget(self, action: #selector(retryTest), for: .touchUpInside)
        
        view.addSubview(remakeButton)
        remakeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(55)
            make.trailing.equalToSuperview().offset(-24)
            make.width.equalTo(132)
            make.height.equalTo(44)
        }
        remakeButton.addTarget(self, action: #selector(remakeTest), for: .touchUpInside)
    }
    
    private func loadQuestions() {
        let jsonData: [Int: [String: String]] = [
            1: ["question": "어떤 특정한 행동을 기대하는 것을 무엇이라고 하나요?", "answer": "기대치", "userAnswer": ""],
            2: ["question": "공통의 가치관을 가진 사람들이 교류하는 집합체를 무엇이라고 하나요?", "answer": "Social group", "userAnswer": ""],
            3: ["question": "정기적으로 상호작용하지만 사회조직에 속해있지 않은 간단한 집합체를 무엇이라고 하나요?", "answer": "Aggregate", "userAnswer": ""],
            4: ["question": "공통의 특성을 가진 사람들의 집합체는 무엇인가요?", "answer": "Social category", "userAnswer": ""],
            5: ["question": "집단에 속하는 구성원들이 공유하는 정체성을 무엇이라고 하나요?", "answer": "정체성", "userAnswer": ""],
            6: ["question": "어떤 특정한 행동을 기대하는 것을 무엇이라고 하나요?", "answer": "기대치", "userAnswer": ""],
            7: ["question": "공통의 가치관을 가진 사람들이 교류하는 집합체를 무엇이라고 하나요?", "answer": "Social group", "userAnswer": ""],
            8: ["question": "정기적으로 상호작용하지만 사회조직에 속해있지 않은 간단한 집합체를 무엇이라고 하나요?", "answer": "Aggregate", "userAnswer": ""],
            9: ["question": "공통의 특성을 가진 사람들의 집합체는 무엇인가요?", "answer": "Social category", "userAnswer": ""],
            10: ["question": "집단에 속하는 구성원들이 공유하는 정체성을 무엇이라고 하나요?", "answer": "정체성", "userAnswer": ""],
            11: ["question": "어떤 특정한 행동을 기대하는 것을 무엇이라고 하나요?", "answer": "기대치", "userAnswer": ""],
            12: ["question": "공통의 가치관을 가진 사람들이 교류하는 집합체를 무엇이라고 하나요?", "answer": "Social group", "userAnswer": ""],
            13: ["question": "정기적으로 상호작용하지만 사회조직에 속해있지 않은 간단한 집합체를 무엇이라고 하나요?", "answer": "Aggregate", "userAnswer": ""],
            14: ["question": "공통의 특성을 가진 사람들의 집합체는 무엇인가요?", "answer": "Social category", "userAnswer": ""],
            15: ["question": "집단에 속하는 구성원들이 공유하는 정체성을 무엇이라고 하나요?", "answer": "정체성", "userAnswer": ""],
            16: ["question": "어떤 특정한 행동을 기대하는 것을 무엇이라고 하나요?", "answer": "기대치", "userAnswer": ""],
            17: ["question": "공통의 가치관을 가진 사람들이 교류하는 집합체를 무엇이라고 하나요?", "answer": "Social group", "userAnswer": ""],
            18: ["question": "정기적으로 상호작용하지만 사회조직에 속해있지 않은 간단한 집합체를 무엇이라고 하나요?", "answer": "Aggregate", "userAnswer": ""],
            19: ["question": "공통의 특성을 가진 사람들의 집합체는 무엇인가요?", "answer": "Social category", "userAnswer": ""],
            20: ["question": "집단에 속하는 구성원들이 공유하는 정체성을 무엇이라고 하나요?", "answer": "정체성", "userAnswer": ""]
            
            
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
                questionView.configure(with: question, questionNumberValue: questionIndex + 1)
                questionView.isHidden = false
            } else {
                questionView.isHidden = true
            }
        }
        
        // 전체 페이지 수 계산
        let totalPages = (questionManager.questions.count + questionsPerPage - 1) / questionsPerPage
        
        // pagingLabel 업데이트
        pagingLabel.text = "\(currentPage + 1)/\(totalPages)"
        
        // 이전 버튼 숨기기/보이기
        previousButton.isHidden = currentPage == 0
        
        // 다음 버튼과 제출하기 버튼 처리
        let isLastPage = currentPage == totalPages - 1
        nextButton.isHidden = isLastPage
        submitButton.isHidden = !isLastPage
        
        retryButton.isHidden = !isLastPage || resultLabel.isHidden
        sendWrongAnswersButton.isHidden = !isLastPage || resultLabel.isHidden
        remakeButton.isHidden = !isLastPage || resultLabel.isHidden
        
        // 기존 progressBarView가 있다면 제거
        progressBarView?.removeFromSuperview()
        
        // 새로운 progressBarView 생성 및 추가
        let newProgressBarView = ProgressBarView(frame: .zero, totalPages: totalPages, currentPage: currentPage + 1)
        view.addSubview(newProgressBarView)
        newProgressBarView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-49)
            make.centerX.equalToSuperview()
        }
        
        // progressBarView 업데이트
        progressBarView = newProgressBarView
        progressBarView?.updateCurrentPage(currentPage + 1)
    }
    
    private func saveCurrentAnswers() {
        let startIndex = currentPage * questionsPerPage
        for (index, questionView) in questionViews.enumerated() {
            let questionIndex = startIndex + index
            if questionIndex < questionManager.questions.count {
                questionManager.questions[questionIndex].userAnswer = questionView.answerTextField.text ?? ""
            }
        }
    }
    
    private func setupProgressBar() {
        let totalPages = (questionManager.questions.count + questionsPerPage - 1) / questionsPerPage
        let newProgressBarView = ProgressBarView(frame: .zero, totalPages: totalPages, currentPage: 1)
        view.addSubview(newProgressBarView)
        
        newProgressBarView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(300) // 적절한 너비로 조정
            make.height.equalTo(4)
        }
        
        progressBarView = newProgressBarView
    }
    
    private func showSubmitAlert() {
        let alertController = UIAlertController(title: "시험지 제출", message: "시험지를 제출하시겠습니까?\n결과분석 페이지로 이동합니다.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.saveCurrentAnswers()
            self.replaceTextFieldsWithLabels()
            self.printAnswers()
            self.checkAnswersAndShowResult()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            // Handle cancel action
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showRemakeAlert() {
        let alertController = UIAlertController(title: "새로운 문제풀기", message: "문제를 새롭게 생성하시겠습니까?\n이 작업은 파일 당 1회만 가능합니다.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            // Handle cancel action
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func replaceTextFieldsWithLabels() {
        // 현재 페이지의 모든 질문 뷰에 대해 적용
        for (index, questionView) in questionViews.enumerated() {
            let questionIndex = currentPage * questionsPerPage + index
            if questionIndex < questionManager.questions.count {
                let question = questionManager.questions[questionIndex]
                questionView.configure(with: question, questionNumberValue: questionIndex + 1)
                questionView.replaceTextFieldWithLabels()
            }
        }
        
        // 다른 페이지의 질문들에 대해서도 변경 적용
        for (index, question) in questionManager.questions.enumerated() {
            let pageIndex = index / questionsPerPage
            let questionViewIndex = index % questionsPerPage
            
            if pageIndex != currentPage {
                let questionView = questionViews[questionViewIndex]
                questionView.configure(with: question, questionNumberValue: index + 1)
                questionView.replaceTextFieldWithLabels()
            }
        }
    }
    
    private func printAnswers() {
        for (index, question) in questionManager.questions.enumerated() {
            print("질문 \(index + 1) - 정답: \(question.answer), 쓴 답: \(question.userAnswer)")
        }
    }
    
    private func checkAnswersAndShowResult() {
        var correctAnswers = 0
        let totalQuestions = questionManager.questions.count
        
        for question in questionManager.questions {
            let normalizedCorrectAnswer = question.answer.lowercased().replacingOccurrences(of: " ", with: "")
            let normalizedUserAnswer = question.userAnswer.lowercased().replacingOccurrences(of: " ", with: "")
            
            if normalizedCorrectAnswer == normalizedUserAnswer {
                correctAnswers += 1
            }
        }
        
        resultLabel.text = "\(correctAnswers)/\(totalQuestions)"
        resultLabel.isHidden = false
        
        // 결과 애니메이션
        resultLabel.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.resultLabel.alpha = 1
        }
        
        // 버튼 상태 변경
        submitButton.isHidden = true
        retryButton.isHidden = false
        sendWrongAnswersButton.isHidden = false
        remakeButton.isHidden = false
        
        printAnswers()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
    
    @objc private func submitAnswers() {
        showSubmitAlert()
    }
    
    @objc private func retryTest() {
        // 모든 답변 초기화
        for index in 0..<questionManager.questions.count {
            questionManager.questions[index].userAnswer = ""
        }
        
        // 현재 페이지를 첫 페이지로 리셋
        currentPage = 0
        
        // 결과 레이블 숨기기
        resultLabel.isHidden = true
        
        // 제출하기 버튼 표시, 재응시하기와 오답노트 보내기 버튼 숨기기
        submitButton.isHidden = false
        retryButton.isHidden = true
        sendWrongAnswersButton.isHidden = true
        
        // 이전/다음 버튼 상태 리셋
        previousButton.isHidden = false
        nextButton.isHidden = false
        
        // QuestionView들의 상태 리셋
        for questionView in questionViews {
            questionView.answerTextField.isHidden = false
            questionView.answerTextField.text = ""
            questionView.correctAnswerView.removeFromSuperview()
            questionView.correctAnswerLabel.removeFromSuperview()
            questionView.userAnswerLabel.removeFromSuperview()
        }
        
        // UI 업데이트
        updateUI()
        
        print("재시험 시작")
    }
    
    @objc private func sendWrongAnswers() {
        // 오답노트 보내기 로직 구현
        print("오답노트 보내기")
    }
    
    @objc private func remakeTest() {
        print("문제 재추출")
        showRemakeAlert()
    }
    
    @objc internal override func dismissKeyboard() {
        view.endEditing(true) // 현재 화면에서 활성화된 키보드를 내림
    }
}
