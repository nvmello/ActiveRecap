//
//  ActiveRecapApp.swift
//  ActiveRecap
//
//  Created by Nick Morello and Jacob Heathcoat on 12/2/24.
//

import SwiftUI

@main
struct ActiveRecapApp: App {
    @State private var splashScreenFinished = false
    @StateObject private var workoutData = WorkoutData()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !splashScreenFinished {
                    SplashScreen(isFinished: $splashScreenFinished)
                } else {
                    HomeView(workoutData: workoutData).task {
                        await workoutData.requestAuthorization()
                    }
                }
            }
        }
    }
}

