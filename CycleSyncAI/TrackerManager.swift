//
//  TrackerManager.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 17/06/25.
//

import Foundation

let dietComponents = ["Morning Drink", "Breakfast", "Lunch", "Snack", "Dinner"]
let workoutComponents = ["Workout Session 1", "Workout Session 2"]
let hydrationComponent = ["Daily Water Goal"]

class TrackerManager {
    static let shared = TrackerManager()
    private let key = "trackerData"

    private init() {}

    func loadTrackingData() -> [String: [String: Bool]] {
        if let data = UserDefaults.standard.dictionary(forKey: key) as? [String: [String: Bool]] {
            return data
        }
        return [:]
    }

    func saveTrackingData(_ data: [String: [String: Bool]]) {
        UserDefaults.standard.set(data, forKey: key)
    }

    func toggle(component: String, for date: String) {
        var data = loadTrackingData()
        var dayData = data[date] ?? [:]
        dayData[component] = !(dayData[component] ?? false)
        data[date] = dayData
        saveTrackingData(data)
    }

    func isComplete(component: String, for date: String) -> Bool {
        let data = loadTrackingData()
        return data[date]?[component] ?? false
    }

    func isAllComplete(for date: String, planType: String) -> Bool {
        let components: [String]
        if planType == "diet" {
            components = dietComponents + hydrationComponent
        } else {
            components = workoutComponents
        }
        let dayData = loadTrackingData()[date] ?? [:]
        for item in components {
            if dayData[item] != true {
                return false
            }
        }
        return true
    }
    
    func dailyProgress(for date: String, planType: String) -> Float {
        let components: [String] = (planType == "diet") ? (dietComponents + hydrationComponent) : workoutComponents
        let data = loadTrackingData()
        let dayData = data[date] ?? [:]
        let completed = components.filter { dayData[$0] == true }.count
        return components.isEmpty ? 0 : Float(completed) / Float(components.count)
    }
    
    func adherenceSummary(since startDate: String, to endDate: String, planType: String) -> (x: Int, N: Int, P: Float) {
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"

        guard let start = isoFormatter.date(from: startDate),
              let end = isoFormatter.date(from: endDate) else { return (0, 0, 0) }

        var N = 0
        var x = 0
        var totalProgress: Float = 0
        var current = start

        while current <= end {
            let dateStr = isoFormatter.string(from: current)
            let progress = dailyProgress(for: dateStr, planType: planType)
            totalProgress += progress
            if progress > 0 { x += 1 }
            N += 1
            current = Calendar.current.date(byAdding: .day, value: 1, to: current)!
        }

        let P = N > 0 ? totalProgress / Float(N) : 0
        return (x, N, P)
    }
}
