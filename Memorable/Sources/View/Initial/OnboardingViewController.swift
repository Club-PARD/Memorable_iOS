//
//  Onboarding1ViewController.swift
//  Memorable
//
//  Created by 김현기 on 7/3/24.
//

import SnapKit
import Then
import UIKit

class OnboardingViewController: UIPageViewController {
    private var pages: [UIViewController] = []
    private var currentIndex: Int = 0

    private let progressBarView = ProgressBarView(frame: .zero, totalPages: 3, currentPage: 1).then {
        $0.contentMode = .scaleAspectFit
    }

    private let nextButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = MemorableFont.Button()
        $0.backgroundColor = MemorableColor.Black
        $0.layer.cornerRadius = 30
    }

    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey: Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        setupUI()
        setupButton()
    }

    private func setupPageViewController() {
        dataSource = self
        delegate = self

        pages = [
            OnboardingContentViewController(content: Onboarding1()),
            OnboardingContentViewController(content: Onboarding2()),
            OnboardingContentViewController(content: Onboarding3())
        ]

        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }

    private func setupUI() {
        view.backgroundColor = MemorableColor.White
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(progressBarView)
        view.addSubview(nextButton)

        progressBarView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
        }

        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
            make.width.equalTo(460)
            make.height.equalTo(60)
        }
    }

    private func setupButton() {
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }

    @objc private func didTapNext() {
        if currentIndex == pages.count - 1 {
            navigationController?.setViewControllers([HomeViewController()], animated: true)
        } else {
            goToNextPage()
        }
    }

    private func goToNextPage() {
        guard currentIndex < pages.count - 1 else { return }
        currentIndex += 1
        setViewControllers([pages[currentIndex]], direction: .forward, animated: true, completion: nil)
        updateUI()
    }

    private func updateUI() {
        progressBarView.updateCurrentPage(currentIndex + 1)
        nextButton.setTitle(currentIndex == pages.count - 1 ? "시작하기" : "다음", for: .normal)
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let visibleViewController = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: visibleViewController)
        {
            currentIndex = index
            updateUI()
        }
    }
}

class OnboardingContentViewController: UIViewController {
    private let contentView: UIView

    init(content: UIView) {
        self.contentView = content
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
    }
}
