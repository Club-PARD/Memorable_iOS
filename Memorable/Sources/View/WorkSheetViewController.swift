//
//  StudySheetViewController.swift
//  Memorable
//
//  Created by 김현기 on 6/26/24.
//

import SnapKit
import Then
import UIKit

class WorkSheetViewController: UIViewController {
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "applogo_v2")
    }

    private let backButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        $0.setImage(image, for: .normal)
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 0.5 * 40
        $0.clipsToBounds = true
    }

    private let finishImage = FloatingImage(frame: CGRect(x: 0, y: 0, width: 260, height: 36)).then {
        $0.image = UIImage(named: "finishStudy")
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }

    private let doneButton = UIButton().then {
        $0.setTitle("학습완료", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
        $0.isEnabled = false
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

    private var workSheetView: UIView?

    private let reExtractButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .blue
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12)
        config.image = UIImage(systemName: "arrow.counterclockwise", withConfiguration: imageConfig)
        config.imagePadding = 5
        config.imagePlacement = .trailing
        config.title = "빈칸 재추출하기"
        $0.configuration = config
    }

    private let resetButton = UIButton().then {
        $0.setTitle("초기화하기", for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
    }

    private var isShowingAnswer = false

    private let showAnswerButton = UIButton().then {
        $0.setTitle("키워드 보기", for: .normal)
        $0.setTitle("키워드 숨기기", for: .selected)
        $0.backgroundColor = .systemGray
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
    }

    private var userAnswer: [String] = []
    private var answerLength: Int = 0

    private var correctCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray

        workSheetView = WorkSheetView(
            frame: view.bounds,
            viewWidth: view.frame.width - 48,
            text: mockText,
            answers: mockAnswers
        )

        setupButtons()

        addSubViews()
        setupConstraints()
    }

    // MARK: - Button Action

    @objc func didTapResetButton() {
        print("RESET ANSWERS")
        if let worksheetView = workSheetView as? WorkSheetView {
            for answer in worksheetView.userAnswers {
                answer.text = nil
            }
        }
        else {
            print("WorkSheetView를 찾을 수 없습니다.")
        }
    }

    @objc func didTapShowAnswerButton() {
        isShowingAnswer.toggle()
        showAnswerButton.isSelected = isShowingAnswer

        if isShowingAnswer {
            showAnswer()
        }
        else {
            hideAnswer()
        }
    }

    @objc func showAnswer() {
        print("SHOW ANSWER")
        correctCount = 0

        guard let worksheet = workSheetView as? WorkSheetView else {
            print("WorkSheetView를 찾을 수 없습니다.")
            return
        }

        userAnswer = worksheet.userAnswers.map { $0.text ?? "" }
        answerLength = worksheet.userAnswers.count

        print("✅ 실제 답안: \(mockAnswers)")
        print("☑️ 유저 답안: \(userAnswer)")

        DispatchQueue.main.async {
            for idx in 0 ..< self.answerLength {
                let textField = worksheet.userAnswers[idx]

                // 값을 안 쓴 부분
                if self.userAnswer[idx].isEmpty {
                    textField.textColor = .lightGray
                    textField.text = mockAnswers[idx]
                }
                // 값이 동일
                else if mockAnswers[idx] == self.userAnswer[idx] {
                    self.correctCount += 1
                    textField.textColor = .blue
                }
                // 나머지 (= 틀림)
                else {
                    textField.textColor = .red
                    textField.text = mockAnswers[idx]
                }

                textField.isEnabled = false
                textField.setNeedsDisplay()
            }

            if self.correctCount == self.answerLength {
                self.correctAll()
            }

            worksheet.layoutIfNeeded()
        }
    }

    func hideAnswer() {
        print("HIDE ANSWER")

        guard let worksheet = workSheetView as? WorkSheetView else {
            print("WorkSheetView를 찾을 수 없습니다.")
            return
        }

        DispatchQueue.main.async {
            for idx in 0 ..< self.answerLength {
                worksheet.userAnswers[idx].text = self.userAnswer[idx]
                worksheet.userAnswers[idx].textColor = .black
                worksheet.userAnswers[idx].isEnabled = true
                worksheet.userAnswers[idx].setNeedsDisplay()
            }

            worksheet.layoutIfNeeded()
        }
    }

    func correctAll() {
        print("CORRECT ALL")
        finishImage.isHidden = false
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .blue
        doneButton.isEnabled = true
    }

    @objc func didTapDoneButton() {
        print("DONE")
    }

    @objc func didTapBackButton() {
        print("GO BACK")
    }

    @objc func didTapReExtractButton() {
        print("REEXTRACT KEYWORD")

        let alert = UIAlertController(title: "키워드 재추출", message: "키워드를 새롭게 생성하시겠습니까?\n이 작업은 파일 당 1회만 가능합니다.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            print("PRESS CANCEL")
        }

        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            print("PRESS CONFIRM")
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }

    // MARK: - Default Setting

    func setupButtons() {
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        reExtractButton.addTarget(self, action: #selector(didTapReExtractButton), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        showAnswerButton.addTarget(self, action: #selector(didTapShowAnswerButton), for: .touchUpInside)
    }

    func addSubViews() {
        view.addSubview(logoImageView)
        view.addSubview(backButton)
        view.addSubview(finishImage)
        view.addSubview(doneButton)
        view.addSubview(titleLabel)
        view.addSubview(categoryLabel)
        view.addSubview(workSheetView!)
        view.addSubview(reExtractButton)
        view.addSubview(resetButton)
        view.addSubview(showAnswerButton)
    }

    func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.height.equalTo(24)
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.leading.equalTo(logoImageView.snp.trailing).offset(20)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }

        doneButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-11)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.height.equalTo(44)
            make.width.equalTo(132)
        }

        finishImage.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-11)
            make.trailing.equalTo(doneButton.snp.leading).offset(-10)
            make.height.equalTo(44)
            make.width.equalTo(260)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(28)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
        }

        categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(12)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }

        showAnswerButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-32)
            make.height.equalTo(44)
            make.width.equalTo(132)
        }

        resetButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.trailing.equalTo(showAnswerButton.snp.leading).offset(-10)
            make.height.equalTo(44)
            make.width.equalTo(132)
        }

        workSheetView!.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.bottom.equalTo(showAnswerButton.snp.top).offset(-24)
        }

        reExtractButton.snp.makeConstraints { make in
            make.top.equalTo(workSheetView!.snp.top).offset(24)
            make.trailing.equalTo(workSheetView!.snp.trailing).offset(-20)
        }
    }
}
