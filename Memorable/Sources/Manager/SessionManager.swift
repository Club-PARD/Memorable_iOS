//
//  SessionManager.swift
//  Memorable
//
//  Created by 김현기 on 6/25/24.
//

import AuthenticationServices

class SessionManager {
    static let shared = SessionManager()

    private init() {}

    func saveToKeychain(appleIDCredential: ASAuthorizationAppleIDCredential) {
        do {
            let encodedCredential = try NSKeyedArchiver.archivedData(withRootObject: appleIDCredential, requiringSecureCoding: true)

            let keychainQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "your.bundle",
                kSecAttrAccount as String: "appleIDToken",
                kSecValueData as String: encodedCredential,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
            ]

            let status = SecItemAdd(keychainQuery as CFDictionary, nil)
            if status == errSecSuccess {
                print("Token stored in Keychain successfully")
            } else if status == errSecDuplicateItem {
                print("Token already exists in Keychain")
            } else {
                print("Error storing token in Keychain with status: \(status)")
                // Handle the error appropriately
            }
        } catch {
            print("Error encoding credential: \(error)")
        }
    }

    func retrieveFromKeychain() -> ASAuthorizationAppleIDCredential? {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "your.bundle",
            kSecAttrAccount as String: "appleIDToken",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &result)

        if status == errSecSuccess, let tokenData = result as? Data {
            do {
                if let credential = try NSKeyedUnarchiver.unarchivedObject(ofClass: ASAuthorizationAppleIDCredential.self, from: tokenData) {
                    return credential
                } else {
                    print("Credential could not be unarchived")
                }
            } catch {
                print("Error decoding credential: \(error)")
            }
        } else if status == errSecItemNotFound {
            print("Token not found in Keychain")
        } else {
            print("Error retrieving token from Keychain with status: \(status)")
        }
        return nil
    }

    func deleteKeychainItem(service: String, account: String) {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(keychainQuery as CFDictionary)
        if status == errSecSuccess {
            print("Keychain item deleted successfully")
        } else if status == errSecItemNotFound {
            print("Keychain item not found")
        } else {
            print("Error deleting Keychain item with status: \(status)")
        }
    }
}
