//
//  TestViewController.swift
//  Memorable
//
//  Created by Minhyeok Kim on 6/28/24.
//

import SnapKit
import Then
import UIKit

struct TestSheetState {
    var userAnswers: [String?]
    var isSubmitted: Bool
    var score: Int?
}

class TestSheetViewController: UIViewController, UITextFieldDelegate {
    private let apiManager = APIManagere.shared
    private var testsheetDetail: TestsheetDetail?
    
    var sharedName: String?
    var sharedCategory: String?
    var sharedText: String?
    
    private let questionManager = QuestionManager()
    private var currentPage = 0
    private let questionsPerPage = 3
    
    private var questionViews: [QuestionView] = []
    private var previousButton = UIButton()
    private var nextButton = UIButton()
    private var testSheetView: UIView?
    private var progressBarView: ProgressBarView?
    
    private var isFirstSheetSelected: Bool = true
    private let firstSheetButton = UIButton()
    private let secondSheetButton = UIButton()
    
    private var firstSheetState: TestSheetState?
    private var secondSheetState: TestSheetState?
    
    private let sheetToggleStackView = UIStackView()
    
    private let addTestSheetButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        
        // 버튼 타이틀 설정
        var title = AttributedString("추가 시험지 받기")
        title.font = MemorableFont.Body1()
        configuration.attributedTitle = title
        configuration.baseForegroundColor = MemorableColor.Blue1
        
        // 시스템 이미지 추가
        let image = UIImage(systemName: "arrow.counterclockwise")?.withRenderingMode(.alwaysTemplate)
        configuration.image = image
        configuration.imagePadding = 8
        configuration.imagePlacement = .leading
        
        // 이미지 틴트 색상 설정
        button.tintColor = MemorableColor.Blue1
        
