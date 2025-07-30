//
//  NotificationManager.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 16/06/25.
//

import Foundation
import UserNotifications

class NotificationManager {

    static let shared = NotificationManager() // Singleton pattern
    private init() {} // prevent external initialization

    // Call this once at app launch or when toggles are updated
    func scheduleMorningReminderIfNeeded(dates: [String]) {
        let isOn = UserDefaults.standard.bool(forKey: "morningReminderEnabled")
        guard isOn else {
            print("🚫 Morning Reminder is OFF")
            return
        }

        if isTodayCoveredByPlans(dates: dates) {
            print("✅ [MorningReminder] Plan already exists for today — no notification needed.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to Sync with Your Cycle ✨"
        content.body = "Start your day strong — generate your plan for today!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 5
        dateComponents.minute = 45
        
        // For Testing Only
        //let now = Calendar.current.dateComponents([.hour, .minute], from: Date().addingTimeInterval(120)) // 2 min from now
        //dateComponents.hour = now.hour
        //dateComponents.minute = now.minute
        
        
         let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        // For Testing Only
        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "morningReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling morning reminder: \(error)")
            } else {
                print("✅ Morning reminder scheduled for 5:45 AM")
            }
        }
    }
    
    func isTodayCoveredByPlans(dates: [String]) -> Bool {
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
        let todayStr = isoFormatter.string(from: Date())
        return dates.contains { $0.trimmingCharacters(in: .whitespaces) == todayStr }
    }
    
    func cancelMorningReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["morningReminder"])
        print("🔕 Morning reminder notification cancelled")
    }


    func schedulePhaseChangeNotificationIfNeeded(currentPhase: String) {
        let defaults = UserDefaults.standard

        // Check if toggle is ON
        let isOn = defaults.bool(forKey: "phaseChangeEnabled")
        guard isOn else {
            print("🚫 Phase Change Reminder is OFF")
            return
        }

        // Prevent repeat notification for same phase
        if let lastPhase = defaults.string(forKey: "lastNotifiedPhase"), lastPhase == currentPhase {
            print("⏩ Phase '\(currentPhase)' already notified")
            return
        }

        // Save current phase as last notified
        defaults.set(currentPhase, forKey: "lastNotifiedPhase")

        // Schedule notification
        let content = UNMutableNotificationContent()
        content.title = "🌀 New Phase: \(currentPhase)"
        content.body = "Your body has entered the \(currentPhase) phase. Tap to learn how to adapt your lifestyle!"
        content.sound = .default

        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // 5 seconds for testing
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60 * 2, repeats: false) // fires in 2 hours
        
        let request = UNNotificationRequest(identifier: "phaseChangeReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling phase change notification: \(error)")
            } else {
                print("✅ Phase change notification scheduled for phase: \(currentPhase)")
            }
        }
    }
    
    func cancelPhaseChangeReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["phaseChangeReminder"])
        print("🔕 Phase change notification cancelled")
    }
    
    func triggerPhaseReminderIfNeeded() {
        guard UserDefaults.standard.bool(forKey: "phaseChangeEnabled") else {
            print("🚫 Phase Change Reminder is OFF")
            return
        }

        HealthManager.shared.fetchCurrentCycleStartDate { startDate in
            guard let start = startDate,
                  let cycleDay = HealthManager.shared.calculateCycleDay(from: start) else {
                print("❌ Could not determine cycle day for phase check")
                return
            }
            let phase = HealthManager.shared.determinePhase(for: cycleDay, menstrualEndDay: HealthManager.shared.lastMenstrualEndDay)
            print("🔁 Current phase: \(phase)")

            NotificationManager.shared.schedulePhaseChangeNotificationIfNeeded(currentPhase: phase)

            // 💧 Schedule hydration reminders based on this phase
            NotificationManager.shared.scheduleHydrationNotifications(for: phase)
        }
    }
    
    func scheduleHydrationNotifications(for phase: String) {
        let isOn = UserDefaults.standard.bool(forKey: "hydrationEnabled")
        guard isOn else {
            print("🚫 Hydration Reminder is OFF")
            return
        }

        // Cancel existing hydration reminders
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["hydration1", "hydration2", "hydration3", "hydration4", "hydration5", "hydration6"])

        // Determine interval
        let interval: TimeInterval
        switch phase.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "follicular":
            interval = 4 * 60 * 60
        case "luteal":
            interval = 3 * 60 * 60
        case "menstrual", "ovulatory":
            interval = 3 * 60 * 60
        default:
            interval = 3 * 60 * 60
        }

        // Schedule reminders throughout the day starting from 9am
        let startHour = 9
        for i in 0..<6 {
            let hour = startHour + i * Int(interval / 3600)
            guard hour < 24 else {
                print("⚠️ Skipping hydration reminder at hour \(hour) — exceeds valid time range.")
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = "💧 Hydration Check-In"
            content.body = "Time to sip some water and stay refreshed!"
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = hour

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "hydration\(i+1)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }

        print("✅ Hydration reminders scheduled for \(phase) phase")
    }
    
    func cancelHydrationReminders() {
        for i in 1...6 {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["hydration\(i)"])
        }
        print("🔕 Hydration reminders cancelled")
    }

}
