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
        let image = UIImage(systemName: "chevron.left")
        $0.setImage(image, for: .normal)
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 0.5 * 40
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

    private var workSheetView: UIView?

    private let resetButton = UIButton().then {
        $0.setTitle("초기화하기", for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
    }

    private let showAnswerButton = UIButton().then {
        $0.setTitle("키워드 보기", for: .normal)
        $0.backgroundColor = .systemGray
        $0.layer.cornerRadius = 22
        $0.contentMode = .scaleAspectFit
    }

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
        } else {
            print("WorkSheetView를 찾을 수 없습니다.")
        }
    }

    @objc func didTapShowAnswerButton() {
        print("SHOW ANSWER")
        var userAnswer: [String] = []
        
        if let worksheetView = workSheetView as? WorkSheetView {
            for answer in worksheetView.userAnswers {
                userAnswer.append(answer.text ?? "")
            }
        } else {
            print("WorkSheetView를 찾을 수 없습니다.")
        }

        print("✅ 실제 답안: \(mockAnswers)")
        print("☑️ 유저 답안: \(userAnswer)")
    }

    func setupButtons() {
        resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        showAnswerButton.addTarget(self, action: #selector(didTapShowAnswerButton), for: .touchUpInside)
    }

    func addSubViews() {
        view.addSubview(logoImageView)
        view.addSubview(backButton)
        view.addSubview(doneButton)
        view.addSubview(titleLabel)
        view.addSubview(categoryLabel)
        view.addSubview(workSheetView!)
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
    }
}
