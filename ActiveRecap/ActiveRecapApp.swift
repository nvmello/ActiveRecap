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
    @StateObject private var currentYearWorkoutData = WorkoutData(
        year: Calendar.current.component(.year, from: Date()) - 2
    )
    @StateObject private var prevYearWorkoutData = WorkoutData(
        year: Calendar.current.component(.year, from: Date()) - 1
    )
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !splashScreenFinished {
                    SplashScreen(isFinished: $splashScreenFinished)
                } else {
                    HomeView(workoutData: currentYearWorkoutData).task {
                        await currentYearWorkoutData.requestAuthorization()
                    }
                }
            }
        }
    }
}

