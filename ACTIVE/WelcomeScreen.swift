//
//  WelcomeScreen.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-11-23.
//

import SwiftUI

struct WelcomeScreen: View {
    
    @Binding var showWelcome: Bool
    
    var body: some View {
        ZStack {
            Color.pale
                .ignoresSafeArea()
            
            
            VStack(spacing: 5) {
                Text("ACTIVE")
                    .font(.custom("Futura", size: 75))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.text)
                    .shadow(radius: 5)
                
                Text("so nothing gets in the way")
                    .font(.custom("Futura", size: 18))
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
                    .offset(y: -5)
                
                HStack(spacing: 20) {
                    Image(systemName: "figure.run")
                    Image(systemName: "figure.outdoor.rowing")
                    Image(systemName: "figure.american.football")
                    Image(systemName: "figure.volleyball")
                    Image(systemName: "figure.basketball")
                    Image(systemName: "figure.roll.runningpace")
                    Image(systemName: "figure.climbing")
                    Image(systemName: "figure.skiing.downhill")
                }
                .font(.headline)
                .foregroundStyle(.text)
                
                
                Button {
                    withAnimation {
                        showWelcome = false
                    }
                } label: {
                    Text("Get Started")
                        .font(.custom("Futura", size: 20))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.text)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 5)
                }
                .offset(y: 35)
            }
            .padding()
            
            
        }
    }
}

#Preview {
    WelcomeScreen(showWelcome: .constant(true))
}
