//
//  ExerciseSavedPopup.swift
//  ACTIVE
//
//  Created by Emma Bian on 2025-12-09.
//

import Foundation
import SwiftUI

struct ExerciseSavedPopup: View {
    
    @Binding var isSaved: Bool
    @State var insulinReduction: Int
    @State var takeTime: Date
    
    
    var body: some View {
        if isSaved {
            ZStack {
                Color.pale
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { isSaved = false } }

                
                ZStack(alignment: .top) {
                    
                    Rectangle()
                        .fill(Color.black.opacity(0.25))
                        .blur(radius: 8)
                        .offset(y: -5)
                        .frame(height: 8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Exercise Saved!")
                            .foregroundStyle(Color.text)
                            .bold()
                            .font(.title3)
                            .padding(.vertical)
                        
                        Text("Reduce insulin by \(insulinReduction)% on \(takeTime.formatted(.dateTime.month().day().hour().minute()))")
                        
                        HStack {
                            Spacer()
                            
                            Button("Done") {
                                withAnimation { isSaved = false }
                            }
                            .buttonStyle(.bordered)
                            
                        }
                        .padding(20)
                        
                    }
                    .foregroundStyle(Color.text)
                    .padding(5)
                    .padding(.horizontal)
                    .background(Color.highlight.opacity(0.5))
                    .cornerRadius(30)
                    .ignoresSafeArea(.all)
//                    .shadow(radius: 10)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(), value: isSaved)
                }
                
            }
        }
    }
}
