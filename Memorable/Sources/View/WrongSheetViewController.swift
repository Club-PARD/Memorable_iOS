//
//  WrongSheetViewController.swift
//  Memorable
//
//  Created by 김현기 on 7/1/24.
//

import SnapKit
import Then
import UIKit

class WrongSheetViewController: UIViewController {
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "applogo-v2")
    }

    private let backButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        $0.setImage(image, for: .normal)
        $0.backgroundColor = MemorableColor.White
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 0.5 * 40
        $0.clipsToBounds = true
    }

    private let categoryTitleLabel = UILabel().then {
        $0.text = "카테고리명"
        $0.font = MemorableFont.LargeTitle()
        $0.textColor = MemorableColor.Black
    }

    private let fileNameLabel = UILabel().then {
        $0.text = "파일명 외 4개 파일"
        $0.font = MemorableFont.Body1()
        $0.textColor = MemorableColor.Gray1
    }

    private var wrongSheetView: UIView?

    private let resetButton = UIButton().then {
        $0.setTitle("초기화하기", for: .normal)
        $0.titleLabel?.font = MemorableFont.Body1()

        $0.contentMode = .scaleAspectFit

        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white

        $0.configuration = config

        // 버튼의 layer에 직접 cornerRadius를 설정합니다.
        $0.layer.cornerRadius = 25
        $0.clipsToBounds = true
    }

    private var isShowingAnswer = false

    private let showAnswerButton = UIButton().then {
        $0.setTitle("정답 보기", for: .normal)
        $0.setTitle("정답 가리기", for: .selected)

        $0.contentMode = .scaleAspectFit

        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "eye")
        config.imagePadding = 10
        config.imagePlacement = .leading
        config.baseBackgroundColor = MemorableColor.Blue2
        config.baseForegroundColor = MemorableColor.White

        $0.configuration = config

        // 버튼의 layer에 직접 cornerRadius를 설정합니다.
        $0.layer.cornerRadius = 25
        $0.clipsToBounds = true
    }

    private var userAnswer: [String] = []
    private var answerLength: Int = 0

    private var correctCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MemorableColor.Gray5

        wrongSheetView = WrongSheetView(
            frame: CGRect.zero,
            questions: mockWrongQuestions,
            answers: mockWrongQuestionAnswers
        )
        loadUserAnswers()

        setupButtons()

        addSubViews()
        setupConstraints()
    }

    // MARK: - Button Settings

    func setupButtons() {
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        showAnswerButton.addTarget(self, action: #selector(didTapShowAnswerButton), for: .touchUpInside)
    }

    @objc func didTapBackButton() {
        print("GO BACK")

        let alert = UIAlertController(title: "오답노트 나가기", message: "오답노트를 나가시겠습니까?\n라이브러리로 되돌아갑니다.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            print("PRESS CANCEL")
        }

        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.saveUserAnswers()
            self.navigationController?.popViewController(animated: true)
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }

    private func saveUserAnswers() {
        guard let wrongsheet = wrongSheetView as? WrongSheetView else {
            print("WrongSheetView를 찾을 수 없습니다.")
            return
        }
        answerLength = wrongsheet.wrongQuestionViews.count
        if isShowingAnswer {
            for idx in 0 ..< answerLength {
                wrongsheet.wrongQuestionViews[idx].answerTextField.text = userAnswer[idx]
            }
        }
        userAnswer = wrongsheet.wrongQuestionViews.map { $0.answerTextField.text ?? "" }

        // TODO: 클백 연결시 key 변경해주어야 함.
        UserDefaults.standard.set(userAnswer, forKey: "wrongSheet")
    }

    private func loadUserAnswers() {
        guard let wrongsheet = wrongSheetView as? WrongSheetView else {
            print("WrongSheetView를 찾을 수 없습니다.")
            return
        }

        let prevUserAnswers: [String] = UserDefaults.standard.array(forKey: "wrongSheet") as? [String] ?? []
        if !prevUserAnswers.isEmpty {
            print(prevUserAnswers)
            for (index, view) in wrongsheet.wrongQuestionViews.enumerated() {
                view.answerTextField.text = prevUserAnswers[index]
            }
        }

        wrongsheet.layoutIfNeeded()
    }

    @objc func didTapResetButton() {
        let alert = UIAlertController(title: "초기화하기", message: "작성한 키워드를 초기화하시겠습니까?\n이 작업은 복구할 수 없습니다.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            print("PRESS CANCEL")
        }

        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            print("RESET")
            if let wrongSheetView = self.wrongSheetView as? WrongSheetView {
                for wrongQuestionView in wrongSheetView.wrongQuestionViews {
                    wrongQuestionView.answerTextField.text = nil
                }
            }
            else {
                print("WrongSheetView를 찾을 수 없습니다.")
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }

    @objc func didTapShowAnswerButton() {
        print("SHOW KEYWORD")
        isShowingAnswer.toggle()
        showAnswerButton.isSelected = isShowingAnswer

        if isShowingAnswer {
            showAnswer()

            resetButton.isHidden = true

            var config = UIButton.Configuration.filled()
            config.image = UIImage(systemName: "eye.slash")
            config.imagePadding = 10
            config.imagePlacement = .leading
            config.baseBackgroundColor = MemorableColor.Blue1?.withAlphaComponent(0.35)
            config.baseForegroundColor = MemorableColor.White
            config.cornerStyle = .large

            showAnswerButton.configuration = config
        }
        else {
            hideAnswer()

            resetButton.isHidden = false

            var config = UIButton.Configuration.filled()
            config.image = UIImage(systemName: "eye")
            config.imagePadding = 10
            config.imagePlacement = .leading
            config.baseBackgroundColor = MemorableColor.Blue2
            config.baseForegroundColor = MemorableColor.White
            config.cornerStyle = .large

            showAnswerButton.configuration = config
        }
    }

    @objc func showAnswer() {
        print("SHOW ANSWER")
        correctCount = 0

        guard let wrongsheet = wrongSheetView as? WrongSheetView else {
            print("WrongSheetView를 찾을 수 없습니다.")
            return
        }

        userAnswer = wrongsheet.wrongQuestionViews.map { $0.answerTextField.text ?? "" }
        answerLength = wrongsheet.wrongQuestionViews.count

        print("✅ 실제 답안: \(mockWrongQuestionAnswers)")
        print("☑️ 유저 답안: \(userAnswer)")

        DispatchQueue.main.async {
            for idx in 0 ..< self.answerLength {
                let textField = wrongsheet.wrongQuestionViews[idx].answerTextField
                let myAnswerLabel = wrongsheet.wrongQuestionViews[idx].myAnswerWhenChecking

                // 값을 안 쓴 부분
                if self.userAnswer[idx].replacingOccurrences(of: " ", with: "")
                    .isEmpty
                {
                    textField.textColor = MemorableColor.Gray2
                    textField.text = mockWrongQuestionAnswers[idx]
                }
                // 값이 동일
                else if mockWrongQuestionAnswers[idx].replacingOccurrences(of: " ", with: "")
                    == self.userAnswer[idx].replacingOccurrences(of: " ", with: "")
                {
                    self.correctCount += 1
                    textField.textColor = MemorableColor.Blue
                }
                // 나머지 (= 틀림)
                else {
                    textField.textColor = MemorableColor.Red
                    textField.text = mockWrongQuestionAnswers[idx]

                    myAnswerLabel.text = "사용자가 입력한 답: \(self.userAnswer[idx])"
                    myAnswerLabel.isHidden = false
                }

                textField.isEnabled = false
                textField.setNeedsDisplay()
            }

            wrongsheet.layoutIfNeeded()
        }
    }

    func hideAnswer() {
        print("HIDE ANSWER")

        guard let wrongsheet = wrongSheetView as? WrongSheetView else {
            print("WrongSheetView를 찾을 수 없습니다.")
            return
        }

        DispatchQueue.main.async {
            for idx in 0 ..< self.answerLength {
                let myAnswerLabel = wrongsheet.wrongQuestionViews[idx].myAnswerWhenChecking

                wrongsheet.wrongQuestionViews[idx].answerTextField.text = self.userAnswer[idx]
                wrongsheet.wrongQuestionViews[idx].answerTextField.textColor = MemorableColor.Black
                wrongsheet.wrongQuestionViews[idx].answerTextField.isEnabled = true
                wrongsheet.wrongQuestionViews[idx].answerTextField.setNeedsDisplay()

                myAnswerLabel.text = nil
                myAnswerLabel.isHidden = true
            }

            wrongsheet.layoutIfNeeded()
        }
    }

    // MARK: - General Settings

    func addSubViews() {
        view.addSubview(logoImageView)
        view.addSubview(backButton)

        view.addSubview(categoryTitleLabel)
        view.addSubview(fileNameLabel)

        view.addSubview(wrongSheetView!)

        view.addSubview(resetButton)
        view.addSubview(showAnswerButton)
    }

    func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(28.21)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.width.equalTo(126)
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(33.72)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.height.equalTo(44)
            make.width.equalTo(44)
        }

        categoryTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(12)
            make.top.equalTo(logoImageView.snp.bottom).offset(32.72)
        }

        fileNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryTitleLabel.snp.trailing).offset(12)
            make.centerY.equalTo(categoryTitleLabel.snp.centerY)
        }

        wrongSheetView!.snp.makeConstraints { make in
            make.top.equalTo(categoryTitleLabel.snp.bottom).offset(28)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.bottom.equalTo(showAnswerButton.snp.top).offset(-26)
        }

        showAnswerButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.height.equalTo(50)
            make.width.equalTo(160)
        }

        resetButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.trailing.equalTo(showAnswerButton.snp.leading).offset(-10)
            make.height.equalTo(50)
            make.width.equalTo(160)
        }
    }
}
