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
    var sharedName: String?
    var sharedCategory: String?
    var sharedText: String?
    
    private let questionManager = QuestionManager()
    private var currentPage = 0
    private let questionsPerPage = 3
    
    private var questionViews: [QuestionView] = []
    private var nextButton: UIButton!
    private var previousButton: UIButton!
    private var testSheetView: UIView?
    private var progressBarView: ProgressBarView?
    
    private var containerView = UIView().then {
        $0.backgroundColor = MemorableColor.White
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
        $0.backgroundColor = MemorableColor.White
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 0.5 * 44
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "사회학개론 1-1"
        $0.font = MemorableFont.LargeTitle()
    }
    
    private let categoryLabel = UILabel().then {
        $0.text = "카테고리명"
        $0.font = MemorableFont.Body1()
        $0.textColor = MemorableColor.Gray1
    }
    
    private let pagingLabel = UILabel().then {
        $0.font = MemorableFont.Body1()
        $0.textColor = MemorableColor.Gray1
    }
    
    private let submitButton = UIButton().then {
        $0.setTitle("제출하기", for: .normal)
        $0.titleLabel?.font = MemorableFont.Body1()
        $0.setTitleColor(MemorableColor.White, for: .normal)
        $0.backgroundColor = MemorableColor.Blue2
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
    }
    
    private let retryButton = UIButton().then {
        $0.setTitle("재응시하기", for: .normal)
        $0.titleLabel?.font = MemorableFont.Body1()
        $0.setTitleColor(MemorableColor.White, for: .normal)
        $0.backgroundColor = MemorableColor.Black
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private let sendWrongAnswersButton = UIButton().then {
        $0.setTitle("오답노트 보내기", for: .normal)
        $0.titleLabel?.font = MemorableFont.Body1()
        $0.setTitleColor(MemorableColor.White, for: .normal)
        $0.backgroundColor = MemorableColor.Blue2
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private let remakeButton = UIButton().then {
        $0.setTitle("재추출하기", for: .normal)
        $0.titleLabel?.font = MemorableFont.Body1()
        $0.setTitleColor(MemorableColor.White, for: .normal)
        $0.backgroundColor = MemorableColor.Blue2
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private let resultLabel = UILabel().then {
        $0.font = MemorableFont.Body1()
        $0.textColor = MemorableColor.Gray1
        $0.isHidden = true // 초기에는 숨김 처리
    }
    
    private let scoreLabel = UILabel().then {
        $0.font = MemorableFont.LargeTitle()
        $0.textColor = MemorableColor.Black
        $0.isHidden = true // 초기에는 숨김 처리
        $0.text = "점수"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = MemorableColor.Gray5
        setupUI()
        loadQuestions()
        updateUI()
        
        // 키보드 내리기 (작성 밖 터치)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Example: Display data in a toast message or UI
        if let fileName = sharedName, let category = sharedCategory, let extractedText = sharedText {
            print("File: \(fileName)\nCategory: \(category)\nExtracted Text: \(extractedText)")
            showToast("File: \(fileName)\nCategory: \(category)\nExtracted Text: \(extractedText)")
        }
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
        scoreLabel.snp.makeConstraints { make in
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
        pagingLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        // Previous Button
        previousButton = UIButton()
        let previousButtonImage = UIImage(systemName: "chevron.left")
        previousButton.setImage(previousButtonImage, for: .normal)
        previousButton.tintColor = MemorableColor.Blue2
        previousButton.backgroundColor = MemorableColor.White
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
        nextButton.tintColor = MemorableColor.Blue2
        nextButton.backgroundColor = MemorableColor.White
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
        submitButton.isHidden = true // 초기에는 숨김 처리
        
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
            1: ["question": "자크 랑시에르의 철학적 배경은 어떤 철학자의 영향을 받았는가?", "answer": "알튀세르", "userAnswer": ""],
            2: ["question": "랑시에르가 집중한 주요 철학적 개념 중 하나는 무엇인가?", "answer": "평등", "userAnswer": ""],
            3: ["question": "조제프 자코토가 교육을 전담했던 시기는 어떤 역사적 사건 이후인가?", "answer": "프랑스 혁명", "userAnswer": ""],
            4: ["question": "조제프 자코토가 프랑스어를 가르쳤던 나라는 어디인가?", "answer": "벨기에", "userAnswer": ""],
            5: ["question": "전통적인 교육 시스템이 제한을 가하는 능력은 무엇인가?", "answer": "지적 능력", "userAnswer": ""],
            6: ["question": "모국어가 어떤 상황 속에서 자연스럽게 배워진다고 언급되는가?", "answer": "일상", "userAnswer": ""],
            7: ["question": "거의 동일한 지적 능력을 가진다는 철학적 배경의 기저에 깔려 있는 권리는 무엇인가?", "answer": "평등", "userAnswer": ""],
            8: ["question": "특정한 교육 시스템이 학생들에게 제한을 가하는 방법은 무엇인가?", "answer": "전통적인 교육 시스템", "userAnswer": ""],
            9: ["question": "자코토가 프랑스어를 가르치는 교육 실험의 중요한 개념 중 하나는 무엇인가?", "answer": "무지한 스승", "userAnswer": ""],
            10: ["question": "랑시에르의 철학이 영향을 받은 철학적 사조 중 하나는 무엇인가?", "answer": "구조주의", "userAnswer": ""],
            11: ["question": "자크 랑시에르가 주목한 철학적 접근법 중 하나는 무엇인가?", "answer": "마르크스주의", "userAnswer": ""],
            12: ["question": "자크 랑시에르의 철학은 개인의 자유를 위한 과정에도 중점을 두고 있다. 이 과정을 무엇이라 부르는가?", "answer": "해방", "userAnswer": ""],
            13: ["question": "교육 실험을 통해 혁신적인 교육방법을 제시한 프랑스의 교육자는 누구인가?", "answer": "조제프 자코토", "userAnswer": ""],
            14: ["question": "자크 랑시에르의 철학에서 주요한 역할을 하는, 말이나 문자를 의미하는 것은 무엇인가?", "answer": "기호", "userAnswer": ""],
            15: ["question": "자크 랑시에르가 비판적으로 바라본 것은 학생들에게 무지를 교육하며 제한하는 무엇인가?", "answer": "교육 시스템", "userAnswer": ""],
            16: ["question": "조제프 자코토가 가르친 언어는 무엇인가?", "answer": "프랑스어", "userAnswer": ""],
            17: ["question": "자크 랑시에르가 제시한 새로운 교육 시스템의 목적은 무엇인가?", "answer": "변혁", "userAnswer": ""],
            18: ["question": "자크 랑시에르의 철학에서 언급된, 특정 언어를 학습하는 과정에서 중요한 역할을 하는 요소는 무엇인가?", "answer": "모국어", "userAnswer": ""],
            19: ["question": "교육 시스템의 변혁을 중심으로 논지를 전개한 철학자는 누구인가?", "answer": "자크 랑시에르", "userAnswer": ""],
            20: ["question": "자크 랑시에르는 구조주의 이후의 철학적 접근에도 영향을 받았다. 이 접근법은 무엇인가?", "answer": "포스트구조주의", "userAnswer": ""]
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
        for index in 0 ..< questionManager.questions.count {
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
    
    @objc override func dismissKeyboard() {
        view.endEditing(true) // 현재 화면에서 활성화된 키보드를 내림
    }
    
    private func showToast(_ message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 70))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.systemFont(ofSize: 15.0)
        toastLabel.text = message
        toastLabel.numberOfLines = 0 // Allow multiple lines
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
