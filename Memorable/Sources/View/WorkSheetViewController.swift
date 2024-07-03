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
        $0.image = UIImage(named: "applogo-v2")
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
        $0.setTitleColor(MemorableColor.Gray1, for: .normal)
        $0.backgroundColor = MemorableColor.Gray4
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
        config.baseForegroundColor = MemorableColor.Blue1
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12)
        config.image = UIImage(systemName: "arrow.counterclockwise", withConfiguration: imageConfig)
        config.imagePadding = 5
        config.imagePlacement = .trailing
        config.title = "빈칸 재추출하기"
        $0.configuration = config
    }

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
        $0.setTitle("키워드 보기", for: .normal)
        $0.setTitle("키워드 가리기", for: .selected)

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
        view.backgroundColor = .gray5

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
        let alert = UIAlertController(title: "초기화하기", message: "작성한 키워드를 초기화하시겠습니까?\n이 작업은 복구할 수 없습니다.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            print("PRESS CANCEL")
        }

        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            print("RESET ANSWERS")
            if let worksheetView = self.workSheetView as? WorkSheetView {
                for answer in worksheetView.userAnswers {
                    answer.text = nil
                }
            }
            else {
                print("WorkSheetView를 찾을 수 없습니다.")
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }

    @objc func didTapShowAnswerButton() {
        isShowingAnswer.toggle()
        showAnswerButton.isSelected = isShowingAnswer

        if isShowingAnswer {
            showAnswer()

            resetButton.isHidden = true

            var config = UIButton.Configuration.filled()
            config.image = UIImage(systemName: "eye.slash")
            config.imagePadding = 10
            config.imagePlacement = .leading
            config.baseBackgroundColor = MemorableColor.Gray4
            config.baseForegroundColor = MemorableColor.Gray1
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
                if self.userAnswer[idx].replacingOccurrences(of: " ", with: "")
                    .isEmpty
                {
                    textField.textColor = .lightGray
                    textField.text = mockAnswers[idx]
                }
                // 값이 동일
                else if mockAnswers[idx].replacingOccurrences(of: " ", with: "")
                    == self.userAnswer[idx].replacingOccurrences(of: " ", with: "")
                {
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
        doneButton.setTitleColor(MemorableColor.White, for: .normal)
        doneButton.backgroundColor = MemorableColor.Blue2
        doneButton.isEnabled = true
    }

    @objc func didTapDoneButton() {
        print("DONE")
        let alert = UIAlertController(title: "학습완료", message: "학습완료 하시겠습니까?\n해당 파일로 나만의 시험지를\n바로 생성할 수 있습니다.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "나가기", style: .cancel) { _ in
            print("PRESS CANCEL")
            self.navigationController?.popViewController(animated: true)
        }

        let confirmAction = UIAlertAction(title: "시험지 생성하기", style: .default) { _ in
            print("PRESS CONFIRM")
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }

    @objc func didTapBackButton() {
        print("GO BACK")
        navigationController?.popViewController(animated: true)
//        let alert = UIAlertController(title: "빈칸 학습지 나가기", message: "빈칸 학습지를 나가시겠습니까?\n지금까지의 기록이 저장되지 않고\n라이브러리로 되돌아갑니다.", preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
//            print("PRESS CANCEL")
//        }
//
//        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
//            print("PRESS CONFIRM")
//            self.navigationController?.popViewController(animated: true)
//        }
//
//        alert.addAction(cancelAction)
//        alert.addAction(confirmAction)
//
//        present(alert, animated: true)
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

        doneButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(13)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.height.equalTo(44)
            make.width.equalTo(132)
        }

        finishImage.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(13)
            make.trailing.equalTo(doneButton.snp.leading).offset(-10)
            make.height.equalTo(44)
            make.width.equalTo(260)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(12)
            make.top.equalTo(logoImageView.snp.bottom).offset(32.72)
        }

        categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(12)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }

        showAnswerButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.height.equalTo(50)
            make.width.equalTo(160)
        }

        resetButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.trailing.equalTo(showAnswerButton.snp.leading).offset(-10)
            make.height.equalTo(50)
            make.width.equalTo(160)
        }

        workSheetView!.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.bottom.equalTo(showAnswerButton.snp.top).offset(-26)
        }

        reExtractButton.snp.makeConstraints { make in
            make.top.equalTo(workSheetView!.snp.top).offset(20)
            make.trailing.equalTo(workSheetView!.snp.trailing).offset(-28)
        }
    }
}
