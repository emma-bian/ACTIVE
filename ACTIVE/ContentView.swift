//
//  ContentView.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-10-29.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var exerciseData: ExerciseData
    @State private var showWelcome = true

    var body: some View {
        ZStack {
            
            if showWelcome {
                WelcomeScreen(showWelcome: $showWelcome)
                    .transition(.opacity.combined(with: .scale))
            } else {
                TabView {
                    HomeScreen()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    ChartScreen()
                        .tabItem {
                            Label("Charts", systemImage: "chart.xyaxis.line")
                        }
//                    PlanNewExercise()
//                        .tabItem {
//                            Label("Plan", systemImage: "figure.run")
//                        }
//                    ScheduleScreen()
//                        .tabItem {
//                            Label("Schedule", systemImage: "calendar")
//                        }
//                    ResourceScreen()
//                        .tabItem {
//                            Label("Resources", systemImage: "questionmark.circle")
//                        }
                    SettingsScreen()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .transition(.opacity)
                .environmentObject(exerciseData)
            }
            
        }
        .animation(.easeInOut, value: showWelcome)
    }
}

#Preview {
    ContentView()
}

// next steps: add home screen, schedule view (make it like google calendar), logo, enable notifications, compatable with widgets
