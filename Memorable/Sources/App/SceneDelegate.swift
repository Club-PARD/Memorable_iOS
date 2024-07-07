//
//  SceneDelegate.swift
//  Memorable
//
//  Created by 김현기 on 6/23/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var pendingURL: URL?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)

        let initialVC = SplashViewController()
        let navigationVC = UINavigationController(rootViewController: initialVC)
        
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }
        
        window?.rootViewController = navigationVC
        window?.makeKeyAndVisible()
        
        // Handle incoming URL if the app was opened with one
        if let urlContext = connectionOptions.urlContexts.first {
            pendingURL = urlContext.url
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleURL(url)
    }
    
    func handleURL(_ url: URL) {
        guard url.scheme == "memorable", url.host == "worksheet" else {
            return
        }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let sheetName = components?.queryItems?.first(where: { $0.name == "name" })?.value?.removingPercentEncoding
        let sheetCategory = components?.queryItems?.first(where: { $0.name == "category" })?.value?.removingPercentEncoding
        let sheetText = components?.queryItems?.first(where: { $0.name == "text" })?.value?.removingPercentEncoding
        
        if isLoggedIn() {
            navigateToWorksheet(name: sheetName, category: sheetCategory, text: sheetText)
        } else {
            pendingURL = url
            navigateToLogin()
        }
    }
    
    func isLoggedIn() -> Bool {
        // 로그인 상태 확인 로직 구현
        // 예: UserDefaults나 KeyChain에서 토큰 확인
        return false // 임시로 false 반환
    }
    
    func navigateToLogin() {
        let loginVC = LoginViewController()
        loginVC.delegate = self
        if let navigationController = window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(loginVC, animated: true)
        }
    }
    
    func navigateToWorksheet(name: String?, category: String?, text: String?) {
        let worksheetVC = WorkSheetViewController()
        worksheetVC.sharedName = name
        worksheetVC.sharedCategory = category
        worksheetVC.sharedText = text
        
        if let navigationController = window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(worksheetVC, animated: true)
        }
    }
}

extension SceneDelegate: LoginViewControllerDelegate {
    func loginDidComplete() {
        if let url = pendingURL {
            handleURL(url)
            pendingURL = nil
        } else {
            // 일반적인 로그인 후 홈 화면으로 이동
            navigateToHome()
        }
    }
    
    func navigateToHome() {
        let homeVC = HomeViewController()
        if let navigationController = window?.rootViewController as? UINavigationController {
            navigationController.setViewControllers([homeVC], animated: true)
        }
    }
}
