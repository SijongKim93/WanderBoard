//
//  AppDelegate.swift
//  WanderBoard
//
//  Created by 김시종 on 5/28/24.
//

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import KakaoSDKCommon
import KakaoSDKAuth


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        if FirebaseApp.app() == nil {
            ErrorUtility.shared.presentErrorAlertAndTerminate(with: "앱 초기화에 실패했습니다. 나중에 다시 시도해 주세요.")
            return false
        }
        
        KakaoSDK.initSDK(appKey: "fdaab28c4efeacf52167771728104865")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        configureInitialViewController()
        return true
    }
    
    private func configureInitialViewController() {
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            if let currentUser = Auth.auth().currentUser {
                let uid = currentUser.uid
                Firestore.firestore().collection("users").document(uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.data()
                        let isProfileComplete = data?["isProfileComplete"] as? Bool ?? false
                        DispatchQueue.main.async {
                            let initialViewController: UIViewController
                            if isProfileComplete {
                                initialViewController = PageViewController()
                            } else {
                                initialViewController = AuthenticationVC()
                            }
                            self.window?.rootViewController = initialViewController
                            self.window?.makeKeyAndVisible()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.window?.rootViewController = AuthenticationVC()
                            self.window?.makeKeyAndVisible()
                        }
                    }
                }
            } else {
                window?.rootViewController = AuthenticationVC()
                window?.makeKeyAndVisible()
            }
        } else {
            window?.rootViewController = AuthenticationVC()
            window?.makeKeyAndVisible()
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WanderBoard")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
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
}
