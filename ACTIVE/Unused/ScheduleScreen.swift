//
//  ScheduleScreen.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-11-23.
//

import SwiftUI

struct ScheduleScreen: View {
    
    @EnvironmentObject var exerciseData: ExerciseData
    
    @State private var showPopup = false
    @State private var toEdit: Exercise? = nil
    
    
    var body: some View {
        ZStack {
            Color.pale.ignoresSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                                
                Text("Schedule")
                    .font(.custom("Futura", size: 25))
                    .foregroundStyle(Color.pale)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.text.opacity(0.8))
                    )
                    .padding(.top, 15)
                    .padding(.leading, 15)
                
                let sortedExercises = exerciseData.exercises.sorted { $0.date < $1.date }
                let groupedByDay = Dictionary(grouping: sortedExercises) { exercise in
                            Calendar.current.startOfDay(for: exercise.date)
                        }

                let orderedDays = groupedByDay.keys.sorted()
                
                
                ScrollView {
                    
                    
                    LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                        
                        ForEach(orderedDays, id: \.self) { day in
                            
                            Section {
                                
                                VStack(spacing: 0) {
                                    
                                    ForEach(groupedByDay[day] ?? []) { e in
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            
                                            HStack {
                                                Text(e.name)
                                                    .bold()
                                                    .font(.headline)
                                                
                                                Text(e.date.formatted(.dateTime.hour().minute()))
                                                    .padding(.horizontal)
                                                
                                                switch e.type.name {
                                                    case "Aerobic": Image(systemName: "figure.run")
                                                    case "Strength": Image(systemName: "figure.strengthtraining.traditional")
                                                    case "Balance": Image(systemName: "figure.yoga")
                                                    case "Flexibility": Image(systemName: "figure.flexibility")
                                                default:
                                                    Image(systemName: "figure.run")
                                                }
                                                
                                                Spacer()
                                                
                                                Menu {
                                                    Button("Edit") {
                                                        toEdit = e
                                                        showPopup = true
                                                    }
                                                    Button("Delete") {
                                                        delete(e: e)
                                                    }
                                                } label: {
                                                    Image(systemName: "ellipsis.circle")
                                                        .font(.title)
                                                }
                                            }
                                            
                                            HStack {
                                                Text("Intensity: \(e.intensity)")
                                                Spacer()
                                                Text("|")
                                                Spacer()
                                                Text("Duration: \(e.duration) mins")
                                                Spacer()
                                                Text("|")
                                                Spacer()
                                                Text("Type: \(e.type.name)")
                                            }
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                            .padding(.vertical, 5)
                                            
                                            Text("Reduce insulin by \(e.insulin)% on \(e.doseTime.formatted(.dateTime.month().day().hour().minute()))")
                                            
                                            Divider()
                                                .offset(y: 18)
                                        }
                                        .foregroundStyle(Color.text)
                                        .padding()
                                    }
                                    
                                }
                                .padding(.horizontal)
                                
                            } header: {
                                
                                ZStack {
                                    Color(.systemBackground)
                                    Text(day.formatted(.dateTime.month().day()))
                                        .font(.title2)
                                        .bold()
                                        .padding(.vertical, 6)
                                        .padding(.horizontal)
                                        .foregroundStyle(Color.text)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .zIndex(1)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                                    
                Spacer()
                
                
                if let e = toEdit, showPopup {
                    EditExercisePopup(
                        isShowing: $showPopup,
                        nameE: e.name,
                        durationE: e.duration,
                        intensityE: Double(e.intensity),
                        typeE: e.type,
                        dateE: e.date
                    ) { newName, newDuration, newIntensity, newType, newDate in
                        updateExercise(id: e.id, name: newName, duration: newDuration, intensity: newIntensity, type: newType, date: newDate)
                    }
                }
                
            }
        }
    }
    
    
    func updateExercise(id: UUID, name: String, duration: Int, intensity: Double, type: Types, date: Date) {
            if let i = exerciseData.exercises.firstIndex(where: { $0.id == id }) {
                exerciseData.exercises[i].name = name
                exerciseData.exercises[i].duration = duration
                exerciseData.exercises[i].intensity = Int(intensity)
                exerciseData.exercises[i].type = type
                exerciseData.exercises[i].date = date
                exerciseData.exercises[i].insulin = exerciseData.exercises[i].calculateInsulin()
                exerciseData.exercises[i].doseTime = exerciseData.exercises[i].calculateDoseTime()
            }
        }
    
    func delete(e: Exercise) {
        if let index = exerciseData.exercises.firstIndex(where: { $0.id == e.id }) {
            exerciseData.exercises.remove(at: index)
        }
    }
}

#Preview {
    ScheduleScreen()
}
