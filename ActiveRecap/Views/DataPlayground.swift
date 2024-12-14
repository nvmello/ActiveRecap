//
//  DataPlayground.swift
//  ActiveRecap
//
//  Created by Nick Morello on 12/9/24.
//

import SwiftUI

struct DataPlayground: View {
    @StateObject var workoutData = WorkoutData()
    
    var body: some View {
        VStack {
            Image(systemName: "dumbbell")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Active Recap")
        }
        .padding()
        
        VStack {
            HStack {
                Text("# Workouts: ")
                    .foregroundColor(.secondary)
                
                Text("\(workoutData.getWorkoutCount())")
                    .fontWeight(.medium)
            }
            HStack {
                Text("Time Exercising: ")
                    .foregroundColor(.secondary)
                
                Text("\(workoutData.getWorkoutTime()) Minutes")
                    .fontWeight(.medium)
            }
            HStack {
                Text("Calories Burned: ")
                    .foregroundColor(.secondary)
                
                Text("\(workoutData.getCaloriesBurned())")
                    .fontWeight(.medium)
            }
        }
        .padding()
        .onAppear {
            Task {
                await workoutData.requestAuthorization()
            }
        }
    }
}

#Preview {
    DataPlayground()
}
