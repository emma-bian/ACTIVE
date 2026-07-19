//
//  ACTIVEApp.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-10-29.
//

import SwiftUI

@main
struct ACTIVEApp: App {

    @StateObject var exerciseData = ExerciseData()
    @StateObject var healthKitManager = HealthKitManager()
    @StateObject var aiService = AIInsulinAdjustmentService(apiKey: "API_KEY")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(exerciseData)
                .environmentObject(aiService)
                .environmentObject(healthKitManager)
                .onAppear {
                    healthKitManager.requestAuthorization()
                }
        }
    }
}
