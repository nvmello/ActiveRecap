//
//  Data.swift
//  ActiveRecap
//
//  Created by Nick Morello on 12/9/24.
//

import Foundation
import HealthKit
import SwiftUI
class WorkoutData: ObservableObject{
    var healthStore: HKHealthStore?;
    private var workouts: [HKWorkout] = [] {
        didSet {    //property observer in that runs code right after a property's value changes
            self.workoutCount = workouts.count
            self.calculateCalories()
            self.calculateWorkoutTime()
        }
    };
    private let calendar = Calendar.current
    private var startDate: Date {
        let firstOfYear = calendar.date(
            from: DateComponents(
                year: calendar.component(.year, from: Date()),
                month: 1,
                day: 1
            )
        )
        return firstOfYear!;
    }
    
    private let endDate: Date = Date();
    
    //An optional predicate that restricts the results that the query returns.
    private var datePredicate: NSPredicate {
        return HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
    }
    
    @Published var workoutCount: Int = 0;
    @Published var totalCaloriesBurned: Int = 0;
    @Published var totalWorkoutTime: Int = 0;
    
    
    init() {
        self.healthStore = HKHealthStore()
    }
    
    public func requestAuthorization() async {
        let types: Set<HKObjectType> = [
            HKObjectType.workoutType()
        ]
        
        do {
            if HKHealthStore.isHealthDataAvailable() {
                try await healthStore?.requestAuthorization(toShare: [], read: types)
                // After authorization, you can fetch the data
                await fetchWorkouts()
                
            }
        } catch {
            print("HealthKit authorization error: \(error.localizedDescription)")
        }
    }
    
    public func fetchWorkouts() async {
        //Check if healthstore and predicate are available
        guard let healthStore = self.healthStore
              else {
                print("Error: Health store not available")
            return
        }
       
        //Query HK data
        let query = HKSampleQuery(
            sampleType: HKObjectType.workoutType(),     //we are looking at workoutTypes
            predicate: self.datePredicate,  //only look in the given timeframe
            limit: HKObjectQueryNoLimit,    // If you want to return all matching samples, use HKObjectQueryNoLimit
            sortDescriptors: nil            //no reason to sort the data
        ){_, samples, error in      // <- HealthKit fills these parameters
            guard let workouts = samples as? [HKWorkout] else { //samples is literally an array of all workouts in the provided predicate time frame
                print("Error fetching workouts: \(error?.localizedDescription ?? "")")
                return
            }
            
            //DispatchQueue.main.async assures the code inside {} is ran on the main thread, necessary to update UI components with @Published
            DispatchQueue.main.async {
                self.workouts = workouts;
            }
        }
        
        healthStore.execute(query)
        
    }
    
    private func calculateCalories() {
        var totalCalories = 0
        
        for workout in workouts {
            if let stats = workout.statistics(
                for: HKQuantityType(.activeEnergyBurned)), let calories = stats.sumQuantity()?.doubleValue(for: .kilocalorie()) {
                totalCalories += Int(round(calories))
            }
            
        }
        
        DispatchQueue.main.async {
            self.totalCaloriesBurned = totalCalories
        }
    }
    
    private func calculateWorkoutTime() {
        var totalTime = 0
        
        for workout in workouts {
            let minutes = workout.duration / 60;
            totalTime += Int(round(minutes))
            
        }
        
        DispatchQueue.main.async {
            self.totalWorkoutTime = totalTime
        }
    }

    
    public func getWorkoutCount() -> Int {
        return workoutCount;
    }
    
    public func getCaloriesBurned() -> Int {
        return self.totalCaloriesBurned;
    }
    
    public func getWorkoutTime() -> Int {
        return self.totalWorkoutTime;
    }
}

