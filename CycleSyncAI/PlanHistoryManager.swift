//
//  PlanHistoryManager.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 14/06/25.
//

import Foundation

class PlanHistoryManager {
    static let shared = PlanHistoryManager()
    private let key = "savedPlans"
    private let datesKey = "cachedPlanDates"

    private var cachedDates: Set<String>

    private init() {
        if let arr = UserDefaults.standard.array(forKey: datesKey) as? [String] {
            cachedDates = Set(arr)
        } else {
            cachedDates = []
        }
    }

    func savePlan(_ plan: PlanModel) {
        var existing = loadPlans()
        existing.insert(plan, at: 0) // newest first
        if let data = try? JSONEncoder().encode(existing) {
            UserDefaults.standard.set(data, forKey: key)
            
            let isoFormatter = DateFormatter()
                isoFormatter.dateFormat = "yyyy-MM-dd"
                let todayStr = isoFormatter.string(from: Date())
                if UserDefaults.standard.string(forKey: "firstPlanDate") == nil {
                    UserDefaults.standard.set(todayStr, forKey: "firstPlanDate")
                }
            cachedDates.formUnion(plan.dates)
            UserDefaults.standard.set(Array(cachedDates), forKey: datesKey)
        }
    }

    func loadPlans() -> [PlanModel] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([PlanModel].self, from: data) else {
            return []
        }
        // refresh cache if needed
        let allDates = decoded.flatMap { $0.dates }
        if !allDates.isEmpty {
            cachedDates = Set(allDates)
            UserDefaults.standard.set(Array(cachedDates), forKey: datesKey)
        }
        return decoded
    }

    func clearPlans() {
        UserDefaults.standard.removeObject(forKey: key)
        cachedDates.removeAll()
        UserDefaults.standard.removeObject(forKey: datesKey)
    }
    
    func getAllDateLabels() -> [String] {
        return loadPlans().map { $0.dateLabel }
    }

    func getAllPlanDates() -> [String] {
        if cachedDates.isEmpty {
            let dates = loadPlans().flatMap { $0.dates }
            cachedDates = Set(dates)
            UserDefaults.standard.set(Array(cachedDates), forKey: datesKey)
        }
        return Array(cachedDates)
    }
}
