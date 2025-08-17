//
//  WorkoutViewModel.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import Foundation
import CoreData
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var workouts: [WorkoutEntry] = []
    @Published var selectedDate = Date()
    @Published var calendarDate = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddWorkout = false
    @Published var showingExerciseDetail = false
    @Published var selectedExercise = ""
    
    private let viewContext: NSManagedObjectContext
    private let workoutDataService: WorkoutDataService
    private var cancellables = Set<AnyCancellable>()
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.workoutDataService = WorkoutDataService(context: viewContext)
        
        setupSubscriptions()
        loadWorkouts()
    }
    
    private func setupSubscriptions() {
        $selectedDate
            .sink { [weak self] _ in
                self?.loadWorkouts()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadWorkouts() {
        isLoading = true
        errorMessage = nil
        
        do {
            workouts = workoutDataService.fetchWorkoutsForDate(selectedDate)
        } catch {
            errorMessage = "ワークアウトデータの読み込みに失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addWorkout(dto: WorkoutDTO) {
        do {
            _ = try workoutDataService.createWorkout(from: dto)
            loadWorkouts()
        } catch {
            errorMessage = "ワークアウトの保存に失敗しました: \(error.localizedDescription)"
        }
    }
    
    func deleteWorkout(_ workout: WorkoutEntry) {
        do {
            try workoutDataService.delete(workout)
            loadWorkouts()
        } catch {
            errorMessage = "ワークアウトの削除に失敗しました: \(error.localizedDescription)"
        }
    }
    
    func deleteWorkoutGroup(exerciseName: String) {
        do {
            try workoutDataService.deleteWorkoutsForExercise(exerciseName, on: selectedDate)
            loadWorkouts()
        } catch {
            errorMessage = "ワークアウトグループの削除に失敗しました: \(error.localizedDescription)"
        }
    }
    
    func moveToToday() {
        let today = Date()
        selectedDate = today
        calendarDate = today
    }
    
    // MARK: - Computed Properties
    
    var groupedWorkouts: [String: [WorkoutEntry]] {
        Dictionary(grouping: workouts) { workout in
            workout.exerciseName ?? "不明な種目"
        }
    }
    
    var totalCaloriesForDay: Double {
        workouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    var exerciseCount: Int {
        groupedWorkouts.keys.count
    }
    
    var navigationTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: calendarDate)
    }
    
    // MARK: - Exercise Management
    
    func getRecentExercises() -> [String] {
        return workoutDataService.fetchRecentExercises(limit: 10)
    }
    
    func getMaxWeightForExercise(_ exerciseName: String) -> Double {
        return workoutDataService.getMaxWeightForExercise(exerciseName)
    }
    
    func getTotalVolumeForExercise(_ exerciseName: String) -> Double {
        let range = (start: selectedDate.startOfDay(), end: selectedDate.endOfDay())
        return workoutDataService.getTotalVolumeForExercise(exerciseName, dateRange: range)
    }
    
    // MARK: - Statistics
    
    func getWeeklyStats() -> WeeklyWorkoutStats {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? selectedDate
        
        var weeklyWorkouts: [WorkoutEntry] = []
        var currentDate = weekStart
        
        while currentDate <= weekEnd {
            let dayWorkouts = workoutDataService.fetchWorkoutsForDate(currentDate)
            weeklyWorkouts.append(contentsOf: dayWorkouts)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        let totalCalories = weeklyWorkouts.reduce(0) { $0 + $1.caloriesBurned }
        let uniqueExercises = Set(weeklyWorkouts.compactMap { $0.exerciseName }).count
        let totalSets = weeklyWorkouts.count
        
        return WeeklyWorkoutStats(
            totalCalories: totalCalories,
            uniqueExercises: uniqueExercises,
            totalSets: totalSets,
            workoutDays: Set(weeklyWorkouts.map { Calendar.current.startOfDay(for: $0.date) }).count
        )
    }
}

// MARK: - Supporting Types

struct WeeklyWorkoutStats {
    let totalCalories: Double
    let uniqueExercises: Int
    let totalSets: Int
    let workoutDays: Int
    
    var averageCaloriesPerDay: Double {
        guard workoutDays > 0 else { return 0 }
        return totalCalories / Double(workoutDays)
    }
    
    var averageSetsPerDay: Double {
        guard workoutDays > 0 else { return 0 }
        return Double(totalSets) / Double(workoutDays)
    }
}
