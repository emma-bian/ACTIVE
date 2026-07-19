//
//  HealthKitManager.swift
//  ACTIVE
//
//  Created by Emma Bian on 2026-07-09.
//

import Foundation
import Combine
import HealthKit

struct VitalReading: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double // mg/dL
}

class HealthKitManager: ObservableObject {

    var healthStore: HKHealthStore?

    @Published var glucoseReadings: [VitalReading] = []
    @Published var heartRateReadings: [VitalReading] = []
    @Published var oxygenSaturationReadings: [VitalReading] = []
    @Published var isAuthorized = false

    init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        healthStore = HKHealthStore()
    }


    func requestAuthorization() {
        
        let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let oxygenSatType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        
        healthStore?.requestAuthorization(toShare: [glucoseType, heartRateType, oxygenSatType], read: [glucoseType, heartRateType, oxygenSatType]) { (success, error) in
            if success {
                self.seedTestData() //TESTING ONLY
                self.fetchVitals()
//                self.startObservingAllVitals()
            } else {
                print("Authorization failed.")
                return
            }
        }
    }
    
    func fetchVitals(hoursBack: Int = 24) {
        fetch(identifier: .bloodGlucose, unit: HKUnit(from: "mg/dL"), hoursBack: hoursBack)
        
        let bpmUnit = HKUnit.count().unitDivided(by: .minute())
        fetch(identifier: .heartRate, unit: bpmUnit, hoursBack: hoursBack)
        
        fetch(identifier: .oxygenSaturation, unit: .percent(), hoursBack: hoursBack)
    }
        
    private func fetch(identifier: HKQuantityTypeIdentifier, unit: HKUnit, hoursBack: Int) {
        let quantityTypeIdentifier = HKSampleType.quantityType(forIdentifier: identifier)!
        let hourlyAnchor = Calendar.current.startOfDay(for: Date())
        let oneDayAgo = Calendar.current.date(byAdding: .hour, value: -hoursBack, to: Date())!
        let halfHourly = DateComponents(minute: 30)
        let startDate = HKQuery.predicateForSamples(withStart: oneDayAgo, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityTypeIdentifier,
            quantitySamplePredicate: startDate,
            options: .discreteAverage,
            anchorDate: hourlyAnchor,
            intervalComponents: halfHourly)
        
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else {
                print("Query error.")
                return
            }
            self.updateStatistics(statsCollection: statsCollection, quantityType: identifier, unit: unit)
        }
        
        healthStore?.execute(query)
    }
    
    func updateStatistics(statsCollection: HKStatisticsCollection, quantityType: HKQuantityTypeIdentifier, unit: HKUnit) {
        DispatchQueue.main.async {
            var readings: [VitalReading] = []
            
            let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            
            statsCollection.enumerateStatistics(from: startDate!, to: Date()) { stats, _ in
                guard let average = stats.averageQuantity() else { return }
                let value = average.doubleValue(for: unit)
                readings.append(VitalReading(date: stats.startDate, value: value))
            }

            switch quantityType {
            case .bloodGlucose:
                self.glucoseReadings = readings
            case .heartRate:
                self.heartRateReadings = readings
            case .oxygenSaturation:
                // HealthKit stores this as a 0.0-1.0 fraction — convert to a percent for display.
                self.oxygenSaturationReadings = readings.map { VitalReading(date: $0.date, value: $0.value * 100) }
            default:
                break
            }
        }
    }

    

