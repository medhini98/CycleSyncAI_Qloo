import Foundation
import HealthKit

class HealthManager {
    static let shared = HealthManager()
    let healthStore = HKHealthStore()

    private init() {}
    
    public var lastMenstrualEndDay: Int? = nil

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        if HKHealthStore.isHealthDataAvailable() {
            guard let menstrualType = HKObjectType.categoryType(forIdentifier: .menstrualFlow) else {
                completion(false, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Menstrual flow type unavailable"]))
                return
            }
            let readData: Set = [menstrualType]
            healthStore.requestAuthorization(toShare: [], read: readData, completion: completion)
        } else {
            completion(false, NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Health data unavailable"]))
        }
    }

    func fetchCurrentCycleStartDate(completion: @escaping (Date?) -> Void) {
        guard let menstrualType = HKObjectType.categoryType(forIdentifier: .menstrualFlow) else {
            print("Could not get menstrualFlow type")
            completion(nil)
            return
        }

        let startDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)

        let query = HKSampleQuery(sampleType: menstrualType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, results, error in
            guard let samples = results as? [HKCategorySample] else {
                print("No samples found or wrong type")
                completion(nil)
                return
            }

            let menstrualSamples = samples.filter {
                $0.value == HKCategoryValueMenstrualFlow.unspecified.rawValue ||
                $0.value == HKCategoryValueMenstrualFlow.light.rawValue ||
                $0.value == HKCategoryValueMenstrualFlow.medium.rawValue ||
                $0.value == HKCategoryValueMenstrualFlow.heavy.rawValue
            }.sorted(by: { $0.startDate > $1.startDate })

            guard let latest = menstrualSamples.first else {
                print("No valid menstrual samples")
                completion(nil)
                return
            }

            var currentStart = latest.startDate

            for sample in menstrualSamples {
                if Calendar.current.isDate(sample.startDate, inSameDayAs: currentStart) ||
                    Calendar.current.isDate(sample.startDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: currentStart)!) {
                    currentStart = sample.startDate < currentStart ? sample.startDate : currentStart
                } else {
                    break  // stop if the day is not consecutive
                }
            }

            print("🚨 DEBUG — Final calculated cycle start date: \(currentStart)")
            completion(currentStart)
        }

        healthStore.execute(query)
    }

    func calculateCycleDay(from startDate: Date) -> Int? {
        let startOfStartDate = Calendar.current.startOfDay(for: startDate)
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let days = Calendar.current.dateComponents([.day], from: startOfStartDate, to: startOfToday).day
        guard let days = days else { return nil }
        return days + 1  // cycle days start from 1
    }
    
    func calculateCycleDay(from cycleStartDate: Date, to targetDate: Date) -> Int? {
        let startOfStartDate = Calendar.current.startOfDay(for: cycleStartDate)
        let startOfTargetDate = Calendar.current.startOfDay(for: targetDate)
        let days = Calendar.current.dateComponents([.day], from: startOfStartDate, to: startOfTargetDate).day
        guard let days = days else { return nil }
        return days + 1  // cycle days start from 1
    }

    func determinePhase(for cycleDay: Int, menstrualEndDay: Int?) -> String {
        if cycleDay > 35 {
            return "LongCycle"  // flag: cycle is unusually long
        }
        
        if let menstrualEnd = menstrualEndDay {
            if cycleDay <= menstrualEnd {
                return "Menstrual"
            } else if cycleDay <= 13 {
                return "Follicular"
            } else if cycleDay <= 16 {
                return "Ovulation"
            } else if cycleDay <= 35 {
                return "Luteal"
            } else {
                return "Unknown"
            }
        } else {
            if cycleDay <= 7 {
                return "Menstrual"
            } else if cycleDay <= 13 {
                return "Follicular"
            } else if cycleDay <= 16 {
                return "Ovulation"
            } else if cycleDay <= 35 {
                return "Luteal"
            } else {
                return "Unknown"
            }
        }
    }
}
