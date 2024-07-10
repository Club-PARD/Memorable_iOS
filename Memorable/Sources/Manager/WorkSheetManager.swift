//
//  WorkSheetManager.swift
//  Memorable
//
//  Created by 김현기 on 7/8/24.
//

import UIKit

class WorkSheetManager {
    static let shared = WorkSheetManager()

    // Work Sheet 세부정보
    var worksheetDetail: WorksheetDetail?
    // 첫번째 Work Sheet View를 보이고 있는지
    var isFirstSheetSelected: Bool = true
    // Work Sheet에 유저가 입력한 정답 배열
    var userAnswer: [String] = []
    // 현재 정답을 보여주고 있는 지 여부
    var isShowingAnswer = false

    var correctCount: Int = 0

    private var userStartedEditing: [Bool] = []

    // 최근 본 파일 업데이트해주는 함수
    func updateRecentDate() {
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

    // 뒤로 가기 할떄 유저가 입력한 정답을 저장하는 함수
    func saveUserAnswers(worksheet: UIView?) {
        guard let worksheet = worksheet as? WorkSheetView else {
            print("WorkSheetView를 찾을 수 없습니다.")
            return
        }
        guard let detail = worksheetDetail else {
            print("Detail을 찾을 수 없습니다.")
            return
        }

        if isShowingAnswer {
            for idx in 0 ..< worksheet.userAnswers.count {
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

        isShowingAnswer = false
    }

    // 이전에 유저가 입력한 정답을 불러오는 함수
    func reloadUserAnswers(worksheet: UIView?) {
        guard let worksheet = worksheet as? WorkSheetView else {
            print("WorkSheetView를 찾을 수 없습니다.")
            return
        }
        guard let detail = worksheetDetail else { return }

        if isFirstSheetSelected {
            print("isFirstSheetSelected")

            let prevUserAnswers: [String] = UserDefaults.standard.array(forKey: "\(detail.worksheetId)-1") as? [String] ?? []
            if prevUserAnswers.isEmpty {
                return
            }
            else {
                for (index, field) in worksheet.userAnswers.enumerated() {
                    field.text = prevUserAnswers[index]
                }
            }
        }
        else {
            print("isSecondSheetSelected")

            let prevUserAnswers: [String] = UserDefaults.standard.array(forKey: "\(detail.worksheetId)-2") as? [String] ?? []
            if prevUserAnswers.isEmpty {
                return
            }
            else {
                for (index, field) in worksheet.userAnswers.enumerated() {
                    field.text = prevUserAnswers[index]
                }
            }
        }
        worksheet.layoutIfNeeded()
    }

    func correctAll() {
        print("CORRECT ALL")
        guard let detail = worksheetDetail else {
            print("detail 없음")
            return
        }

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

    @objc func showAnswer(worksheet: UIView?, isCorrectAll: @escaping (Bool) -> Void) {
        print("SHOW ANSWER")
        correctCount = 0

        guard let worksheet = worksheet as? WorkSheetView else {
            print("WorkSheetView를 찾을 수 없습니다.")
            return
        }

        guard let detail = worksheetDetail else {
            print("WorkSheetDetail을 찾을 수 없습니다.")
            return
        }

        if isFirstSheetSelected {
            userAnswer = worksheet.userAnswers.map { $0.text ?? "" }

//            print("✅ 실제 답안: \(detail.answer1)")
//            print("☑️ 유저 답안: \(userAnswer)")

            DispatchQueue.main.async {
                self.userStartedEditing = Array(repeating: false, count: worksheet.userAnswers.count)

                for idx in 0 ..< worksheet.userAnswers.count {
                    let textField = worksheet.userAnswers[idx]

                    // 사용자 답변 저장
                    self.userAnswer[idx] = textField.text ?? ""

                    self.updateTextFieldAppearance(textField, atIndex: idx)

                    textField.isEnabled = true
                    textField.setNeedsDisplay()

                    textField.tag = idx
                    textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                    textField.addTarget(self, action: #selector(self.textFieldDidBeginEditing(_:)), for: .editingDidBegin)
                    textField.addTarget(self, action: #selector(self.textFieldDidEndEditing(_:)), for: .editingDidEnd)
                }

                if self.correctCount == self.userAnswer.count {
                    if !detail.isCompleteAllBlanks {
                        self.correctAll()
                        isCorrectAll(true)
                    }
                }

                worksheet.layoutIfNeeded()
            }
        }
        else {
            userAnswer = worksheet.userAnswers.map { $0.text ?? "" }

            //            print("✅ 실제 답안: \(detail.answer2)")
            //            print("☑️ 유저 답안: \(userAnswer)")

            DispatchQueue.main.async {
                self.userStartedEditing = Array(repeating: false, count: worksheet.userAnswers.count)

                for idx in 0 ..< worksheet.userAnswers.count {
                    let textField = worksheet.userAnswers[idx]

                    // 사용자 답변 저장
                    self.userAnswer[idx] = textField.text ?? ""

                    self.updateTextFieldAppearance(textField, atIndex: idx)

                    textField.isEnabled = true
                    textField.setNeedsDisplay()

                    textField.tag = idx
                    textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                    textField.addTarget(self, action: #selector(self.textFieldDidBeginEditing(_:)), for: .editingDidBegin)
                    textField.addTarget(self, action: #selector(self.textFieldDidEndEditing(_:)), for: .editingDidEnd)
                }

                if self.correctCount == self.userAnswer.count {
                    if !detail.isCompleteAllBlanks {
                        self.correctAll()
                        isCorrectAll(true)
                    }
                }

                worksheet.layoutIfNeeded()
            }
        }
    }

    func hideAnswer(worksheet: UIView?) {
        print("HIDE ANSWER")

        guard let worksheet = worksheet as? WorkSheetView else {
            print("WorkSheetView를 찾을 수 없습니다.")
            return
        }

        DispatchQueue.main.async {
            self.userStartedEditing = []

            for idx in 0 ..< worksheet.userAnswers.count {
                let textField = worksheet.userAnswers[idx]
                textField.text = self.userAnswer[idx]
                textField.textColor = MemorableColor.Black
                textField.placeholder = ""
                textField.isEnabled = true
                textField.setNeedsDisplay()

                textField.removeTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                textField.removeTarget(self, action: #selector(self.textFieldDidBeginEditing(_:)), for: .editingDidBegin)
                textField.removeTarget(self, action: #selector(self.textFieldDidEndEditing(_:)), for: .editingDidEnd)
            }

            worksheet.layoutIfNeeded()
        }

        isShowingAnswer = false
    }

    // 만약 키워드보기 버튼이 눌려있는 상태라면 상태 파악해서 바로 바꿔주기.
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard isShowingAnswer, let detail = worksheetDetail else { return }

        let index = textField.tag
        userAnswer[index] = textField.text ?? ""

        updateTextFieldAppearance(textField, atIndex: index)
    }

    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        print("DID BEGIN EDITING")
        let index = textField.tag
        userStartedEditing[index] = true
    }

    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        print("DID END EDITING")
        let index = textField.tag
        if userAnswer[index] == "" {
            textField.text = ""
        }
    }

    private func updateTextFieldAppearance(_ textField: UITextField, atIndex index: Int) {
        guard let detail = worksheetDetail else { return }

        let correctAnswer = isFirstSheetSelected ? detail.answer1[index] : detail.answer2[index]
        let userInput = userAnswer[index].replacingOccurrences(of: " ", with: "")

        if userInput.isEmpty {
            if userStartedEditing[index] {
                textField.placeholder = correctAnswer
                textField.text = ""
            }
            else {
                textField.textColor = MemorableColor.Gray2
                textField.placeholder = correctAnswer
                textField.text = ""
            }
        }
        else if userInput.lowercased() == correctAnswer.replacingOccurrences(of: " ", with: "").lowercased() {
            textField.textColor = MemorableColor.Blue1
        }
        else {
            textField.textColor = MemorableColor.Red
        }

        updateCorrectCount()
    }

    private func updateCorrectCount() {
        guard let detail = worksheetDetail else { return }

        correctCount = 0
        for (index, userInput) in userAnswer.enumerated() {
            let correctAnswer = isFirstSheetSelected ? detail.answer1[index] : detail.answer2[index]
            if userInput.replacingOccurrences(of: " ", with: "").lowercased() == correctAnswer.replacingOccurrences(of: " ", with: "").lowercased() {
                correctCount += 1
            }
        }
    }
}
