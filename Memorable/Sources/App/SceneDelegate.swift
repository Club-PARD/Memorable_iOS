//
//  SceneDelegate.swift
//  Memorable
//
//  Created by 김현기 on 6/23/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    /*
        앱이 Scenes에 맞춰져 있고 앱이 실행되지 않은 상태에서는 시스템은 URL을 실행 이후에 URL을 scene(_:willConnectTo:options delegate 메서드에 전달하고,
        앱이 메모리에서 실행되고 있거나 suspended된 상태에서 URL을 열 때는 scene(_:openURLContexts:)에 전달한다.
     */
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let homeViewController = SplashViewController()

        let navigationVC = UINavigationController(rootViewController: homeViewController)

        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light // 라이트모드만 지원하기
            //    self.window?.overrideUserInterfaceStyle = .dark // 다크모드만 지원하기
        }

        window?.rootViewController = navigationVC
        window?.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            print("url: \(context.url.absoluteURL)")
            print("scheme: \(context.url.scheme ?? "default")")
            print("host: \(context.url.host ?? "default")")
            print("path: \(context.url.path)")
            print("components: \(context.url.pathComponents)")
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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
