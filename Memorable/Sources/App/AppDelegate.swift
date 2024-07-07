//
//  AppDelegate.swift
//  Memorable
//
//  Created by 김현기 on 6/23/24.
//

import CoreData
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("AppDelegate: open URL called with \(url)")

        // URL 처리 로직
        if url.scheme == "memorable" && url.host == "worksheet" {
            // SceneDelegate의 handleURL 메서드 호출
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.handleURL(url)
            }
        }

        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        print("AppDelegate: didFinishLaunchingWithOptions called")
        // Override point for customization after application launch.

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("AppDelegate: configurationForConnecting called")
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("AppDelegate: didDiscardSceneSessions called")
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Memorable")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

//    // MARK: - URL Handling
//
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        print("AppDelegate: open URL called with \(url)")
//
//        // URL 처리 로직
//        if url.scheme == "memorable" && url.host == "open-shared-file" {
//            // 공유된 파일 처리 로직
//            handleSharedFile()
//        }
//
//        return true
//    }
//
//    func handleSharedFile() {
//        let userDefaults = UserDefaults(suiteName: "group.io.pard.Memorable24")
//        if userDefaults?.bool(forKey: "isSharedFile") == true,
//           let fileURLString = userDefaults?.string(forKey: "sharedFileURL"),
//           let fileName = userDefaults?.string(forKey: "sharedFileName") {
//
//            print("Shared file detected: \(fileName)")
//
//            // 여기에서 파일 처리 로직을 구현하거나
//            // 필요한 경우 NotificationCenter를 통해 다른 부분에 알림을 보낼 수 있습니다.
//            NotificationCenter.default.post(name: .didReceiveSharedFile, object: nil, userInfo: ["fileURL": fileURLString, "fileName": fileName])
//
//            // 처리 후 flag를 리셋합니다.
//            userDefaults?.set(false, forKey: "isSharedFile")
//            userDefaults?.synchronize()
//        }
//    }
}

// extension Notification.Name {
//    static let didReceiveSharedFile = Notification.Name("didReceiveSharedFile")
// }
