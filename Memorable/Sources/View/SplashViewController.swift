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

        // Do any additional setup after loading the view.
        gifImage.animate(withGIFNamed: "memorable_splash")
        Timer.scheduledTimer(withTimeInterval: 2.2, repeats: false, block: { [weak self] _ in

            self?.gifImage.stopAnimatingGIF()
            self?.navigateToView()
        })

        view.addSubview(gifImage)
        gifImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-54)
            make.width.equalTo(276)
        }
    }

    func navigateToView() {
        // 로그인 상태 확인
        SignInManager.checkUserAuth { authState in
            DispatchQueue.main.async {
                switch authState {
                case .undefined, .signedOut:
                    let loginViewController = LoginViewController()
                    self.navigationController?.setViewControllers([loginViewController], animated: false)

                case .signedIn:
                    let homeViewController = HomeViewController()
                    self.navigationController?.setViewControllers([homeViewController], animated: false)
                }
            }
        }
    }
}
