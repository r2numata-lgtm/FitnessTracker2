//
//  WorkoutDataService.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import CoreData
import Foundation

class WorkoutDataService: DataService<WorkoutEntry> {
    
    // MARK: - Workout Specific Methods
    func fetchWorkoutsForDate(_ date: Date, sortBy: WorkoutSortOption = .date) -> [WorkoutEntry] {
        let predicate = DateRangeService.createDatePredicate(for: date)
        let sortDescriptors = sortBy.sortDescriptors
        return fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }
    
    func fetchWorkoutsByExercise(_ exerciseName: String, limit: Int? = nil) -> [WorkoutEntry] {
        let predicate = NSPredicate(format: "exerciseName == %@", exerciseName)
        let sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: false)]
        
        let results = fetch(predicate: predicate, sortDescriptors: sortDescriptors)
        
        if let limit = limit {
            return Array(results.prefix(limit))
        }
        return results
    }
    
    func fetchGroupedWorkoutsForDate(_ date: Date) -> [String: [WorkoutEntry]] {
        let workouts = fetchWorkoutsForDate(date)
        return Dictionary(grouping: workouts) { workout in
            workout.safeExerciseName
        }
    }
    
    func fetchRecentExercises(limit: Int = 20) -> [String] {
        let sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: false)]
        let workouts = fetch(sortDescriptors: sortDescriptors)
        
        let exerciseNames = workouts.compactMap { $0.exerciseName }
        let uniqueExercises = Array(NSOrderedSet(array: exerciseNames)) as! [String]
        
        return Array(uniqueExercises.prefix(limit))
    }
    
    func fetchWorkoutsByCategory(_ category: String) -> [WorkoutEntry] {
        guard let exercises = AppConstants.Exercise.defaultExercises[category] else {
            return []
        }
        
        let predicate = NSPredicate(format: "exerciseName IN %@", exercises)
        let sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: false)]
        
        return fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }
    
    // MARK: - Statistics
    func getTotalCaloriesForDate(_ date: Date) -> Double {
        let workouts = fetchWorkoutsForDate(date)
        return workouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    func getTotalVolumeForExercise(_ exerciseName: String, dateRange: (start: Date, end: Date)? = nil) -> Double {
        var predicate = NSPredicate(format: "exerciseName == %@", exerciseName)
        
        if let range = dateRange {
            let datePredicate = NSPredicate(format: "date >= %@ AND date <= %@",
                                          range.start as NSDate,
                                          range.end as NSDate)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, datePredicate])
        }
        
        let workouts = fetch(predicate: predicate)
        return workouts.reduce(0) { $0 + $1.totalVolume }
    }
    
    func getMaxWeightForExercise(_ exerciseName: String) -> Double {
        let predicate = NSPredicate(format: "exerciseName == %@", exerciseName)
        let workouts = fetch(predicate: predicate)
        return workouts.map { $0.weight }.max() ?? 0
    }
    
    func getWorkoutFrequency(for period: TimePeriod) -> [String: Int] {
        let range = period.dateRange
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@",
                                   range.start as NSDate,
                                   range.end as NSDate)
        
        let workouts = fetch(predicate: predicate)
        let groupedByExercise = Dictionary(grouping: workouts) { $0.safeExerciseName }
        
        return groupedByExercise.mapValues { $0.count }
    }
    
    // MARK: - Create and Update
    func createWorkout(from dto: WorkoutDTO) throws -> WorkoutEntry {
        let workout = create()
        
        workout.date = dto.date
        workout.exerciseName = dto.exerciseName
        workout.weight = dto.weight
        workout.sets = Int16(dto.sets)
        workout.reps = Int16(dto.reps)
        workout.memo = dto.memo
        workout.photo = dto.photoData
        
        // カロリー計算
        workout.calculateCalories(bodyWeight: dto.bodyWeight ?? AppConstants.Calories.defaultBodyWeight)
        
        try save()
        
        // 履歴に追加
        UserDefaultsManager.shared.addExerciseToHistory(dto.exerciseName)
        
        return workout
    }
    
    func updateWorkout(_ workout: WorkoutEntry, with dto: WorkoutDTO) throws {
        workout.date = dto.date
        workout.exerciseName = dto.exerciseName
        workout.weight = dto.weight
        workout.sets = Int16(dto.sets)
        workout.reps = Int16(dto.reps)
        workout.memo = dto.memo
        
        if let photoData = dto.photoData {
            workout.photo = photoData
        }
        
        // カロリー再計算
        workout.calculateCalories(bodyWeight: dto.bodyWeight ?? AppConstants.Calories.defaultBodyWeight)
        
        try save()
    }
    
    // MARK: - Delete Operations
    func deleteWorkoutsForExercise(_ exerciseName: String, on date: Date) throws {
        let datePredicate = DateRangeService.createDatePredicate(for: date)
        let exercisePredicate = NSPredicate(format: "exerciseName == %@", exerciseName)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, exercisePredicate])
        
        try deleteAll(predicate: combinedPredicate)
    }
    
    func deleteAllWorkoutsForExercise(_ exerciseName: String) throws {
        let predicate = NSPredicate(format: "exerciseName == %@", exerciseName)
        try deleteAll(predicate: predicate)
    }
}

// MARK: - Supporting Types
enum WorkoutSortOption {
    case date
    case exercise
    case weight
    case calories
    
    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .date:
            return [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: false)]
        case .exercise:
            return [NSSortDescriptor(keyPath: \WorkoutEntry.exerciseName, ascending: true)]
        case .weight:
            return [NSSortDescriptor(keyPath: \WorkoutEntry.weight, ascending: false)]
        case .calories:
            return [NSSortDescriptor(keyPath: \WorkoutEntry.caloriesBurned, ascending: false)]
        }
    }
}

enum TimePeriod {
    case week
    case month
    case year
    
    var dateRange: (start: Date, end: Date) {
        switch self {
        case .week:
            return DateRangeService.createWeekRange(for: Date())
        case .month:
            return DateRangeService.createMonthRange(for: Date())
        case .year:
            return DateRangeService.createYearRange(for: Date())
        }
    }
}
