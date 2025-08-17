//
//  FoodViewModel.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import Foundation
import CoreData
import Combine

class FoodViewModel: ObservableObject {
    @Published var foods: [FoodEntry] = []
    @Published var selectedDate = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddFood = false
    
    private let viewContext: NSManagedObjectContext
    private let foodDataService: FoodDataService
    private var cancellables = Set<AnyCancellable>()
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.foodDataService = FoodDataService(context: viewContext)
        
        setupSubscriptions()
        loadFoods()
    }
    
    private func setupSubscriptions() {
        $selectedDate
            .sink { [weak self] _ in
                self?.loadFoods()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func loadFoods() {
        isLoading = true
        errorMessage = nil
        
        do {
            foods = foodDataService.fetchFoodsForDate(selectedDate)
        } catch {
            errorMessage = "食事データの読み込みに失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addFood(dto: FoodDTO) {
        do {
            _ = try foodDataService.createFood(from: dto)
            loadFoods()
        } catch {
            errorMessage = "食事の保存に失敗しました: \(error.localizedDescription)"
        }
    }
    
    func deleteFood(_ food: FoodEntry) {
        do {
            try foodDataService.delete(food)
            loadFoods()
        } catch {
            errorMessage = "食事の削除に失敗しました: \(error.localizedDescription)"
        }
    }
    
    func deleteFoodsForMealType(_ mealType: MealType) {
        do {
            try foodDataService.deleteFoodsForMealType(mealType, on: selectedDate)
            loadFoods()
        } catch {
            errorMessage = "食事グループの削除に失敗しました: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Computed Properties
    
    var groupedFoods: [MealType: [FoodEntry]] {
        var grouped: [MealType: [FoodEntry]] = [:]
        
        for mealType in MealType.allCases {
            grouped[mealType] = foods.filter { food in
                food.mealType == mealType.rawValue
            }
        }
        
        return grouped
    }
    
    var totalCaloriesForDay: Double {
        foods.reduce(0) { $0 + $1.calories }
    }
    
    var foodCountForDay: Int {
        foods.count
    }
    
    // MARK: - Meal Type Statistics
    
    func getCaloriesForMealType(_ mealType: MealType) -> Double {
        return groupedFoods[mealType]?.reduce(0) { $0 + $1.calories } ?? 0
    }
    
    func getFoodCountForMealType(_ mealType: MealType) -> Int {
        return groupedFoods[mealType]?.count ?? 0
    }
    
    func getMealTypeBreakdown() -> [String: Double] {
        var breakdown: [String: Double] = [:]
        
        for mealType in MealType.allCases {
            breakdown[mealType.displayName] = getCaloriesForMealType(mealType)
        }
        
        return breakdown
    }
    
    // MARK: - Food History and Suggestions
    
    func getRecentFoods() -> [String] {
        return foodDataService.fetchRecentFoods(limit: 20)
    }
    
    func searchFoods(query: String) -> [FoodEntry] {
        return foodDataService.fetchFoodsByName(query, limit: 10)
    }
    
    func getCommonFoods() -> [CommonFood] {
        return foodDataService.getCommonFoods()
    }
    
    func searchCommonFoods(query: String) -> [CommonFood] {
        return foodDataService.searchCommonFoods(query: query)
    }
    
    // MARK: - Weekly Statistics
    
    func getWeeklyStats() -> WeeklyFoodStats {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? selectedDate
        
        var weeklyFoods: [FoodEntry] = []
        var currentDate = weekStart
        
        while currentDate <= weekEnd {
            let dayFoods = foodDataService.fetchFoodsForDate(currentDate)
            weeklyFoods.append(contentsOf: dayFoods)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        let totalCalories = weeklyFoods.reduce(0) { $0 + $1.calories }
        let uniqueFoods = Set(weeklyFoods.compactMap { $0.foodName }).count
        let totalItems = weeklyFoods.count
        
        let mealTypeBreakdown = Dictionary(grouping: weeklyFoods) { $0.mealType ?? "その他" }
            .mapValues { $0.reduce(0) { $0 + $1.calories } }
        
        return WeeklyFoodStats(
            totalCalories: totalCalories,
            uniqueFoods: uniqueFoods,
            totalItems: totalItems,
            mealTypeBreakdown: mealTypeBreakdown,
            eatingDays: Set(weeklyFoods.map { Calendar.current.startOfDay(for: $0.date) }).count
        )
    }
    
    // MARK: - Nutrition Goals
    
    func getCalorieGoalProgress(dailyGoal: Double) -> Double {
        guard dailyGoal > 0 else { return 0 }
        return (totalCaloriesForDay / dailyGoal) * 100
    }
    
    func isOverCalorieGoal(dailyGoal: Double) -> Bool {
        return totalCaloriesForDay > dailyGoal
    }
    
    func getRemainingCalories(dailyGoal: Double) -> Double {
        return max(0, dailyGoal - totalCaloriesForDay)
    }
}

// MARK: - Supporting Types

struct WeeklyFoodStats {
    let totalCalories: Double
    let uniqueFoods: Int
    let totalItems: Int
    let mealTypeBreakdown: [String: Double]
    let eatingDays: Int
    
    var averageCaloriesPerDay: Double {
        guard eatingDays > 0 else { return 0 }
        return totalCalories / Double(eatingDays)
    }
    
    var averageItemsPerDay: Double {
        guard eatingDays > 0 else { return 0 }
        return Double(totalItems) / Double(eatingDays)
    }
    
    var mostConsumedMealType: String? {
        return mealTypeBreakdown.max(by: { $0.value < $1.value })?.key
    }
}
