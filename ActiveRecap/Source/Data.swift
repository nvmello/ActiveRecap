//
//  Data.swift
//  ActiveRecap
//
//  Created by Nick Morello on 12/9/24.
//

import Foundation
import HealthKit
import SwiftUI

/// A class that manages workout data from HealthKit, providing access to workout statistics
/// including total workouts, calories burned, and workout duration.
///
/// This class serves as the data model for tracking fitness activities, handling HealthKit authorization,
/// and processing workout data for display in the UI.
class WorkoutData: ObservableObject {
    /// The HealthKit store instance used to access health and fitness data
    var healthStore: HKHealthStore?
    
    /// Array of workout samples retrieved from HealthKit
    /// Updates to this property trigger recalculation of workout statistics
    private var workouts: [HKWorkout] = [] {
        didSet {    //property observer in that runs code right after a property's value changes
            self.workoutCount = workouts.count
            self.calculateCalories()
            self.calculateWorkoutTime()
        }
    }
    
    /// Calendar instance used for date calculations
    private let calendar = Calendar.current
    
    /// The start date for workout queries, set to January 1st of the current year
    private var startDate: Date {
        let firstOfYear = calendar.date(
            from: DateComponents(
                year: calendar.component(.year, from: Date()),
                month: 1,
                day: 1
            )
        )
        return firstOfYear!
    }
    
    /// The end date for workout queries, set to the current date
    private let endDate: Date = Date()
    
    /// Predicate used to filter workout samples within the specified date range
    private var datePredicate: NSPredicate {
        return HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
    }
    
    /// Published properties that update the UI when changed
    @Published var workoutCount: Int = 0
    @Published var totalCaloriesBurned: Int = 0
    @Published var totalWorkoutTime: Int = 0
    
    /// Initializes the WorkoutData instance and sets up the HealthKit store
    init() {
        self.healthStore = HKHealthStore()
    }
    
    /// Requests authorization to access HealthKit workout data
    ///
    /// This method must be called before attempting to access any HealthKit data.
    /// It requests read-only access to workout data.
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
    
    /// Fetches workout data from HealthKit within the specified date range
    ///
    /// This method queries HealthKit for all workout samples between startDate and endDate,
    /// then updates the published properties with the new data.
    public func fetchWorkouts() async {
        //Check if healthstore and predicate are available
        guard let healthStore = self.healthStore else {
            print("Error: Health store not available")
            return
        }
        
        //Query HK data
        let query = HKSampleQuery(
            sampleType: HKObjectType.workoutType(),     //we are looking at workoutTypes
            predicate: self.datePredicate,  //only look in the given timeframe
            limit: HKObjectQueryNoLimit,    // If you want to return all matching samples, use HKObjectQueryNoLimit
            sortDescriptors: nil            //no reason to sort the data
        ) { _, samples, error in      // <- HealthKit fills these parameters
            guard let workouts = samples as? [HKWorkout] else { //samples is literally an array of all workouts in the provided predicate time frame
                print("Error fetching workouts: \(error?.localizedDescription ?? "")")
                return
            }
            
            //DispatchQueue.main.async assures the code inside {} is ran on the main thread, necessary to update UI components with @Published
            DispatchQueue.main.async {
                self.workouts = workouts
            }
        }
        
        healthStore.execute(query) //tells HealthKit to start retrieving the workout samples based on the query parameters you specified
    }
    
    /// Calculates the total calories burned across all workouts
    ///
    /// This method processes each workout's active energy burned statistics
    /// and updates the totalCaloriesBurned property.
    private func calculateCalories() {
        var totalCalories = 0
        
        for workout in workouts {
            if let stats = workout.statistics(
                for: HKQuantityType(.activeEnergyBurned)),
               let calories = stats.sumQuantity()?.doubleValue(for: .kilocalorie()) {
                totalCalories += Int(round(calories))
            }
        }
        
        DispatchQueue.main.async {
            self.totalCaloriesBurned = totalCalories
        }
    }
    
    /// Calculates the total workout time in minutes
    ///
    /// This method sums the duration of all workouts and updates
    /// the totalWorkoutTime property.
    private func calculateWorkoutTime() {
        var totalTime = 0
        
        for workout in workouts {
            let minutes = workout.duration / 60
            totalTime += Int(round(minutes))
        }
        
        DispatchQueue.main.async {
            self.totalWorkoutTime = totalTime
        }
    }
    
    /// Returns the total number of workouts
    public func getWorkoutCount() -> Int {
        return workoutCount
    }
    
    /// Returns the total calories burned across all workouts
    public func getCaloriesBurned() -> Int {
        return self.totalCaloriesBurned
    }
    
    /// Returns the total workout time in minutes
    public func getWorkoutTime() -> Int {
        return self.totalWorkoutTime
    }
}
