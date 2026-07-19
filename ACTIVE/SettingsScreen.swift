//
//  SettingsScreen.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-12-09.
//

import SwiftUI

struct SettingsScreen: View {
    
    @State private var insulinNotify: Bool = true
    @State private var reminderTime: Int = 0
    @State private var reminderTimeSt: String = "At dose time"
    let reminderTimes = ["At dose time", "5 mins", "10 mins", "30 mins", "1 hr", "2 hr", "3 hr"]
    
    var body: some View {
        ZStack {
            Color.pale.ignoresSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                
//                Text("ACTIVE")
//                    .foregroundStyle(Color.text)
//                    .font(.custom("Futura", size: 25))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal, 30)
//                    .padding(.top, 10)
//                
//                Text("settings")
//                    .foregroundStyle(Color.text)
//                    .font(.custom("Futura", size: 15))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal, 30)
//                    .padding(.top, -20)
                
                

                Text("Settings")
                    .font(.custom("Futura", size: 25))
                    .foregroundStyle(Color.pale)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.text.opacity(0.8))
                    )
                    .padding(.top, 15)
                    .padding(.leading, 15)
                
                    
                Form {
                    Section(header: Text("Notifications"), footer: Text("How long before insulin dose time do you want to receive notification reminders?")) {
                        
                        Toggle("Insulin Reminders", isOn: $insulinNotify)
                        
                        if insulinNotify {
                            Picker("Reminder Time", selection: $reminderTimeSt) {
                                ForEach(reminderTimes, id: \.self) {
                                    Text($0)
                                }
                            }
                        }
                        
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(.text)
                
            }
        }
    }
}

#Preview {
    SettingsScreen()
}
