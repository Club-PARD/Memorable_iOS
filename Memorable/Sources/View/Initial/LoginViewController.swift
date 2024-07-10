//
//  ViewController.swift
//  Memorable
//
//  Created by 김현기 on 6/23/24.
//

import AuthenticationServices
import SnapKit
import Then
import UIKit

protocol LoginViewControllerDelegate: AnyObject {
    func loginDidComplete()
}

class LoginViewController: UIViewController {
    weak var delegate: LoginViewControllerDelegate?
    
    let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "login_applogo")
    }

    lazy var appleLoginButton = ASAuthorizationAppleIDButton(
        authorizationButtonType: .signIn,
        authorizationButtonStyle: .black
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupAppleLoginButton()
        addSubViews()
        setupConstraints()
    }

    // Apple Login 버튼 설정
    func setupAppleLoginButton() {
        appleLoginButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    func addSubViews() {
        view.addSubview(logoImageView)
        view.addSubview(appleLoginButton)
    }
    
    func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.width.equalTo(280)
        }
        appleLoginButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(375)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(150)
        }
    }
    
    // Apple Login 버튼 클릭 시
    @objc func didTapSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        // 로그인 버튼을 누른 후, 들어간 ID, PW 정보로 Authorization Controller (클릭시 팝업 되는 녀석) 생성
        let authController = ASAuthorizationController(authorizationRequests: [request])

        authController.delegate = self
        // ASAuthorizationControllerDelegate 프로토콜이 필요함
        authController.presentationContextProvider = self
        authController.performRequests()
    }
}

// Authorization Controller Delegate 프로토콜
extension LoginViewController: ASAuthorizationControllerDelegate {
    private func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
        print("Registering New Account with User: \(credential.user)")
//        setupActivityIndicator(view: view)
        
        let userIdentifier: String = credential.user
        let givenName: String = credential.fullName?.givenName ?? "NIL"
        let familyName: String = credential.fullName?.familyName ?? "NIL"
        let email: String = credential.email ?? "NIL"
        
        let userData = User(
            identifier: userIdentifier,
            givenName: givenName,
            familyName: familyName,
            email: email
        )
        
        APIManager.shared.postData(to: "/api/users", body: userData) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success:
//                removeActivityIndicator()
                print("User successfully posted")
                self.dismiss(animated: true)
                self.delegate?.loginDidComplete()
                self.navigationController?.setViewControllers([OnboardingViewController()], animated: true)
            case .failure(let error):
//                removeActivityIndicator()
                print("Error posting user: \(error)")
            }
        }
    }
    
    private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
        print("Signing in with existing account with user: \(credential.user)")
        setupActivityIndicator(view: view)
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            let userData = User(identifier: "aaaa", givenName: "bbbb", familyName: "cccc", email: "eeee@gmail.com")
            
//            APIManager.shared.postData(to: "/api/users", body: userData) { (result: Result<EmptyResponse, Error>) in
//                removeActivityIndicator()
//                switch result {
//                case .success:
//                    print("User successfully posted")
//                    self.dismiss(animated: true)
//                    self.delegate?.loginDidComplete()
//                    self.navigationController?.setViewControllers([OnboardingViewController()], animated: true)
//                case .failure(let error):
//                    print("Error posting user: \(error)")
//                }
//            }
    
            APIManager.shared.getData(to: "/api/users/\(credential.user)") { (info: User?, error: Error?) in

                DispatchQueue.main.async {
                    // 3. 받아온 데이터 처리
                    if let error = error {
                        print("Error fetching data: \(error)")
                        removeActivityIndicator()
                        self.signOut()
                        return
                    }

                    guard let user = info else {
                        print("No data received")
                        removeActivityIndicator()
                        self.signOut()
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
                    self.delegate?.loginDidComplete()
                    self.navigationController?.setViewControllers([HomeViewController()], animated: true)
                }
            }
        }
    }
    
    private func signInWithUserAndPassword(credential: ASPasswordCredential) {
        print("Signing in using an existing iCloud Keychain credential with user: \(credential.user)")
        
        dismiss(animated: true)
        navigationController?.setViewControllers([HomeViewController()], animated: true)
    }
    
    // Authorization 과정이 끝났을 때
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // 우리 앱에 계정을 생성한다.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
//            if let authorizationCode = appleIDCredential.authorizationCode,
//               let identityToken = appleIDCredential.identityToken,
//               let authCodeString = String(data: authorizationCode, encoding: .utf8),
//               let identifyTokenString = String(data: identityToken, encoding: .utf8)
//            {
//                print("authorizationCode: \(authorizationCode)")
//                print("identityToken: \(identityToken)")
//                print("authCodeString: \(authCodeString)")
//                print("identifyTokenString: \(identifyTokenString)")
//            }
            
            print("User Identifier: \(userIdentifier)")
            
            UserDefaults.standard.set(userIdentifier, forKey: SignInManager.userIdentifierKey)
            if fullName != nil && email != nil {
                let user = User(identifier: userIdentifier, givenName: fullName?.givenName ?? "NIL", familyName: fullName?.familyName ?? "NIL", email: email ?? "NIL")
                
                if let encodeData = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encodeData, forKey: "userInfo")
                }
                
                print("👥 User Info Saved")
            }
            
            if let _ = appleIDCredential.email, let _ = appleIDCredential.fullName {
                registerNewAccount(credential: appleIDCredential)
            } else {
                signInWithExistingAccount(credential: appleIDCredential)
            }
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("User Name: \(username)")
            print("Password: \(password)")
            
            UserDefaults.standard.set(username, forKey: SignInManager.userIdentifierKey)
            
            signInWithUserAndPassword(credential: passwordCredential)
            
        default:
            break
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        // Handle Error
        print("‼️ Failed!!")
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func signOut() {
        print("❎ Signed Out")

        UserDefaults.standard.removeObject(forKey: SignInManager.userIdentifierKey)
        navigationController?.setViewControllers([LoginViewController()], animated: false)
    }
}
    
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
