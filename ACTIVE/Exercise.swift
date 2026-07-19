//
//  Exercise.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-12-04.
//

import Foundation
import Combine

class Exercise: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String
    @Published var intensity: Int
    @Published var duration: Int
    @Published var type: Types
    @Published var date: Date
    @Published var insulin: Int
    @Published var doseTime: Date
    
    @Published var aiAdjusted = false
    @Published var wasEdited = false
    
    init(id: UUID = UUID(), name: String, intensity: Int, duration: Int, type: Types, date: Date) {
        self.id = id
        self.name = name
        self.intensity = intensity
        self.duration = duration
        self.type = type
        self.date = date
        self.insulin = 0
        self.doseTime = date
        
        self.insulin = calculateInsulin()
        self.doseTime = calculateDoseTime()
        
        
    }
        
    func calculateInsulin() -> Int {
        // returns percentage change of insulin dose
        // does not return actual dosage
        
        var reduction = 0     // % reduction of insulin
        
        switch type {
        case .aerobic:
            // aerobic = strongest BG-lowering effect
            if duration < 30 {
                reduction = 20
            } else if duration < 60 {
                reduction = 30
            } else {
                reduction = 40
            }
            
            // higher intensity = larger insulin reduction
            if intensity >= 7 {
                reduction += 10
            }
            
        case .strength:
            // strength often raises BG slightly at first, then lowers it slightly
            // lower insulin reduction
            if duration < 30 {
                reduction = 0
            } else if duration < 60 {
                reduction = 10
            } else {
                reduction = 15
            }
            
        case .flexibility, .balance:
            // minimal BG effect = usually no adjustment
            reduction = 0
        }
        
        // safe interval
        reduction = min(max(reduction, 0), 75)
        
        self.insulin = reduction
        
        return reduction
    }

    func calculateDoseTime() -> Date {
        // for suggested timing of insulin dose before exercise
        // aerobic exercise often needs insulin taken earlier or reduced (highest BG-lowering)
        // strength/flexibility/balance may not need changes
        
        var minutesBefore = 0
        
        switch type {
        case .aerobic:
            if duration >= 30 {
                minutesBefore = 45     // reduce insulin earlier
            } else {
                minutesBefore = 30
            }
            
        case .strength:
            minutesBefore = 10         // usually minimal adjustment
            
        case .flexibility, .balance:
            minutesBefore = 0          // typically none
        }
        
        let suggested = Calendar.current.date(byAdding: .minute,
                                              value: -minutesBefore,
                                              to: date) ?? date
        
        self.doseTime = suggested
        return suggested
    }
    
}

enum Types {
    case aerobic
    case strength
    case flexibility
    case balance
    
    var name: String {
        switch self {
        case .aerobic: return "Aerobic"
        case .strength: return "Strength"
        case .flexibility: return "Flexibility"
        case .balance: return "Balance"
        }
    }

}
