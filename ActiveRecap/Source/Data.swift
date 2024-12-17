import Foundation
import HealthKit
import SwiftUI

/// A class that manages and processes workout data from HealthKit, providing comprehensive fitness activity tracking
/// and analytics.
///
/// `WorkoutData` handles HealthKit authorization, data fetching, and statistical processing of workout information,
/// including metrics like intensity scores, heart rate data, and cumulative fitness statistics. It serves as the
/// primary data model for fitness activity tracking and analysis.
@MainActor
class WorkoutData: ObservableObject {
    /// The HealthKit store instance used to access health and fitness data
    var healthStore: HKHealthStore?
    
    /// Represents a single workout entry with comprehensive metrics and metadata
    struct WorkoutEntry {
        /// The type of workout activity (e.g., "Running", "Swimming")
        var workoutType: String
        /// The date and time when the workout began
        var startDate: Date
        /// Duration of the workout in minutes
        var duration: TimeInterval
        /// Total calories burned during the workout
        var caloriesBurned: Int
        /// Average heart rate during the workout in beats per minute
        var averageHeartRate: Int
        /// Maximum heart rate reached during the workout in beats per minute
        var peakHeartRate: Int
        /// Calculated intensity score based on heart rate and duration metrics
        var intensityScore: Double
        /// SF Symbol name representing the workout type
        var icon: String
    }
    
    /// Internal storage for processed workout entries
    /// Updates to this property trigger recalculation of workout statistics via property observer
    private var workouts: [WorkoutEntry] = [] {
        didSet {    //property observer in that runs code right after a property's value changes
            self.workoutCount = workouts.count
            //            self.mostCommonWorkoutType()
            //            self.bestWorkout()
        }
    }
    
    var highIntensityScore: Double = 0.0
    
    /// Calendar instance used for date-based calculations and queries
    private let calendar = Calendar.current
    
    private let startDate: Date
    private let endDate: Date
    
    init(year: Int){
        let currentYear = calendar.component(.year, from: Date())
        if year == currentYear {
            self.startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            self.endDate = Date()
        } else{
            // If it's a past year, use full year range
            self.startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
            self.endDate = calendar.date(from: DateComponents(year: year, month: 12, day: 31))!
        }
        self.healthStore = HKHealthStore()
    }
    
    /// Predicate used to filter workout samples within the specified date range
    private var datePredicate: NSPredicate {
        return HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
    }
    
    // MARK: - Published Properties
    
    /// Total number of workouts recorded
    @Published var workoutCount: Int = 0
    /// Cumulative calories burned across all workouts
    @Published var totalCaloriesBurned: Int = 0
    /// Total time spent working out in minutes
    @Published var totalWorkoutTime: Int = 0
    /// Dictionary tracking the frequency of each workout type
    @Published var typeCounts: [String: Int] = [:]
    /// Workout entry with the highest calculated intensity score
    @Published var mostIntenseWorkout = WorkoutEntry(
        workoutType: "",
        startDate: Date(),
        duration: 0.0,
        caloriesBurned: 0,
        averageHeartRate: 0,
        peakHeartRate: 0,
        intensityScore: 0.0,
        icon: "x.circle"
    )
    
    /// Requests authorization to access HealthKit workout and health data
    ///
    /// This method must be called before attempting to access any HealthKit data.
    /// It requests read-only access to workout, heart rate, and energy burned data.
    /// After successful authorization, it automatically fetches available workout data.
    ///
    /// - Throws: An error if HealthKit authorization fails
    public func requestAuthorization() async {
        
        // Safely get the HealthKit types
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              let energyBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Failed to get the heart rate or energy burned quantity types.")
            return
        }
        
        // workoutType is non-optional, so no need to guard it
        let workoutType = HKObjectType.workoutType()
        
        // Define the types of data we need access to
        let types: Set<HKObjectType> = [
            workoutType,
            heartRateType,
            energyBurnedType
        ]
        
