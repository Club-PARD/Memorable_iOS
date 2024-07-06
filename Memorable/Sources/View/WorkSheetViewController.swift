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
    var worksheetDetail: WorksheetDetail?

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
        $0.image = UIImage(named: "finish_study")
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }

    private let finishImage2 = FloatingImage(frame: CGRect(x: 0, y: 0, width: 260, height: 36)).then {
        $0.image = UIImage(named: "finish_add")
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }

    private let doneButton = UIButton().then {
        $0.setTitle("시험지 받기", for: .normal)
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

    private var isFirstSheetSelected: Bool = true

    private let firstSheetButton = UIButton().then {
        $0.setTitle("1", for: .normal)
        $0.layer.cornerRadius = 25 * 0.5
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
        $0.isEnabled = false
    }

    private let secondSheetButton = UIButton().then {
        $0.setTitle("2", for: .normal)
        $0.layer.cornerRadius = 25 * 0.5
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
        $0.isEnabled = false
    }

    private var workSheetView: UIView?

    private let finishAddImage = FloatingImage(frame: CGRect(x: 0, y: 0, width: 260, height: 36)).then {
        $0.image = UIImage(named: "finish_add")
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }

    private var hideWorkItem: DispatchWorkItem?

    private let addWorkSheetButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = MemorableColor.Blue1
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12)
        config.image = UIImage(systemName: "arrow.counterclockwise", withConfiguration: imageConfig)
        config.imagePadding = 5
        config.imagePlacement = .leading
        config.title = "추가 학습지 만들기"
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

        $0.layer.cornerRadius = 25
        $0.clipsToBounds = true
    }

    private var userAnswer: [String] = []
    private var answerLength: Int = 0

    private var correctCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray5

        updateRecentDate()

        setupUI()
        setupButtons()
        addSubViews()
        setupConstraints()
    }

    private func updateRecentDate() {
        guard let worksheetDetail = worksheetDetail else {
            print("WorkSheetViewController: WorksheetDetail is missing")
            return
        }

        APIManagere.shared.updateWorksheetRecentDate(worksheetId: worksheetDetail.worksheetId) { result in

            switch result {
            case .success:
                print("Recent date updated successfully")
            case .failure(let error):
                print("Failed to update recent date: \(error)")
                // 필요한 경우 에러 처리
            }
        }
    }

    private func setupUI() {
        guard let detail = worksheetDetail else { return }

        titleLabel.text = detail.name
        categoryLabel.text = detail.category

        workSheetView = WorkSheetView(
            frame: view.bounds,
            viewWidth: view.frame.width - 48,
            text: detail.content,
            answers: detail.answer1
        )

        reloadUserAnswers()

        if detail.isCompleteAllBlanks {
            finishImage.isHidden = false
            doneButton.setTitleColor(MemorableColor.White, for: .normal)
            doneButton.backgroundColor = MemorableColor.Blue2
            doneButton.isEnabled = true
        }

        if detail.isAddWorksheet {
            finishAddWorksheet()
        }

        if detail.isMakeTestSheet {
            finishImage.removeFromSuperview()
            finishImage.snp.removeConstraints()
            finishImage.isHidden = true
            finishImage2.isHidden = false

            doneButton.setTitleColor(MemorableColor.Gray1, for: .normal)
            doneButton.backgroundColor = MemorableColor.Gray4
            doneButton.isEnabled = false
        }
    }

    // MARK: - Button Action

    @objc func didTapResetButton() {
        let alert = UIAlertController(
            title: "초기화하기",
            message: "작성한 키워드를 초기화하시겠습니까?\n이 작업은 복구할 수 없습니다.",
            preferredStyle: .alert
        )

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

        guard let worksheet = workSheetView as? WorkSheetView else {
            print("WorkSheetView를 찾을 수 없습니다.")
            return
        }

        guard let detail = worksheetDetail else {
            print("WorkSheetDetail을 찾을 수 없습니다.")
            return
        }

        if isFirstSheetSelected {
            userAnswer = worksheet.userAnswers.map { $0.text ?? "" }
            answerLength = worksheet.userAnswers.count

            print("✅ 실제 답안: \(detail.answer1)")
            print("☑️ 유저 답안: \(userAnswer)")

            DispatchQueue.main.async {
                for idx in 0 ..< self.answerLength {
                    let textField = worksheet.userAnswers[idx]

                    // 값을 안 쓴 부분
                    if self.userAnswer[idx].replacingOccurrences(of: " ", with: "")
                        .isEmpty
                    {
                        textField.textColor = .lightGray
                        textField.text = detail.answer1[idx]
                    }
                    // 값이 동일
                    else if detail.answer1[idx].replacingOccurrences(of: " ", with: "")
                        == self.userAnswer[idx].replacingOccurrences(of: " ", with: "")
                    {
                        self.correctCount += 1
                        textField.textColor = .blue
                    }
                    // 나머지 (= 틀림)
                    else {
                        textField.textColor = .red
                        textField.text = detail.answer1[idx]
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
        else {
            userAnswer = worksheet.userAnswers.map { $0.text ?? "" }
            answerLength = worksheet.userAnswers.count

            print("✅ 실제 답안: \(detail.answer2)")
            print("☑️ 유저 답안: \(userAnswer)")

            DispatchQueue.main.async {
                for idx in 0 ..< self.answerLength {
                    let textField = worksheet.userAnswers[idx]

                    // 값을 안 쓴 부분
                    if self.userAnswer[idx].replacingOccurrences(of: " ", with: "")
                        .isEmpty
                    {
                        textField.textColor = .lightGray
                        textField.text = detail.answer2[idx]
                    }
                    // 값이 동일
                    else if detail.answer2[idx].replacingOccurrences(of: " ", with: "")
                        == self.userAnswer[idx].replacingOccurrences(of: " ", with: "")
                    {
                        self.correctCount += 1
                        textField.textColor = .blue
                    }
                    // 나머지 (= 틀림)
                    else {
                        textField.textColor = .red
                        textField.text = detail.answer2[idx]
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
        guard let detail = worksheetDetail else {
            print("detail 없음")
            return
        }

        finishImage.isHidden = false
        doneButton.setTitleColor(MemorableColor.White, for: .normal)
        doneButton.backgroundColor = MemorableColor.Blue2
        doneButton.isEnabled = true

        // DONE
        APIManager.shared.updateData(to: "/api/worksheet/done/\(detail.worksheetId)", body: detail) { result in
            switch result {
            case .success:
                print("isCompleteAllBlanks Update 성공")
            case .failure(let error):
                print("Update 실패: \(error.localizedDescription)")
            }
        }
    }

    @objc func didTapDoneButton() {
        print("DONE")
        let alert = UIAlertController(title: "시험지 받기", message: "시험지가 자동으로 생성되고\n생성된 시험지로 이동합니다.", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            print("PRESS CANCEL")
        }

        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            print("PRESS CONFIRM")
            guard let detail = self.worksheetDetail else {
                print("detail 없음")
                return
            }
            APIManager.shared.updateData(to: "/api/worksheet/make/\(detail.worksheetId)", body: detail) { result in
                switch result {
                case .success:
                    print("isMakeTestSheet Update 성공")
                case .failure(let error):
                    print("Update 실패: \(error.localizedDescription)")
                }
            }

            APIManager.shared.postData(to: "/api/testsheet/\(detail.worksheetId)", body: detail) { (result: Result<TestsheetDetail, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let testSheetDetail):
                        print("Testsheet successfully posted")
                        let testSheetVC = TestSheetViewController()
                        testSheetVC.testsheetDetail = testSheetDetail
                        self.navigationController?.setViewControllers([HomeViewController(), testSheetVC], animated: true)

                    case .failure(let error):
                        print("Error posting testsheet: \(error.localizedDescription)")
                    }
                }
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }

    @objc func didTapBackButton() {
        print("GO BACK")

        saveUserAnswers()

        navigationController?.popViewController(animated: true)
    }

    private func saveUserAnswers() {
        guard let worksheet = workSheetView as? WorkSheetView else {
            print("WorkSheetView를 찾을 수 없습니다.")
            return
        }
        guard let detail = worksheetDetail else {
            print("Detail을 찾을 수 없습니다.")
            return
        }

        answerLength = worksheet.userAnswers.count

        if isShowingAnswer {
            for idx in 0 ..< answerLength {
                worksheet.userAnswers[idx].text = userAnswer[idx]
            }
        }
        userAnswer = worksheet.userAnswers.map { $0.text ?? "" }

        if isFirstSheetSelected {
            UserDefaults.standard.set(userAnswer, forKey: "\(detail.worksheetId)-1")
        }
        else {
            UserDefaults.standard.set(userAnswer, forKey: "\(detail.worksheetId)-2")
        }
    }

    private func reloadUserAnswers() {
        guard let worksheet = workSheetView as? WorkSheetView else {
            print("WorkSheetView를 찾을 수 없습니다.")
            return
        }
        guard let detail = worksheetDetail else { return }

        if isFirstSheetSelected {
            let prevUserAnswers: [String] = UserDefaults.standard.array(forKey: "\(detail.worksheetId)-1") as? [String] ?? []
            if !prevUserAnswers.isEmpty {
                for (index, field) in worksheet.userAnswers.enumerated() {
                    field.text = prevUserAnswers[index]
                }
            }
        }
        else {
            let prevUserAnswers: [String] = UserDefaults.standard.array(forKey: "\(detail.worksheetId)-2") as? [String] ?? []
            if !prevUserAnswers.isEmpty {
                for (index, field) in worksheet.userAnswers.enumerated() {
                    field.text = prevUserAnswers[index]
                }
            }
        }
        worksheet.layoutIfNeeded()
    }

    func finishAddWorksheet() {
        firstSheetButton.isHidden = false
        firstSheetButton.isEnabled = true
        secondSheetButton.isHidden = false
        secondSheetButton.isEnabled = true

        if isFirstSheetSelected {
            firstSheetButton.backgroundColor = MemorableColor.Yellow1
            secondSheetButton.backgroundColor = MemorableColor.Gray2
        }
        else {
            firstSheetButton.backgroundColor = MemorableColor.Gray2
            secondSheetButton.backgroundColor = MemorableColor.Yellow1
        }

        addWorkSheetButton.setTitleColor(MemorableColor.Gray2, for: .normal)
        addWorkSheetButton.isEnabled = false
    }

    @objc func didTapAddWorksheetButton() {
        print("AddWorksheet")

        let alert = UIAlertController(
            title: "추가 학습지 만들기",
            message: "빈칸을 새롭게 생성하시겠습니까?\n이전 학습지도 저장됩니다.",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            print("PRESS CANCEL")
        }

        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            print("PRESS CONFIRM")
            guard let detail = self.worksheetDetail else {
                print("detail이 없습니다.")
                return
            }

            // DONE
            APIManager.shared.updateData(to: "/api/worksheet/addsheet/\(detail.worksheetId)", body: detail) { result in
                switch result {
                case .success:
                    print("isAddWorksheet Update 성공")
                case .failure(let error):
                    print("Update 실패: \(error.localizedDescription)")
                }
            }

            self.saveUserAnswers()

            self.isShowingAnswer = false
            self.showAnswerButton.isSelected = self.isShowingAnswer
            self.resetButton.isHidden = false
            self.showAnswerButton.setTitle("키워드 보기", for: .normal)
            self.showAnswerButton.setTitle("키워드 가리기", for: .selected)
            var config = UIButton.Configuration.filled()
            config.image = UIImage(systemName: "eye")
            config.imagePadding = 10
            config.imagePlacement = .leading
            config.baseBackgroundColor = MemorableColor.Blue2
            config.baseForegroundColor = MemorableColor.White
            config.cornerStyle = .large
            self.showAnswerButton.configuration = config

            self.isFirstSheetSelected.toggle()
            self.finishAddWorksheet()

            self.workSheetView?.removeFromSuperview()
            self.addWorkSheetButton.removeFromSuperview()
            self.firstSheetButton.removeFromSuperview()
            self.secondSheetButton.removeFromSuperview()

            self.workSheetView = WorkSheetView(
                frame: self.view.bounds,
                viewWidth: self.view.frame.width - 48,
                text: detail.content,
                answers: detail.answer2
            )

            if let newWorkSheetView = self.workSheetView {
                self.view.addSubview(newWorkSheetView)
                self.view.addSubview(self.addWorkSheetButton)
                self.view.addSubview(self.firstSheetButton)
                self.view.addSubview(self.secondSheetButton)

                newWorkSheetView.snp.makeConstraints { make in
                    make.top.equalTo(self.titleLabel.snp.bottom).offset(28)
                    make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(40)
                    make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-40)
                    make.bottom.equalTo(self.showAnswerButton.snp.top).offset(-26)
                }

                self.addWorkSheetButton.snp.makeConstraints { make in
                    make.bottom.equalTo(self.workSheetView!.snp.top).offset(-10)
                    make.trailing.equalTo(self.workSheetView!.snp.trailing).offset(-28)
                }

                self.secondSheetButton.snp.makeConstraints { make in
                    make.top.equalTo(self.workSheetView!.snp.top).offset(18)
                    make.trailing.equalTo(self.workSheetView!.snp.trailing).offset(-45)
                    make.width.height.equalTo(25)
                }

                self.firstSheetButton.snp.makeConstraints { make in
                    make.top.equalTo(self.workSheetView!.snp.top).offset(18)
                    make.trailing.equalTo(self.secondSheetButton.snp.leading).offset(-10)
                    make.width.height.equalTo(25)
                }
            }

            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }

    @objc func didTapFirstSheetButton() {
        print("FirstSheetButton")
        guard let worksheetDetail = worksheetDetail else { return }

        hideWorkItem?.cancel()
        finishAddImage.isHidden = true

        saveUserAnswers()
        isFirstSheetSelected = true

        isShowingAnswer = false
        showAnswerButton.isSelected = isShowingAnswer
        showAnswerButton.setTitle("키워드 보기", for: .normal)
        showAnswerButton.setTitle("키워드 가리기", for: .selected)
        resetButton.isHidden = false

        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "eye")
        config.imagePadding = 10
        config.imagePlacement = .leading
        config.baseBackgroundColor = MemorableColor.Blue2
        config.baseForegroundColor = MemorableColor.White
        config.cornerStyle = .large

        showAnswerButton.configuration = config

        firstSheetButton.backgroundColor = MemorableColor.Yellow1
        secondSheetButton.backgroundColor = MemorableColor.Gray2

        workSheetView?.removeFromSuperview()
        addWorkSheetButton.removeFromSuperview()
        firstSheetButton.removeFromSuperview()
        secondSheetButton.removeFromSuperview()

        workSheetView = WorkSheetView(
            frame: view.bounds,
            viewWidth: view.frame.width - 48,
            text: worksheetDetail.content,
            answers: worksheetDetail.answer1
        )
        reloadUserAnswers()

        if let newWorkSheetView = workSheetView {
            view.addSubview(newWorkSheetView)
            view.addSubview(addWorkSheetButton)
            view.addSubview(firstSheetButton)
            view.addSubview(secondSheetButton)

            newWorkSheetView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(28)
                make.leading.equalTo(view.safeAreaLayoutGuide).offset(40)
                make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-40)
                make.bottom.equalTo(showAnswerButton.snp.top).offset(-26)
            }

            addWorkSheetButton.snp.makeConstraints { make in
                make.bottom.equalTo(workSheetView!.snp.top).offset(-10)
                make.trailing.equalTo(workSheetView!.snp.trailing).offset(-28)
            }

            secondSheetButton.snp.makeConstraints { make in
                make.top.equalTo(workSheetView!.snp.top).offset(18)
                make.trailing.equalTo(workSheetView!.snp.trailing).offset(-45)
                make.width.height.equalTo(25)
            }

            firstSheetButton.snp.makeConstraints { make in
                make.top.equalTo(workSheetView!.snp.top).offset(18)
                make.trailing.equalTo(secondSheetButton.snp.leading).offset(-10)
                make.width.height.equalTo(25)
            }
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    @objc func didTapSecondSheetButton() {
        print("SecondSheetButton")
        guard let worksheetDetail = worksheetDetail else { return }

        saveUserAnswers()
        isFirstSheetSelected = false

        isShowingAnswer = false
        showAnswerButton.isSelected = isShowingAnswer
        showAnswerButton.setTitle("키워드 보기", for: .normal)
        showAnswerButton.setTitle("키워드 가리기", for: .selected)
        resetButton.isHidden = false

        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "eye")
        config.imagePadding = 10
        config.imagePlacement = .leading
        config.baseBackgroundColor = MemorableColor.Blue2
        config.baseForegroundColor = MemorableColor.White
        config.cornerStyle = .large

        showAnswerButton.configuration = config

        firstSheetButton.backgroundColor = MemorableColor.Gray2
        secondSheetButton.backgroundColor = MemorableColor.Yellow1

        workSheetView?.removeFromSuperview()
        addWorkSheetButton.removeFromSuperview()
        firstSheetButton.removeFromSuperview()
        secondSheetButton.removeFromSuperview()
        finishAddImage.removeFromSuperview()

        workSheetView = WorkSheetView(
            frame: view.bounds,
            viewWidth: view.frame.width - 48,
            text: worksheetDetail.content,
            answers: worksheetDetail.answer2
        )
        reloadUserAnswers()

        if let newWorkSheetView = workSheetView {
            view.addSubview(newWorkSheetView)
            view.addSubview(addWorkSheetButton)
            view.addSubview(firstSheetButton)
            view.addSubview(secondSheetButton)
            view.addSubview(finishAddImage)

            newWorkSheetView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(28)
                make.leading.equalTo(view.safeAreaLayoutGuide).offset(40)
                make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-40)
                make.bottom.equalTo(showAnswerButton.snp.top).offset(-26)
            }

            addWorkSheetButton.snp.makeConstraints { make in
                make.bottom.equalTo(workSheetView!.snp.top).offset(-10)
                make.trailing.equalTo(workSheetView!.snp.trailing).offset(-28)
            }

            finishAddImage.snp.makeConstraints { make in
                make.trailing.equalTo(addWorkSheetButton.snp.leading).offset(-10)
                make.bottom.equalTo(workSheetView!.snp.top).offset(-10)
            }

            secondSheetButton.snp.makeConstraints { make in
                make.top.equalTo(workSheetView!.snp.top).offset(18)
                make.trailing.equalTo(workSheetView!.snp.trailing).offset(-45)
                make.width.height.equalTo(25)
            }

            firstSheetButton.snp.makeConstraints { make in
                make.top.equalTo(workSheetView!.snp.top).offset(18)
                make.trailing.equalTo(secondSheetButton.snp.leading).offset(-10)
                make.width.height.equalTo(25)
            }
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()

        finishAddImage.isHidden = false

        hideWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.finishAddImage.isHidden = true
        }
        hideWorkItem = workItem

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }

    // MARK: - Default Setting

    func setupButtons() {
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        addWorkSheetButton.addTarget(self, action: #selector(didTapAddWorksheetButton), for: .touchUpInside)
        firstSheetButton.addTarget(self, action: #selector(didTapFirstSheetButton), for: .touchUpInside)
        secondSheetButton.addTarget(self, action: #selector(didTapSecondSheetButton), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        showAnswerButton.addTarget(self, action: #selector(didTapShowAnswerButton), for: .touchUpInside)

        if isFirstSheetSelected {
            firstSheetButton.backgroundColor = MemorableColor.Yellow1
            secondSheetButton.backgroundColor = MemorableColor.Gray2
        }
        else {
            firstSheetButton.backgroundColor = MemorableColor.Gray2
            secondSheetButton.backgroundColor = MemorableColor.Yellow1
        }
    }

    func addSubViews() {
        view.addSubview(logoImageView)
        view.addSubview(backButton)
        view.addSubview(finishImage)
        view.addSubview(finishImage2)
        view.addSubview(doneButton)
        view.addSubview(titleLabel)
        view.addSubview(categoryLabel)
        view.addSubview(workSheetView!)
        view.addSubview(firstSheetButton)
        view.addSubview(secondSheetButton)
        view.addSubview(finishAddImage)
        view.addSubview(addWorkSheetButton)
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

        finishImage2.snp.makeConstraints { make in
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

        addWorkSheetButton.snp.makeConstraints { make in
            make.bottom.equalTo(workSheetView!.snp.top).offset(-10)
            make.trailing.equalTo(workSheetView!.snp.trailing).offset(-28)
        }

        finishAddImage.snp.makeConstraints { make in
            make.trailing.equalTo(addWorkSheetButton.snp.leading)
            make.bottom.equalTo(workSheetView!.snp.top).offset(-10)
        }

        secondSheetButton.snp.makeConstraints { make in
            make.top.equalTo(workSheetView!.snp.top).offset(18)
            make.trailing.equalTo(workSheetView!.snp.trailing).offset(-45)
            make.width.height.equalTo(25)
        }

        firstSheetButton.snp.makeConstraints { make in
            make.top.equalTo(workSheetView!.snp.top).offset(18)
            make.trailing.equalTo(secondSheetButton.snp.leading).offset(-10)
            make.width.height.equalTo(25)
        }
    }
}
