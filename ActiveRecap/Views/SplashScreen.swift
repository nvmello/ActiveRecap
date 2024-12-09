//
//  SplashScreen.swift
//  ActiveRecap
//
//  Created by Jacob Heathcoat on 12/9/24.
//
// Temporary animation for testing purposes only, will change
// Lottie? Another animation import?

import SwiftUI

struct SplashScreen: View {
    @State private var isAnimating = false
    @Binding var isFinished: Bool
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            HStack(spacing: 0) {
                // can adjust movement height by adjusting -20
                // not important cause place holder
                // but relevant for future
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(y: isAnimating ? -20 : 0)
                
                Rectangle()
                    .fill(Color.white)
                    .offset(y: isAnimating ? -20 : 0)
                    .frame(width: 100, height: 8)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(y: isAnimating ? -20 : 0)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.6).repeatCount(3)) {
                isAnimating = true
            }
            
            // dont forget to end it
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isFinished = true
                }
            }
        }
    }
}