        // Check if HealthKit is available on the device
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        do {
            // Request authorization to read the necessary data types
            try await healthStore?.requestAuthorization(toShare: [], read: types)
            
            // After authorization, fetch workouts
            await fetchWorkouts()
            
        } catch {
            print("HealthKit authorization error: \(error.localizedDescription)")
        }
    }
    
    /// Fetches and processes workout data from HealthKit within the specified date range
    ///
    /// This method performs the following operations:
    /// 1. Queries HealthKit for all workout samples between startDate and endDate
    /// 2. Processes each workout to extract relevant metrics
    /// 3. Updates published properties with aggregated statistics
    /// 4. Calculates and updates intensity scores and workout type frequencies
    ///
    /// - Throws: An error if workout data fetching fails
    public func fetchWorkouts() async {
        // Check if healthStore and predicate are available
        guard let healthStore = self.healthStore else {
            print("Error: Health store not available")
            return
        }
        
        // 1. Fetch all workouts in a single query
        let workouts: [HKWorkout]
        do {
            workouts = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKWorkout], Error>) in
                let query = HKSampleQuery(
                    sampleType: HKWorkoutType.workoutType(),
                    predicate: self.datePredicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { _, results, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    // success case
                    continuation.resume(returning: results as? [HKWorkout] ?? [])
                }
                
                // Execute the workouts query
                healthStore.execute(query)
            }
        } catch {
            print("Failed to fetch workouts: \(error.localizedDescription)")
            return
        }
        
        // 2. Process all data in a single pass
        for workout in workouts {
            await self.addWorkout(workout)
        }
        
        // 3. Log workout data (or update UI if needed)
        for workout in self.workouts {
            print("\nWorkout Type: \(workout.workoutType)")
            print("Start Date: \(workout.startDate)")
            print("Duration (minutes): \(workout.duration)")
            print("Calories Burned: \(workout.caloriesBurned)")
            print("Intensity Score: \(workout.intensityScore)")
            print("Average Heart Rate: \(workout.averageHeartRate) bpm")
            print("Peak Heart Rate: \(workout.peakHeartRate) bpm")
        }
    }
    
    /// Processes and adds a single workout to the data model, updating all relevant statistics
    ///
    /// - Parameter workout: The HKWorkout instance to process
    /// - Updates: workoutCount, totalCaloriesBurned, totalWorkoutTime, typeCounts, and mostIntenseWorkout
    private func addWorkout(_ workout: HKWorkout) async {
        var totalCalories = 0
        var avgHeartRate: Int = 0
        var maxHeartRate: Int = 0
        
        // Get calories burned from workout statistics
        if let energyBurnedStats = workout.statistics(for: HKQuantityType(.activeEnergyBurned)),
           let calories = energyBurnedStats.sumQuantity()?.doubleValue(for: .kilocalorie()) {
            totalCalories += Int(round(calories))
        }
        
        // Query heart rate samples directly for the workout duration
        if let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            let predicate = HKQuery.predicateForSamples(
                withStart: workout.startDate,
                end: workout.endDate,
                options: .strictStartDate
            )
            
            do {
                let heartRateSamples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKQuantitySample], Error>) in
                    let query = HKSampleQuery(
                        sampleType: heartRateType,
                        predicate: predicate,
                        limit: HKObjectQueryNoLimit,
                        sortDescriptors: nil
                    ) { _, samples, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        continuation.resume(returning: samples as? [HKQuantitySample] ?? [])
                    }
                    healthStore?.execute(query)
                }
                
                // Calculate average and maximum heart rates from samples
                if !heartRateSamples.isEmpty {
                    let heartRates = heartRateSamples.map {
                        $0.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    }
                    avgHeartRate = Int(round(heartRates.reduce(0, +) / Double(heartRates.count)))
                    maxHeartRate = Int(round(heartRates.max() ?? 0))
                }
            } catch {
                print("Error fetching heart rate data: \(error.localizedDescription)")
            }
        }
        
        // Create a new workout entry with all collected data
        let newWorkoutEntry = WorkoutEntry(
            workoutType: workout.workoutActivityType.name,
            startDate: workout.startDate,
            duration: workout.duration / 60,
            caloriesBurned: totalCalories,
            averageHeartRate: avgHeartRate,
            peakHeartRate: maxHeartRate,
            intensityScore: setWorkoutIntensityScore(
                avgHeartRate: avgHeartRate,
                peakHeartRate: maxHeartRate,
                duration: workout.duration / 60
            ),
            icon: workout.workoutActivityType.sfSymbol
        )
        
        // Update aggregate statistics
        self.workoutCount+=1                                        //calculates total number of workouts
        self.totalCaloriesBurned+=totalCalories                    //Calculates total calories burned
        self.totalWorkoutTime+=Int(newWorkoutEntry.duration)   //Calculates the total workout time in minutes
        self.typeCounts[newWorkoutEntry.workoutType, default: 0] += 1
        if(newWorkoutEntry.intensityScore > mostIntenseWorkout.intensityScore){
            mostIntenseWorkout = newWorkoutEntry;
        }
        self.workouts.append(newWorkoutEntry)
    }
    
    /// Calculates an intensity score for a workout based on heart rate and duration
    ///
    /// The score is calculated using a weighted formula:
    /// - 30% influence from average heart rate
    /// - 50% influence from peak heart rate
    /// - 20% influence from duration
    /// The final result is divided by 100 to normalize the score
    ///
    /// - Parameters:
    ///   - avgHeartRate: Average heart rate during the workout in BPM
    ///   - peakHeartRate: Maximum heart rate reached during the workout in BPM
    ///   - duration: Duration of the workout in minutes
    /// - Returns: A calculated intensity score representing the overall workout intensity
    private func setWorkoutIntensityScore(avgHeartRate: Int, peakHeartRate: Int, duration: Double) -> Double{
        return (Double(avgHeartRate) * 0.3 * Double(peakHeartRate) * 0.5 * Double(duration) * 0.2 ) / 100
    }
    
    ///Returns an array of sorted key value pairs, representing the users top workout types
    //    public func getTopWorkoutTypes() -> [(String, Int)] {
    //        return self.typeCounts
    //    }
    
    /// Returns the number of different workout types a user has completed
    ///
    /// - Returns: Count of unique workout types
    public func getNumDifferentWorkoutTypes() -> Int {
        return self.typeCounts.count
    }
    
    /// Returns the total number of workouts completed
    ///
    /// - Returns: Total workout count
    public func getWorkoutCount() -> Int {
        return workoutCount
    }
    
    /// Returns the total calories burned across all workouts
    ///
    /// - Returns: Total calories burned
    public func getCaloriesBurned() -> Int {
        return self.totalCaloriesBurned
    }
    
    /// Returns the total workout time in minutes
    ///
    /// - Returns: Total workout duration in minutes
    public func getWorkoutTime() -> Int {
        return self.totalWorkoutTime
    }
    
    /// Returns the workout with the highest calculated intensity score
    ///
    /// - Returns: WorkoutEntry representing the most intense workout
    public func getMostIntenseWorkout() -> WorkoutEntry {
        return self.mostIntenseWorkout
    }
}
