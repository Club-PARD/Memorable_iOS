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
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 0.5 * 40
        $0.clipsToBounds = true
    }

    private let categoryTitleLabel = UILabel().then {
        $0.text = "카테고리명"
        $0.font = UIFont.systemFont(ofSize: 34, weight: .bold)
    }

    private let fileNameLabel = UILabel().then {
        $0.text = "파일명 외 4개 파일"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        $0.textColor = .gray
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

        setupButtons()

        addSubViews()
        setupConstraints()
    }

    // MARK: - Button Settings

    func setupButtons() {
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }

    @objc func didTapBackButton() {
        print("GO BACK")
        navigationController?.popViewController(animated: true)
    }

    // MARK: - General Settings

    func addSubViews() {
        view.addSubview(logoImageView)
        view.addSubview(backButton)

        view.addSubview(categoryTitleLabel)
        view.addSubview(fileNameLabel)

        view.addSubview(resetButton)
        view.addSubview(showAnswerButton)
    }

    func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.height.equalTo(24)
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.leading.equalTo(logoImageView.snp.trailing).offset(20)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }

        categoryTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(28)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(24)
        }

        fileNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryTitleLabel.snp.trailing).offset(12)
            make.centerY.equalTo(categoryTitleLabel.snp.centerY)
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
    }
}
