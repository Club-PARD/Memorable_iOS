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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MemorableColor.White

        view.addSubview(gifImage)
        gifImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-54)
            make.width.equalTo(276)
        }

        // Do any additional setup after loading the view.
        gifImage.animate(withGIFNamed: "memorable_splash")
        Timer.scheduledTimer(withTimeInterval: 2.2, repeats: false, block: { [weak self] _ in

            self?.gifImage.stopAnimatingGIF()
            self?.navigateToView()
        })
    }

    func navigateToView() {
        // 로그인 상태 확인
        setupActivityIndicator(view: view)

        SignInManager.checkUserAuth { authState in
            DispatchQueue.main.async {
                switch authState {
                case .undefined, .signedOut:
                    let loginViewController = LoginViewController()
                    self.navigationController?.setViewControllers([loginViewController], animated: false)

                case .signedIn(let userIdentifier):

                    APIManager.shared.getData(to: "/api/users/\(userIdentifier)") { (info: User?, error: Error?) in

                        DispatchQueue.main.async {
                            // 3. 받아온 데이터 처리
                            if let error = error {
                                print("Error fetching data: \(error)")
                                removeActivityIndicator()
                                signOut()
                                return
                            }

                            guard let user = info else {
                                print("No data received")
                                removeActivityIndicator()
                                signOut()
                                return
                            }

                            if let encodeData = try? JSONEncoder().encode(user) {
                                UserDefaults.standard.set(encodeData, forKey: "userInfo")
                                print("👥 User Info Saved")
                            }

                            print("GET: \(user.identifier)")
                            print("GET: \(user.givenName)")
                            print("GET: \(user.familyName)")
                            print("GET: \(user.email)")

                            removeActivityIndicator()
                            self.navigationController?.setViewControllers([HomeViewController()], animated: true)
                        }
                    }
                }
            }
        }

        func signOut() {
            print("❎ Signed Out")

            UserDefaults.standard.removeObject(forKey: SignInManager.userIdentifierKey)
            navigationController?.setViewControllers([LoginViewController()], animated: false)
        }
    }
}
