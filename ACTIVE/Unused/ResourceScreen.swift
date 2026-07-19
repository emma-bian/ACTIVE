//
//  ResourceScreen.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-11-23.
//

import SwiftUI
import AVKit

struct ResourceScreen: View {
    
    let vid1 = AVPlayer(
            url: Bundle.main.url(forResource: "vid1TCOYD", withExtension: "mp4")!
        )
    let vid2 = AVPlayer(
            url: Bundle.main.url(forResource: "vid2diabetesforbundet", withExtension: "mp4")!
        )
    
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
//                Text("resources")
//                    .foregroundStyle(Color.text)
//                    .font(.custom("Futura", size: 15))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal, 30)
//                    .padding(.top, -20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        Text("Video Resources")
                            .font(.custom("Futura", size: 25))
                            .foregroundStyle(Color.pale)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.text.opacity(0.8))
                            )
                        
                        VideoPlayer(player: vid1)
                            .frame(height: 300)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                        Text("Exercise and Diabetes: Learn Options for Cardio, Strength, & Stretching That Help T2D | TCOYD (Taking Control Of Your Diabetes)")
                            .font(.footnote)
                            .offset(y: -10)
                        
                        VideoPlayer(player: vid2)
                            .frame(height: 300)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                        Text("What happens to your blood sugar when you work out? (Diabetesforbundet)")
                            .font(.footnote)
                            .offset(y: -10)
                    }
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(Color.text)
                    .padding()
                }
                
                
            }
        }
    }
}

#Preview {
    ResourceScreen()
}
