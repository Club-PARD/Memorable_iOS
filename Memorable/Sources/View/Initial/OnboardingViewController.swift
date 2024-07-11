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
    var isFromProfile: Bool = false

    private var pages: [UIViewController] = []
    private var currentIndex: Int = 0

    private let progressBarView = ProgressBarView(frame: .zero, totalPages: 7, currentPage: 1).then {
        $0.contentMode = .scaleAspectFit
    }

    init(isFromProfile: Bool = false) {
        self.isFromProfile = isFromProfile
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
    }

    private func setupPageViewController() {
        dataSource = self
        delegate = self

        pages = [
            OnboardingContentViewController(content: Onboarding1()),
            OnboardingContentViewController(content: Onboarding2()),
            OnboardingContentViewController(content: Onboarding3()),
            OnboardingContentViewController(content: Onboarding4()),
            OnboardingContentViewController(content: Onboarding5()),
            OnboardingContentViewController(content: Onboarding6()),
            OnboardingContentViewController(content: OnboardingFinish(frame: view.frame, isFromProfile: isFromProfile))
        ]

        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }

    private func setupUI() {
        view.backgroundColor = MemorableColor.White
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(progressBarView)

        progressBarView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
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
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(30)
        }
    }
}
