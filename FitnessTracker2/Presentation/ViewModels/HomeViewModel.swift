//
//  HomeViewModel.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import Foundation
import CoreData
import Combine

class HomeViewModel: ObservableObject {
    @Published var dailyCalories: DailyCalories?
    @Published var todayWorkouts: [WorkoutEntry] = []
    @Published var todayFoods: [FoodEntry] = []
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let viewContext: NSManagedObjectContext
    private let healthKitManager: HealthKitManager
    private var cancellables = Set<AnyCancellable>()
    
    init(viewContext: NSManagedObjectContext, healthKitManager: HealthKitManager) {
        self.viewContext = viewContext
        self.healthKitManager = healthKitManager
        
        setupSubscriptions()
        loadTodayData()
    }
    
    private func setupSubscriptions() {
        $selectedDate
            .sink { [weak self] _ in
                self?.loadTodayData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadTodayData() {
        isLoading = true
        errorMessage = nil
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        do {
            // ワークアウトデータを取得
            let workoutRequest: NSFetchRequest<WorkoutEntry> = WorkoutEntry.fetchRequest()
            workoutRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                                 startOfDay as NSDate,
                                                 endOfDay as NSDate)
            workoutRequest.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutEntry.date, ascending: true)]
            todayWorkouts = try viewContext.fetch(workoutRequest)
            
            // 食事データを取得
            let foodRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
            foodRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                              startOfDay as NSDate,
                                              endOfDay as NSDate)
            foodRequest.sortDescriptors = [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: true)]
            todayFoods = try viewContext.fetch(foodRequest)
            
            // カロリーデータを取得
            let calorieRequest: NSFetchRequest<DailyCalories> = DailyCalories.fetchRequest()
            calorieRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                                 startOfDay as NSDate,
                                                 endOfDay as NSDate)
            let calories = try viewContext.fetch(calorieRequest)
            dailyCalories = calories.first
            
            updateDailyCalories()
            
        } catch {
            errorMessage = "データの読み込みに失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateDailyCalories() {
        // カロリーデータがない場合は作成
        if dailyCalories == nil {
            createTodayCaloriesEntry()
        }
        
        // 合計値を計算して更新
        let totalIntake = todayFoods.reduce(0) { $0 + $1.calories }
        let totalBurned = todayWorkouts.reduce(0) { $0 + $1.caloriesBurned }
        
        dailyCalories?.totalIntake = totalIntake
        dailyCalories?.totalBurned = totalBurned
        dailyCalories?.netCalories = totalIntake - totalBurned
        
        saveContext()
    }
    
    func refreshHealthKitData() {
        healthKitManager.fetchTodaySteps()
        healthKitManager.fetchTodayActiveCalories { [weak self] calories in
            DispatchQueue.main.async {
                self?.dailyCalories?.steps = Int32(self?.healthKitManager.dailySteps ?? 0)
                self?.saveContext()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var totalIntake: Double {
        todayFoods.reduce(0) { $0 + $1.calories }
    }
    
    var totalBurned: Double {
        todayWorkouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    var netCalories: Double {
        totalIntake - totalBurned
    }
    
    var groupedWorkouts: [String: [WorkoutEntry]] {
        Dictionary(grouping: todayWorkouts) { workout in
            workout.exerciseName ?? "不明な種目"
        }
    }
    
    var groupedFoods: [String: [FoodEntry]] {
        Dictionary(grouping: todayFoods) { food in
            food.mealType ?? "その他"
        }
    }
    
    // MARK: - Private Methods
    
    private func createTodayCaloriesEntry() {
        let newCalories = DailyCalories(context: viewContext)
        newCalories.date = selectedDate
        newCalories.totalIntake = 0
        newCalories.totalBurned = 0
        newCalories.netCalories = 0
        newCalories.steps = Int32(healthKitManager.dailySteps)
        
        dailyCalories = newCalories
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            errorMessage = "データの保存に失敗しました: \(error.localizedDescription)"
        }
    }
}
