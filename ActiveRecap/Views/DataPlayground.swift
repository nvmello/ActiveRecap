//
//  DataPlayground.swift
//  ActiveRecap
//
//  Created by Nick Morello on 12/9/24.
//

import SwiftUI

struct DataPlayground: View {
    @ObservedObject var workoutData: WorkoutData
    
    var body: some View {
        
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
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
                    
                    VStack {
                        Text("Best Workout: ")
                            .foregroundColor(.secondary)
                            .fontWeight(.black)
                        Image(systemName: workoutData.getMostIntenseWorkout().icon)
                            .imageScale(.large)
                            .foregroundStyle(.primary)
                        Text("\(workoutData.getMostIntenseWorkout().workoutType)")
                            .fontWeight(.medium)
                        Text("on \(workoutData.getMostIntenseWorkout().startDate.formatted(.dateTime.month().day()))")
                            .fontWeight(.medium)
                        Text("Total Calories Burned: \(workoutData.getMostIntenseWorkout().caloriesBurned)")
                            .fontWeight(.medium)
                        Text("Peak Heart Rate: \(workoutData.getMostIntenseWorkout().peakHeartRate)")
                            .fontWeight(.medium)
                    }
                    .padding()
                    
                }
            }
            
            
        }
        
    }
}

//#Preview {
//    DataPlayground()
//}