//    private func observeQuantityType(_ identifier: HKQuantityTypeIdentifier, onUpdate: @escaping () -> Void) {
//        guard let healthStore else { return }
//        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else { return }
//
//        let query = HKObserverQuery(sampleType: quantityType, predicate: nil) { _, completionHandler, _ in
//            onUpdate()
//            completionHandler()
//        }
//
//        healthStore.execute(query)
//        healthStore.enableBackgroundDelivery(for: quantityType, frequency: .immediate) { _, _ in }
//    }
//
//    func startObservingAllVitals() {
//        observeQuantityType(.bloodGlucose) { [weak self] in self?.fetchGlucose() }
//        observeQuantityType(.heartRate) { [weak self] in self?.fetchHeartRate() }
//        observeQuantityType(.oxygenSaturation) { [weak self] in self?.fetchOxygenSaturation() }
//    }


    var latestGlucose: VitalReading? { glucoseReadings.last }
    var latestHeartRate: VitalReading? { heartRateReadings.last }
    var latestOxygenSaturation: VitalReading? { oxygenSaturationReadings.last }

    var glucoseTrend: GlucoseTrend {
        Self.trend(for: glucoseReadings, fallFastThreshold: -2, fallThreshold: -0.5, riseThreshold: 0.5, riseFastThreshold: 2)
    }

    private static func trend(
        for readings: [VitalReading],
        fallFastThreshold: Double,
        fallThreshold: Double,
        riseThreshold: Double,
        riseFastThreshold: Double
    ) -> GlucoseTrend {
        guard readings.count >= 2 else { return .stable }
        let recent = readings.suffix(3)
        guard let first = recent.first, let last = recent.last else { return .stable }

        let minutesElapsed = last.date.timeIntervalSince(first.date) / 60
        guard minutesElapsed > 0 else { return .stable }

        let ratePerMin = (last.value - first.value) / minutesElapsed

        if ratePerMin <= fallFastThreshold { return .fallingFast }
        if ratePerMin <= fallThreshold { return .falling }
        if ratePerMin >= riseFastThreshold { return .risingFast }
        if ratePerMin >= riseThreshold { return .rising }
        return .stable
    }
    

    func seedTestData(completion: (() -> Void)? = nil) {
        guard let healthStore else {
            completion?()
            return
        }
        guard
            let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose),
            let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate),
            let oxygenSatType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)
        else {
            completion?()
            return
        }
        
        let now = Date()
        var samples: [HKQuantitySample] = []

        // Glucose: mg/dL, one reading every 30 min for the last 24 hours
        let glucoseUnit = HKUnit(from: "mg/dL")
        let glucoseIntervalMinutes = 30
        let glucoseReadingCount = (24 * 60) / glucoseIntervalMinutes

        for i in 0..<glucoseReadingCount {
            let minutesAgo = glucoseIntervalMinutes * (glucoseReadingCount - i)
            let date = Calendar.current.date(byAdding: .minute, value: -minutesAgo, to: now)!

            let base = 130.0
            let wave = sin(Double(i) / 6.0) * 20
            let noise = Double.random(in: -5...5)
            let value = base + wave + noise

            let quantity = HKQuantity(unit: glucoseUnit, doubleValue: value)
            samples.append(HKQuantitySample(type: glucoseType, quantity: quantity, start: date, end: date))
        }

        // Heart rate: bpm, one reading every 30 min for the last 24 hours
        let bpmUnit = HKUnit.count().unitDivided(by: .minute())
        let heartRateIntervalMinutes = 30
        let heartRateReadingCount = (24 * 60) / heartRateIntervalMinutes

        for i in 0..<heartRateReadingCount {
            let minutesAgo = heartRateIntervalMinutes * (heartRateReadingCount - i)
            let date = Calendar.current.date(byAdding: .minute, value: -minutesAgo, to: now)!

            let base = 75.0
            let wave = sin(Double(i) / 8.0) * 15
            let noise = Double.random(in: -4...4)
            let value = max(50, base + wave + noise)

            let quantity = HKQuantity(unit: bpmUnit, doubleValue: value)
            samples.append(HKQuantitySample(type: heartRateType, quantity: quantity, start: date, end: date))
        }

        // One reading every 30 min for the last 24 hours.
        let oxygenIntervalMinutes = 30
        let oxygenReadingCount = (24 * 60) / oxygenIntervalMinutes

        for i in 0..<oxygenReadingCount {
            let minutesAgo = oxygenIntervalMinutes * (oxygenReadingCount - i)
            let date = Calendar.current.date(byAdding: .minute, value: -minutesAgo, to: now)!

            let base = 0.97
            let noise = Double.random(in: -0.01...0.01)
            let value = min(1.0, base + noise)

            let quantity = HKQuantity(unit: .percent(), doubleValue: value)
            samples.append(HKQuantitySample(type: oxygenSatType, quantity: quantity, start: date, end: date))
        }
        
        healthStore.save(samples) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    print("Test data saved to HealthKit.")
                    self?.fetchVitals()
                } else {
                    print("Failed to save test data: \(error?.localizedDescription ?? "unknown error")")
                }
                completion?()
            }
        }
    }

}


enum GlucoseTrend: String {
    case fallingFast
    case falling
    case stable
    case rising
    case risingFast
}
