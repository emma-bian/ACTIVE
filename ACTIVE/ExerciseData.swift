//
//  ExerciseData.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-12-06.
//

import Foundation
import Combine

class ExerciseData: ObservableObject {
    
    @Published var exercises: [Exercise] = []
}
