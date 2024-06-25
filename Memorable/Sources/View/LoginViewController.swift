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

class LoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupAppleLoginButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        performExistingAccountSetupFlows()
    }
    
    // Apple Login 버튼 설정
    func setupAppleLoginButton() {
        let authorizationButton = ASAuthorizationAppleIDButton().then {
            $0.addTarget(self, action: #selector(self.handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        }
        view.addSubview(authorizationButton)
    }
    
    // Apple Login 버튼 클릭 시
    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        // 로그인 버튼을 누른 후, 들어간 ID, PW 정보로 Authorization Controller 생성
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        // ASAuthorizationControllerDelegate 프로토콜이 필요함
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // 현재 로그인이 되어 있는지 확인
    func performExistingAccountSetupFlows() {
        let requests = [
            ASAuthorizationAppleIDProvider().createRequest(),
            ASAuthorizationPasswordProvider().createRequest()
        ]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// Authorization Controller Delegate 프로토콜
extension LoginViewController: ASAuthorizationControllerDelegate {
    // Authorization 과정이 끝났을 때
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        switch authorization.credential {
//        case let appleIDCredential as ASAuthorizationAppleIDCredential:
//
//            // 우리 앱에 계정을 생성한다.
//            let userIdentifier = appleIDCredential.user
//            let fullName = appleIDCredential.fullName
//            let email = appleIDCredential.email
//
//            // userIdentifier를 키체인에 저장한다.
//            saveUserInKeyChain(userIdentifier: userIdentifier)
//
//            // show Apple ID credential information to HomeViewController
//        }
//    }
    
    // userIdentifer를 키체인에 저장하는 함수
    private func saveUserInKeyChain(userIdentifier: String) {
        do {
            try KeychainItem(service: "io.pard.Memorable24", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("⚠️ Unable to save userIdentifier to keychain")
        }
    }
    
    // 로그인한 Apple ID Credential 정보를 HomeViewController에서 보여준다.
    private func showHomeViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        guard let viewController = presentingViewController as? HomeViewController
        else { return }
        
//        DispatchQueue.main.async {
//            viewController.userIdentifierLabel.text = userIdentifier
//            if let givenName = fullName?.givenName {
//                viewController.givenNameLabel.text = givenName
//            }
//            if let familyName = fullName?.familyName {
//                viewController.familyNameLabel.text = familyName
//            }
//            if let email = email {
//                viewController.emailLabel.text = email
//            }
//            self.dismiss(animated: true, completion: nil)
//        }
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
