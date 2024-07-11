//
//  SignInManager.swift
//  Memorable
//
//  Created by 김현기 on 6/25/24.
//

import AuthenticationServices
import Foundation

enum SignInManager {
    static var userIdentifierKey = ""
    static var userGivenName = ""
    static var userFamilyName = ""
    static var userEmail = ""

    static func checkUserAuth(completion: @escaping (AuthState)
        -> ())
    {
        guard let userIdentifier = UserDefaults.standard.string(forKey: "login") else {
            print("User Identifier Does Not Exist!")
            completion(.undefined)
            return
        }

        if userIdentifier == "" {
            print("User Identifier is Empty String")
            completion(.undefined)
            return
        }

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { credentialState, _ in
            DispatchQueue.main.async {
                switch credentialState {
                case .authorized:
                    print("✅ Credential State: .authorized")
                    completion(.signedIn(userIdentifier))
                case .revoked:
                    print("Credential State: .revoked")
                    completion(.undefined)
                case .notFound:
                    print("Credential State: .notFound")
                    completion(.signedOut)
                default:
                    break
                }
            }
        }
    }
}
