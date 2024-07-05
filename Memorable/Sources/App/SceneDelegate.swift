//
//  SceneDelegate.swift
//  Memorable
//
//  Created by 김현기 on 6/23/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)

//        let initialVC = SplashViewController()
        let initialVC = HomeViewController()

        let navigationVC = UINavigationController(rootViewController: initialVC)
        
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light // 라이트모드만 지원하기
        }
        
        window?.rootViewController = navigationVC
        window?.makeKeyAndVisible()
        
        // Handle incoming URL if the app was opened with one
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(urlContext.url)
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
        
        // Instantiate and configure TestSheetViewController with the received data
        let testSheetViewController = TestSheetViewController()
        testSheetViewController.sharedName = sheetName
        testSheetViewController.sharedCategory = sheetCategory
        testSheetViewController.sharedText = sheetText
        
        // Navigate to TestSheetViewController
        if let navigationController = window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(testSheetViewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: testSheetViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
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
