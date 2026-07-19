//
//  EditExercisePopup.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-12-08.
//

import Foundation
import SwiftUI

struct EditExercisePopup: View {
    @Binding var isShowing: Bool
    @State var nameE: String
    @State var durationE: Int
    @State var durationSt: String = "Duration"
    @State var intensityE: Double
    @State var typeES: String = "Aerobic"
    let typesE = ["Aerobic", "Strength", "Flexibility", "Balance"]
    @State var typeE: Types
    @State var dateE: Date = .now

    var onSave: (String, Int, Double, Types, Date) -> Void

    var body: some View {
        if isShowing {
            ZStack {
                Color.pale
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { isShowing = false } }

                // popup card
                VStack(alignment: .leading, spacing: 4) {
                    Text("Edit Exercise")
                        .foregroundStyle(Color.text)
//                        .font(.custom("Futura", size: 20))
                        .bold()
                        .font(.title3)
                        .padding()
                    
                    HStack {
                        Text("Name")
                        TextField("Name", text: $nameE)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Duration")
                        TextField("\(durationSt)", text: Binding(
                            get: { String(durationE) },
                            set: { newValue in
                                durationE = Int(newValue) ?? 0
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Intensity")
                        Slider(value: $intensityE, in: 0...10, step: 1)
                        Text("\(Int(intensityE))")
                    }
                    
                    HStack {
                        Text("Type")
                        Picker("Type", selection: $typeES) {
                            ForEach(typesE, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    
                    
                    DatePicker(
                        "Date",
                        selection: $dateE,
                        in: Date()..., // no past dates
                    )
                    
                    // ---------------------------------------------------------

                    HStack {
                        Spacer()
                        
                        Button("Cancel") {
                            withAnimation { isShowing = false }
                        }
                        .buttonStyle(.bordered)

                        Button("Save") {
                            if typeES=="Aerobic" {
                                typeE = Types.aerobic
                            } else if typeES=="Strength" {
                                typeE = Types.strength
                            } else if typeES=="Flexibility" {
                                typeE = Types.flexibility
                            } else if typeES=="Balance" {
                                typeE = Types.balance
                            } else {
                                typeE = Types.aerobic
                            }
                            
                            onSave(nameE, durationE, intensityE, typeE, dateE)
                            withAnimation { isShowing = false }
                        }
                        .bold()
                        .buttonStyle(.bordered)
                    }
                    .padding(20)
                }
                .foregroundStyle(Color.text)
                .padding()
                .padding(.horizontal)
                .background(Color.pale)
                .cornerRadius(16)
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(), value: isShowing)
            }
        }
    }
}
