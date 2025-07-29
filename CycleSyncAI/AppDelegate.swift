//
//  AppDelegate.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 5/27/25.
//

import UIKit
import HealthKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {



        // Nothing to do here yet; permissions are requested in LaunchViewController

        // Request HealthKit permissions on first launch
        HealthManager.shared.requestAuthorization { success, error in
            if let error = error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            } else {
                print("HealthKit authorization success: \(success)")
            }
        }

        // Request notification permissions on first launch
        if !UserDefaults.standard.bool(forKey: "notificationPermissionAsked") {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "notificationPermissionAsked")
                    if let error = error {
                        print("Notification authorization error: \(error.localizedDescription)")
                    } else {
                        print(granted ? "Notification permission granted" : "Notification permission denied")
                    }
                }
            }
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

