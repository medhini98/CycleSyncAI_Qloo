//
//  SceneDelegate.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 5/27/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        let rootVC = HomepageViewController()  // or whatever your home screen is
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        
        // Fetch saved filenames from local history
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "notificationDefaultsSet") {
            // Set all toggles ON by default (with defensive trimming)
            ["morningReminderEnabled", "phaseChangeEnabled", "hydrationEnabled", "followUpEnabled"].forEach {
                let trimmedKey = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                defaults.set(true, forKey: trimmedKey)
            }
            defaults.set(true, forKey: "notificationDefaultsSet")
            print("✅ Notification defaults set to ON")
        }

        // Morning reminder
        // ⏰ Schedule morning reminder (if needed)
        let combinedFilenames = PlanHistoryManager.shared.getAllDateLabels()
        NotificationManager.shared.scheduleMorningReminderIfNeeded(filenames: combinedFilenames)

            // 🌀 Schedule phase change reminder (centralized logic)
        NotificationManager.shared.triggerPhaseReminderIfNeeded()
        
        // 💧 Schedule hydration reminders based on current phase (if enabled)
        scheduleHydrationIfNeeded()
        
        NotificationManager.shared.scheduleLogReminderNotification()

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
    
    private func scheduleHydrationIfNeeded() {
        guard UserDefaults.standard.bool(forKey: "hydrationEnabled") else { return }

        HealthManager.shared.fetchCurrentCycleStartDate { startDate in
            guard let start = startDate,
                  let cycleDay = HealthManager.shared.calculateCycleDay(from: start) else {
                print("❌ Could not determine cycle day for hydration scheduling")
                return
            }
            let phase = HealthManager.shared.determinePhase(for: cycleDay, menstrualEndDay: HealthManager.shared.lastMenstrualEndDay)
            NotificationManager.shared.scheduleHydrationNotifications(for: phase)
        }
    }

}

