//
//  PlanNewExercise.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-11-13.
//

import SwiftUI


struct PlanNewExercise: View {
    
    @State private var newExercise: Exercise? = nil
    
    @State private var newName: String = ""
    @State private var newDuration: Int = 0
    @State private var newIntensity: Double = 0
    @State private var newType: String = "Aerobic"
    let newTypes = ["Aerobic", "Strength", "Flexibility", "Balance"]
    @State private var newDate: Date = .now
    
    @EnvironmentObject var exerciseData: ExerciseData
    
    @State private var durString: String = ""
    
    @State private var showSavedPopup = false
    
    var body: some View {
        ZStack {
            Color.pale.ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                
//                Text("ACTIVE")
//                    .foregroundStyle(Color.text)
//                    .font(.custom("Futura", size: 25))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal, 30)
//                    .padding(.top, 10)
//                
//                Text("plan new exercise")
//                    .foregroundStyle(Color.text)
//                    .font(.custom("Futura", size: 15))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal, 30)
//                    .padding(.top, -20)
                
                Text("Plan New Exercise")
                    .font(.custom("Futura", size: 25))
                    .foregroundStyle(Color.pale)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.text.opacity(0.8))
                    )
                    .padding(.top, 15)
                    .padding(.leading, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Form {
                    Section(header: Text("Exercise Name:")) {
                        TextField("Enter exercise name", text: $newName)
                    }
                    
                    Section(header: Text("Duration in Minutes:")) {
                        HStack {
                            
                            TextField("\(newDuration)", text: Binding(
                                get: { String(newDuration) },
                                set: { newValue in
                                    newDuration = Int(newValue) ?? 0
                                }
                            ))
                            .textFieldStyle(.roundedBorder)
                            
                            Spacer()
                            
                            Button("+") {
                                newDuration += 1
                            }
                            .buttonStyle(.bordered)
                            
                            Button("-") {
                                if newDuration >= 1 {
                                    newDuration -= 1
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        
                    }
                    
                    Section(header: Text("Intensity of Exercise:")) {
                        HStack {
                            Slider(value: $newIntensity, in: 0...10, step: 1)
                            Text("\(Int(newIntensity))")
                        }
                    }
                    
                    Section(header: Text("Exercise Type")) {
                        Picker("Type", selection: $newType) {
                            ForEach(newTypes, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    DatePicker(
                        "Date",
                        selection: $newDate,
                        in: Date()..., // no past dates
                    )
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color.text)
                
                Button {
                    
                    var eType: Types
                    if newType=="Aerobic" {
                        eType = Types.aerobic
                    } else if newType=="Strength" {
                        eType = Types.strength
                    } else if newType=="Flexibility" {
                        eType = Types.flexibility
                    } else if newType=="Balance" {
                        eType = Types.balance
                    } else {
                        eType = Types.aerobic
                    }
                    
                    newExercise = Exercise(name: newName,
                                               intensity: Int(newIntensity),
                                               duration: newDuration,
                                               type: eType,
                                               date: newDate)
                    
//                    exerciseData.exercises.append(newExercise)
                    
                    if let newExercise {
                        exerciseData.exercises.append(newExercise)
                    }
                    
                    newName = ""
                    newIntensity = 0
                    newDuration = 0
                    newType = ""
                    newDate = .now
                    
                    showSavedPopup = true
                    
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(Color.text)
                        .font(.title)
                    Text("Add")
                        .foregroundStyle(Color.text)
                        .font(.custom("Futura", size: 20))
                }
                .buttonStyle(.bordered)
                .padding(.bottom, 25)
                
                
                if let newExercise, showSavedPopup {
                    ExerciseSavedPopup(isSaved: $showSavedPopup, insulinReduction: newExercise.insulin, takeTime: newExercise.doseTime)
                }
                
            }
        }
    }
}

#Preview {
    PlanNewExercise()
}
