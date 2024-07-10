//
//  SplashViewController.swift
//  Memorable
//
//  Created by 김현기 on 7/2/24.
//

import Gifu
import SnapKit
import Then
import UIKit

class SplashViewController: UIViewController {
    private let gifImage = GIFImageView().then {
        $0.isUserInteractionEnabled = true
        $0.contentMode = .scaleAspectFit
    }

    private var isApiCallSuccess = false
    private var isMinimumDurationPassed = false
    private let minimumDuration: TimeInterval = 2.2

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MemorableColor.White

        view.addSubview(gifImage)
        gifImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-54)
            make.width.equalTo(276)
        }

        // Start animating GIF in a loop
        gifImage.animate(withGIFNamed: "memorable_splash", loopCount: 0) // 0 means infinite loop

        // Start minimum duration timer
        startMinimumDurationTimer()

        // Start API call process immediately
        checkAuthAndNavigate()
    }

    func startMinimumDurationTimer() {
        Timer.scheduledTimer(withTimeInterval: minimumDuration, repeats: false) { [weak self] _ in
            self?.isMinimumDurationPassed = true
            if (self?.isApiCallSuccess) != nil {
                self?.navigateIfReady(to: .home)
            }
            else {
                self?.navigateIfReady(to: .login)
            }
        }
    }

    func checkAuthAndNavigate() {
        SignInManager.checkUserAuth { [weak self] authState in
            guard let self = self else { return }

            switch authState {
            case .undefined, .signedOut:
                self.isApiCallSuccess = false
                self.navigateIfReady(to: .login)

            case .signedIn(let userIdentifier):
                self.isApiCallSuccess = true
                self.fetchUserData(userIdentifier: userIdentifier)
            }
        }
    }

    func fetchUserData(userIdentifier: String) {
        APIManager.shared.getData(to: "/api/users/\(userIdentifier)") { [weak self] (info: User?, error: Error?) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching data: \(error)")
                    self.handleApiError()
                    return
                }

                guard let user = info else {
                    print("No data received")
                    self.handleApiError()
                    return
                }

                self.saveUserInfo(user)
                self.isApiCallSuccess = true
                self.navigateIfReady(to: .home)
            }
        }
    }

    func saveUserInfo(_ user: User) {
        if let encodeData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodeData, forKey: "userInfo")
            print("👥 User Info Saved")
        }
        print("GET: \(user.identifier)")
        print("GET: \(user.givenName)")
        print("GET: \(user.familyName)")
        print("GET: \(user.email)")
    }

    func handleApiError() {
        isApiCallSuccess = false
        navigateIfReady(to: .login)
    }

    func signOut() {
        print("❎ Signed Out")
        UserDefaults.standard.removeObject(forKey: SignInManager.userIdentifierKey)
    }

    enum NavigationDestination {
        case login
        case home
    }

    func navigateIfReady(to destination: NavigationDestination) {
        guard isMinimumDurationPassed else { return }
        DispatchQueue.main.async {
            print(destination)
            self.gifImage.stopAnimatingGIF()
            switch destination {
            case .login:
                let loginViewController = LoginViewController()
                self.navigationController?.setViewControllers([loginViewController], animated: false)
            case .home:
                print("GO")
                self.navigationController?.setViewControllers([HomeViewController()], animated: true)
            }
        }
    }
}
