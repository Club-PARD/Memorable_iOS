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
            self.window?.overrideUserInterfaceStyle = .light // 라이트모드만 지원하기
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
        let sheetName = components?.queryItems?.first(where: { $0.name == "name" })?.value?.removingPercentEncoding ?? ""
        let sheetCategory = components?.queryItems?.first(where: { $0.name == "category" })?.value?.removingPercentEncoding ?? ""
        let sheetText = components?.queryItems?.first(where: { $0.name == "text" })?.value?.removingPercentEncoding ?? ""
        
        if isLoggedIn() {
            createAndNavigateToWorksheet(name: sheetName, category: sheetCategory, content: sheetText)
        } else {
            pendingURL = url
            navigateToLogin()
        }
    }
    
    func isLoggedIn() -> Bool {
        return UserDefaults.standard.string(forKey: SignInManager.userIdentifierKey) != nil
    }
    
    func navigateToLogin() {
        let loginVC = LoginViewController()
        loginVC.delegate = self
        if let navigationController = window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(loginVC, animated: true)
        }
    }
    
    func createAndNavigateToWorksheet(name: String, category: String, content: String) {
        guard let userIdentifier = UserDefaults.standard.string(forKey: SignInManager.userIdentifierKey) else {
            print("User identifier not found")
            return
        }
        
        // 인디케이터 표시
        setupActivityIndicator(view: window!)
        
        APIManagere.shared.createWorksheet(userId: userIdentifier, name: name, category: category, content: content) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let worksheetDetail):
                    removeActivityIndicator()
                    print("Successfully created worksheet: \(worksheetDetail)")
                    let workSheetVC = WorkSheetViewController()
                    WorkSheetManager.shared.worksheetDetail = worksheetDetail
                    if let navigationController = self?.window?.rootViewController as? UINavigationController {
                        navigationController.pushViewController(workSheetVC, animated: true)
                        
                        // 워크시트 생성 후 문서 목록 업데이트
                        if let homeVC = navigationController.viewControllers.first as? HomeViewController {
                            homeVC.fetchDocuments()
                            homeVC.updateAfterDocumentChange()
                        }
                    }
                case .failure(let error):
                    removeActivityIndicator()
                    print("Error creating worksheet: \(error)")
                    // 에러 처리 로직 추가
                }
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

extension SceneDelegate: LoginViewControllerDelegate {
    func loginDidComplete() {
        if let url = pendingURL {
            handleURL(url)
            pendingURL = nil
        } else {
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
