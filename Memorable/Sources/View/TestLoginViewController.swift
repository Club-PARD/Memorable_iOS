//
//  TestLoginViewController.swift
//  Memorable
//
//  Created by 김현기 on 6/25/24.
//

import SnapKit
import Then
import UIKit

class TestViewController: UIViewController {
    var userIdentifier: String = ""
    var givenName: String = ""
    var familyName: String = ""
    var email: String = ""

    var userIdentifierLabel = UILabel()
    var nameLabel = UILabel()
    var emailLabel = UILabel()

    var signOutButton = UIButton().then {
        $0.setTitle("로그아웃", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        print("📊 App Directory: \(NSHomeDirectory())")

        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)

        setLabels()
        addSubViews()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SignInManager.checkUserAuth { authState in
            switch authState {
            case .undefined:
                let controller = LoginViewController()
                controller.modalPresentationStyle = .fullScreen
                controller.delegate = self
                self.present(controller, animated: false, completion: nil)
            case .signedOut:
                let controller = LoginViewController()
                controller.modalPresentationStyle = .fullScreen
                controller.delegate = self
                self.present(controller, animated: false, completion: nil)
            case .signedIn:
                print("✅ Signed In")
                self.didFinishAuth()
            }
        }
    }

    @objc func signOut() {
        print("❎ Signed Out")

        UserDefaults.standard.removeObject(forKey: SignInManager.userIdentifierKey)

        userIdentifier = ""
        givenName = ""
        familyName = ""
        email = ""

        DispatchQueue.main.async {
            self.showLoginViewController()
        }
    }

    func setLabels() {
        userIdentifierLabel.text = "UserIdentifier: \(userIdentifier)"
        nameLabel.text = "name: \(familyName)\(givenName)"
        emailLabel.text = "email: \(email)"
    }

    func addSubViews() {
        view.addSubview(userIdentifierLabel)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(signOutButton)
    }

    func setupConstraints() {
        userIdentifierLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.centerX.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(userIdentifierLabel).offset(20)
            make.centerX.equalToSuperview()
        }
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel).offset(20)
            make.centerX.equalToSuperview()
        }
        signOutButton.snp.makeConstraints { make in
            make.top.equalTo(emailLabel).offset(20)
            make.centerX.equalToSuperview()
        }
    }
}

extension TestViewController: LoginViewControllerDelegate {
    func didFinishAuth() {
        userIdentifier = UserDefaults.standard.string(forKey: SignInManager.userIdentifierKey)!
        userIdentifierLabel.text = "UserIdentifier: \(userIdentifier)"

        if let userData = UserDefaults.standard.data(forKey: "userInfo") {
            if let decodedData = try? JSONDecoder().decode(User.self, from: userData) {
                print("User Info: \(decodedData)")
                givenName = decodedData.givenName
                familyName = decodedData.familyName
                email = decodedData.email

                nameLabel.text = "Name: \(familyName)\(givenName)"
                emailLabel.text = "Email: \(email)"
            }
        }
    }
}