        button.configuration = configuration
        return button
    }()
    
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
    
    private let resultLabel = UILabel().then {
        $0.font = MemorableFont.LargeTitle()
        $0.textAlignment = .right
        $0.textColor = MemorableColor.Black
        $0.isHidden = true
    }
    
    private let scoreLabel = UILabel().then {
        $0.font = MemorableFont.Body1()
        $0.textColor = MemorableColor.Gray1
        $0.textAlignment = .right
        $0.isHidden = true
        $0.text = "점"
    }
    
    private let finishImage = FloatingImage(frame: CGRect(x: 0, y: 0, width: 260, height: 36)).then {
        $0.image = UIImage(named: "finish_add")
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTestsheet()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = MemorableColor.Gray5
        setupUI()
        loadQuestions()
        updateUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        if let fileName = sharedName, let category = sharedCategory, let extractedText = sharedText {
            print("File: \(fileName)\nCategory: \(category)\nExtracted Text: \(extractedText)")
            showToast("File: \(fileName)\nCategory: \(category)\nExtracted Text: \(extractedText)")
        }
    }
    
    private func loadTestsheet() {
        testsheetDetail = apiManager.getMockTestsheetDetail()
        setupTestsheetInfo()
        firstSheetState = TestSheetState(userAnswers: Array(repeating: nil, count: testsheetDetail?.questions1.count ?? 0), isSubmitted: false, score: nil)
    }
    
    private func setupTestsheetInfo() {
        guard let testsheetDetail = testsheetDetail else { return }
        
        titleLabel.text = testsheetDetail.name
        categoryLabel.text = testsheetDetail.category
    }
    
    private func setupUI() {
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(51)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.width.equalTo(126)
            make.height.equalTo(15.07)
        }
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(33.72)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(39)
            make.height.equalTo(44)
            make.width.equalTo(44)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(12)
        }
        
        view.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(12)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(173)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(540)
        }
        
        view.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.trailing.equalTo(containerView.snp.trailing).offset(-18)
            make.bottom.equalTo(containerView.snp.top).offset(-88)
        }
        
        view.addSubview(resultLabel)
        resultLabel.snp.makeConstraints { make in
            make.bottom.equalTo(scoreLabel).offset(5)
            make.trailing.equalTo(scoreLabel.snp.leading).offset(-8)
        }
        
        for _ in 0..<3 {
            let questionView = QuestionView()
            containerView.addSubview(questionView)
            questionViews.append(questionView)
        }
        
        for (index, questionView) in questionViews.enumerated() {
            questionView.snp.makeConstraints { make in
                make.leading.equalTo(containerView).offset(52)
                make.trailing.equalTo(containerView).offset(-52)
                make.height.equalTo(120)
                
                switch index {
                case 0:
                    make.top.equalTo(containerView).offset(50)
                case 1:
                    make.centerY.equalTo(containerView)
                case 2:
                    make.bottom.equalTo(containerView).offset(-50)
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
        
        let previousButtonImage = UIImage(systemName: "chevron.left")
        previousButton.setImage(previousButtonImage, for: .normal)
        previousButton.tintColor = MemorableColor.Gray1
        previousButton.backgroundColor = MemorableColor.White
        previousButton.contentMode = .scaleAspectFit
        previousButton.layer.cornerRadius = 32
        previousButton.clipsToBounds = true
        previousButton.addTarget(self, action: #selector(previousPage), for: .touchUpInside)
        
        view.addSubview(previousButton)
        previousButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-21)
            make.width.height.equalTo(64)
        }
        
        let nextButtonImage = UIImage(systemName: "chevron.right")
        nextButton.setImage(nextButtonImage, for: .normal)
        nextButton.tintColor = MemorableColor.Blue2
        nextButton.backgroundColor = MemorableColor.White
        nextButton.contentMode = .scaleAspectFit
        nextButton.layer.cornerRadius = 32
        nextButton.clipsToBounds = true
        nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-21)
            make.width.height.equalTo(64)
        }
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-31)
            make.width.equalTo(132)
            make.height.equalTo(44)
        }
        submitButton.addTarget(self, action: #selector(submitAnswers), for: .touchUpInside)
        
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
        
        setupSheetButtons()
        setupAddTestSheetButton()
        setupSheetToggle()
        
        view.addSubview(finishImage)
        finishImage.snp.makeConstraints { make in
            make.trailing.equalTo(addTestSheetButton.snp.leading).offset(-8)
            make.centerY.equalTo(addTestSheetButton)
        }
    }
    
    private func setupSheetButtons() {
        firstSheetButton.setTitle("1", for: .normal)
        secondSheetButton.setTitle("2", for: .normal)
        
        [firstSheetButton, secondSheetButton].forEach {
            $0.layer.cornerRadius = 12.5
            $0.clipsToBounds = true
            $0.addTarget(self, action: #selector(sheetButtonTapped(_:)), for: .touchUpInside)
            $0.titleLabel?.font = MemorableFont.Body1() // 폰트 설정 추가
            $0.setTitleColor(MemorableColor.Black, for: .normal) // 텍스트 색상 설정 추가
        }
        
        updateSheetSelection() // 초기 선택 상태 설정
    }
    
    private func setupAddTestSheetButton() {
        addTestSheetButton.addTarget(self, action: #selector(addTestSheetButtonTapped), for: .touchUpInside)
        
        view.addSubview(addTestSheetButton)
        
        addTestSheetButton.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.top).offset(-10)
            make.trailing.equalTo(containerView.snp.trailing).offset(-24)
        }
        
        addTestSheetButton.isEnabled = !(testsheetDetail?.isReExtracted ?? false)
        addTestSheetButton.setTitleColor(testsheetDetail?.isReExtracted ?? false ? MemorableColor.Gray2 : MemorableColor.Blue1, for: .normal)
    }
    
    private func setupSheetToggle() {
        sheetToggleStackView.axis = .horizontal
        sheetToggleStackView.distribution = .fillEqually
        sheetToggleStackView.spacing = 10
        view.addSubview(sheetToggleStackView)
        
        sheetToggleStackView.addArrangedSubview(firstSheetButton)
        sheetToggleStackView.addArrangedSubview(secondSheetButton)
        
        sheetToggleStackView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(18)
            make.trailing.equalTo(containerView.snp.trailing).offset(-45)
            make.height.equalTo(25)
            make.width.equalTo(60) // 전체 너비 설정
        }
        
        // 각 버튼의 크기를 동일하게 설정
        [firstSheetButton, secondSheetButton].forEach { button in
            button.snp.makeConstraints { make in
                make.width.height.equalTo(25)
            }
        }
        
        sheetToggleStackView.isHidden = true // 초기에는 숨김 처리
    }
    
    private func updateUI() {
        let startIndex = currentPage * questionsPerPage
            for (index, questionView) in questionViews.enumerated() {
                let questionIndex = startIndex + index
                if questionIndex < questionManager.questions.count {
                    let question = questionManager.questions[questionIndex]
                    let currentState = isFirstSheetSelected ? firstSheetState : secondSheetState
                    let userAnswer = currentState?.userAnswers[questionIndex]
                    questionView.configure(with: question, questionNumberValue: questionIndex + 1, userAnswer: userAnswer)
                    questionView.isHidden = false
                    
                    if currentState?.isSubmitted ?? false {
                        questionView.replaceTextFieldWithLabels()
                    } else {
                        questionView.resetView()
                    }
                } else {
                    questionView.isHidden = true
                }
            }
        
        let totalPages = (questionManager.questions.count + questionsPerPage - 1) / questionsPerPage
        
        pagingLabel.text = "\(currentPage + 1)/\(totalPages)"
        
        previousButton.isHidden = currentPage == 0
        
        let isLastPage = currentPage == totalPages - 1
        nextButton.isHidden = isLastPage
        
        let currentState = isFirstSheetSelected ? firstSheetState : secondSheetState
        if let score = currentState?.score {
            resultLabel.text = "\(score)/\(questionManager.questions.count)"
            resultLabel.isHidden = false
            scoreLabel.isHidden = false
        } else {
            resultLabel.isHidden = true
            scoreLabel.isHidden = true
        }
        
        updateUIForSubmittedState()
        
        sendWrongAnswersButton.isHidden = !isLastPage || !(currentState?.isSubmitted ?? false)
        retryButton.isHidden = !isLastPage || !(currentState?.isSubmitted ?? false)
        
        submitButton.isHidden = !isLastPage || (currentState?.isSubmitted ?? false)
        
        progressBarView?.removeFromSuperview()
        
        let newProgressBarView = ProgressBarView(frame: .zero, totalPages: totalPages, currentPage: currentPage + 1)
        view.addSubview(newProgressBarView)
        newProgressBarView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-49)
            make.centerX.equalToSuperview()
        }
        
        progressBarView = newProgressBarView
        progressBarView?.updateCurrentPage(currentPage + 1)
    }
    
    private func updateUIForSubmittedState() {
        let currentState = isFirstSheetSelected ? firstSheetState : secondSheetState
        submitButton.isHidden = currentState?.isSubmitted ?? false
        retryButton.isHidden = !(currentState?.isSubmitted ?? false)
        sendWrongAnswersButton.isHidden = !(currentState?.isSubmitted ?? false)
        addTestSheetButton.isHidden = !(currentState?.isSubmitted ?? false)
    }
    
    private func saveCurrentAnswers() {
        let startIndex = currentPage * questionsPerPage
        for (index, questionView) in questionViews.enumerated() {
            let questionIndex = startIndex + index
            if questionIndex < questionManager.questions.count {
                if isFirstSheetSelected {
                    firstSheetState?.userAnswers[questionIndex] = questionView.answerTextField.text
                } else {
                    secondSheetState?.userAnswers[questionIndex] = questionView.answerTextField.text
                }
            }
        }
    }
    
    private func showSubmitAlert() {
        let alertController = UIAlertController(title: "시험지 제출", message: "시험지를 제출하시겠습니까?\n결과분석 페이지로 이동합니다.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.saveCurrentAnswers()
            self.replaceTextFieldsWithLabels()
            self.printAnswers()
            self.checkAnswersAndShowResult()
            self.moveToFirstPage()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func moveToFirstPage() {
        currentPage = 0
        updateUI()
    }
    
    private func showRemakeAlert() {
        let alertController = UIAlertController(title: "새로운 문제풀기", message: "문제를 새롭게 생성하시겠습니까?\n이 작업은 파일 당 1회만 가능합니다.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.reExtractQuestions()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func replaceTextFieldsWithLabels() {
        for (index, questionView) in questionViews.enumerated() {
            let questionIndex = currentPage * questionsPerPage + index
            if questionIndex < questionManager.questions.count {
                let question = questionManager.questions[questionIndex]
                let currentState = isFirstSheetSelected ? firstSheetState : secondSheetState
                let userAnswer = currentState?.userAnswers[questionIndex]
                questionView.configure(with: question, questionNumberValue: questionIndex + 1, userAnswer: userAnswer)
                questionView.replaceTextFieldWithLabels()
            }
        }
    }
    
    private func printAnswers() {
        let currentState = isFirstSheetSelected ? firstSheetState : secondSheetState
        for (index, question) in questionManager.questions.enumerated() {
            print("질문 \(index + 1) - 정답: \(question.answer), 쓴 답: \(String(describing: currentState?.userAnswers[index] ?? ""))")
        }
    }
    
    private func checkAnswersAndShowResult() {
        var correctAnswers = 0
        let totalQuestions = questionManager.questions.count
        
        let currentState = isFirstSheetSelected ? firstSheetState : secondSheetState
        
        for (index, question) in questionManager.questions.enumerated() {
            let normalizedCorrectAnswer = question.answer.lowercased().replacingOccurrences(of: " ", with: "")
            let normalizedUserAnswer = currentState?.userAnswers[index]?.lowercased().replacingOccurrences(of: " ", with: "")
            
            if normalizedCorrectAnswer == normalizedUserAnswer {
                correctAnswers += 1
            }
            
            if !isFirstSheetSelected && (testsheetDetail?.isReExtracted ?? false) {
                showFinishImage()
            }
        }
        
        if isFirstSheetSelected {
            firstSheetState?.score = correctAnswers
            firstSheetState?.isSubmitted = true
        } else {
            secondSheetState?.score = correctAnswers
            secondSheetState?.isSubmitted = true
        }
        
        resultLabel.text = "\(correctAnswers)/\(totalQuestions)"
        resultLabel.isHidden = false
        scoreLabel.isHidden = false
        
        resultLabel.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.resultLabel.alpha = 1
        }
        
        updateUIForSubmittedState()
        
        printAnswers()
        
        if !isFirstSheetSelected && (testsheetDetail?.isReExtracted ?? false) {
            showFinishImage()
        }
    }
    
    @objc private func backButtonTapped() {
        let alertController = UIAlertController(title: "시험지 나가기", message: "응시 데이터는 모두 사라지며\n재진입 시 작성하신 답안은 모두 지워집니다.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
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
        printAnswers()
        if !isFirstSheetSelected && (testsheetDetail?.isReExtracted ?? false) {
            showFinishImage()
        }
    }
    
    @objc private func retryTest() {
        let alertController = UIAlertController(title: "재응시하기", message: "해당 시험을 재응시하시겠습니까?\n답안과 결과가 모두 지워집니다.", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            if self.isFirstSheetSelected {
                self.firstSheetState = TestSheetState(userAnswers: Array(repeating: nil, count: self.testsheetDetail?.questions1.count ?? 0), isSubmitted: false, score: nil)
            } else {
                self.secondSheetState = TestSheetState(userAnswers: Array(repeating: nil, count: self.testsheetDetail?.questions2.count ?? 0), isSubmitted: false, score: nil)
            }
            
            self.currentPage = 0
            self.resultLabel.isHidden = true
            self.updateUI()
            
            for questionView in self.questionViews {
                questionView.answerTextField.isHidden = false
                questionView.answerTextField.text = ""
                questionView.correctAnswerView.removeFromSuperview()
                questionView.correctAnswerLabel.removeFromSuperview()
                questionView.userAnswerLabel.removeFromSuperview()
            }
            
            print("재시험 시작")
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func sendWrongAnswers() {
        print("오답노트 보내기")
    }
    
    @objc private func remakeTest() {
        print("문제 재추출")
        showRemakeAlert()
    }
    
    @objc override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showToast(_ message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 70))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 15.0)
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    @objc private func sheetButtonTapped(_ sender: UIButton) {
        isFirstSheetSelected = (sender == firstSheetButton)
        updateSheetSelection()
        loadQuestions()
        
        if !isFirstSheetSelected && (testsheetDetail?.isReExtracted ?? false) {
            if secondSheetState?.isSubmitted ?? false {
                showFinishImage()
            } else {
                hideFinishImage()
            }
        } else {
            hideFinishImage()
        }
    }
    
    @objc private func addTestSheetButtonTapped() {
        addTestSheetButton.setTitleColor(MemorableColor.Gray1, for: .normal)
        addTestSheetButton.tintColor = MemorableColor.Gray1
        showReExtractAlert()
    }
    
    private func updateSheetSelection() {
        firstSheetButton.backgroundColor = isFirstSheetSelected ? MemorableColor.Yellow1 : MemorableColor.Gray2
        secondSheetButton.backgroundColor = isFirstSheetSelected ? MemorableColor.Gray2 : MemorableColor.Yellow1
        
        firstSheetButton.setTitleColor(isFirstSheetSelected ? MemorableColor.Black : MemorableColor.Gray1, for: .normal)
        secondSheetButton.setTitleColor(isFirstSheetSelected ? MemorableColor.Gray1 : MemorableColor.Black, for: .normal)
    }
    
    private func showReExtractAlert() {
        let alert = UIAlertController(title: "추가 시험지 만들기", message: "새로운 문제를 생성하시겠습니까?\n이전 시험지도 저장됩니다.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.reExtractQuestions()
        })
        
        present(alert, animated: true)
    }
    
    private func reExtractQuestions() {
        testsheetDetail?.isReExtracted = true
        secondSheetState = TestSheetState(userAnswers: Array(repeating: nil, count: testsheetDetail?.questions2.count ?? 0), isSubmitted: false, score: nil)
        
        sheetToggleStackView.isHidden = false
        addTestSheetButton.isEnabled = false
        
        isFirstSheetSelected = false
        updateSheetSelection()
        loadQuestions()
        
        resetSecondSheetUI()
        showFinishImage()
    }
    
    private func showFinishImage() {
        guard !isFirstSheetSelected && (secondSheetState?.isSubmitted ?? false) else {
            return
        }
        
        finishImage.isHidden = false
        finishImage.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.finishImage.alpha = 1.0
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.hideFinishImage()
            }
        }
    }
    
    private func hideFinishImage() {
        UIView.animate(withDuration: 0.5, animations: {
            self.finishImage.alpha = 0.0
        }) { _ in
            self.finishImage.isHidden = true
        }
    }
    
    private func resetSecondSheetUI() {
        // 현재 페이지의 questionView만 리셋
        let startIndex = currentPage * questionsPerPage
        for (index, questionView) in questionViews.enumerated() {
            let questionIndex = startIndex + index
            if questionIndex < questionManager.questions.count {
                questionView.resetView()
            }
        }
        updateUI()
    }
    
    private func loadQuestions() {
        guard let testSheetDetail = testsheetDetail else { return }
        questionManager.questions = isFirstSheetSelected ? testSheetDetail.questions1 : testSheetDetail.questions2
        currentPage = 0
        
        if isFirstSheetSelected {
            // 첫 번째 시험지의 경우 기존 상태 유지
            updateUI()
        } else {
            // 두 번째 시험지의 경우 UI 리셋
            resetSecondSheetUI()
        }
    }
}
