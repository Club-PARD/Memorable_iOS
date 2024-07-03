//
//  Onboarding1ViewController.swift
//  Memorable
//
//  Created by 김현기 on 7/3/24.
//

import SnapKit
import Then
import UIKit

class OnboardingViewController: UIViewController {
    private var idx: Int = 1

    private let progressBarView = ProgressBarView(frame: .zero, totalPages: 3, currentPage: 0).then {
        $0.contentMode = .scaleAspectFit
    }

    private var onBoardingView: UIView = Onboarding1()

    private var onboardingViews: [UIView] = [Onboarding1(), Onboarding2(), Onboarding3()]

    private let nextButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = MemorableFont.Button()
        $0.backgroundColor = MemorableColor.Black
        $0.layer.cornerRadius = 30
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = MemorableColor.White
        progressBarView.updateCurrentPage(idx)

        setupButton()

        addSubViews()
        setupConstraints()
    }

    // MARK: - Button Setting

    private func setupButton() {
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }

    @objc private func didTapNext() {
        print("NEXT")
        if idx == 3 {
            print("GOTO HOME")
            navigationController?.setViewControllers([HomeViewController()], animated: true)
        }
        else {
            onBoardingView.removeFromSuperview()
            onBoardingView = onboardingViews[idx]

            view.addSubview(onBoardingView)
            onBoardingView.snp.makeConstraints { make in
                make.centerX.equalToSuperview().offset(10)
                make.bottom.equalTo(nextButton.snp.top).offset(-24)
            }

            if idx == 2 {
                nextButton.setTitle("시작하기", for: .normal)
            }

            idx += 1
            progressBarView.updateCurrentPage(idx)

            UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }

    private func addSubViews() {
        view.addSubview(progressBarView)
        view.addSubview(onBoardingView)
        view.addSubview(nextButton)
    }

    private func setupConstraints() {
        progressBarView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
        }

        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-80)
            make.width.equalTo(460)
            make.height.equalTo(60)
        }

        onBoardingView.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(10)
            make.bottom.equalTo(nextButton.snp.top).offset(-24)
        }
    }
}
