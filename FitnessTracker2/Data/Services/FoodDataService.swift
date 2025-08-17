//
//  FoodDataService.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import CoreData
import Foundation

class FoodDataService: DataService<FoodEntry> {
    
    // MARK: - Food Specific Methods
    func fetchFoodsForDate(_ date: Date, sortBy: FoodSortOption = .date) -> [FoodEntry] {
        let predicate = DateRangeService.createDatePredicate(for: date)
        let sortDescriptors = sortBy.sortDescriptors
        return fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }
    
    func fetchFoodsByMealType(_ mealType: MealType, date: Date) -> [FoodEntry] {
        let datePredicate = DateRangeService.createDatePredicate(for: date)
        let mealPredicate = NSPredicate(format: "mealType == %@", mealType.rawValue)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, mealPredicate])
        
        let sortDescriptors = [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: true)]
        return fetch(predicate: combinedPredicate, sortDescriptors: sortDescriptors)
    }
    
    func fetchGroupedFoodsForDate(_ date: Date) -> [String: [FoodEntry]] {
        let foods = fetchFoodsForDate(date)
        return Dictionary(grouping: foods) { food in
            food.safeMealType
        }
    }
    
    func fetchRecentFoods(limit: Int = 50) -> [String] {
        let sortDescriptors = [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: false)]
        let foods = fetch(sortDescriptors: sortDescriptors)
        
        let foodNames = foods.compactMap { $0.foodName }
        let uniqueFoods = Array(NSOrderedSet(array: foodNames)) as! [String]
        
        return Array(uniqueFoods.prefix(limit))
    }
    
    func fetchFoodsByName(_ foodName: String, limit: Int? = nil) -> [FoodEntry] {
        let predicate = NSPredicate(format: "foodName CONTAINS[cd] %@", foodName)
        let sortDescriptors = [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: false)]
        
        let results = fetch(predicate: predicate, sortDescriptors: sortDescriptors)
        
        if let limit = limit {
            return Array(results.prefix(limit))
        }
        return results
    }
    
    // MARK: - Statistics
    func getTotalCaloriesForDate(_ date: Date) -> Double {
        let foods = fetchFoodsForDate(date)
        return foods.reduce(0) { $0 + $1.calories }
    }
    
    func getTotalCaloriesForMealType(_ mealType: MealType, date: Date) -> Double {
        let foods = fetchFoodsByMealType(mealType, date: date)
        return foods.reduce(0) { $0 + $1.calories }
    }
    
    func getMealTypeBreakdown(for date: Date) -> [String: Double] {
        let groupedFoods = fetchGroupedFoodsForDate(date)
        return groupedFoods.mapValues { foods in
            foods.reduce(0) { $0 + $1.calories }
        }
    }
    
    func getAverageCaloriesPerDay(for period: TimePeriod) -> Double {
        let range = period.dateRange
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@",
                                   range.start as NSDate,
                                   range.end as NSDate)
        
        let foods = fetch(predicate: predicate)
        let totalCalories = foods.reduce(0) { $0 + $1.calories }
        
        let days = Calendar.current.dateComponents([.day], from: range.start, to: range.end).day ?? 1
        return totalCalories / Double(max(days, 1))
    }
    
    func getFoodFrequency(for period: TimePeriod) -> [String: Int] {
        let range = period.dateRange
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@",
                                   range.start as NSDate,
                                   range.end as NSDate)
        
        let foods = fetch(predicate: predicate)
        let groupedByName = Dictionary(grouping: foods) { $0.safeFoodName }
        
        return groupedByName.mapValues { $0.count }
    }
    
    func getWeeklyCaloriesTrend() -> [WeeklyCaloriesData] {
        var weeklyData: [WeeklyCaloriesData] = []
        let calendar = Calendar.current
        
        for i in 0..<8 { // 過去8週間
            let weekStartDate = calendar.date(byAdding: .weekOfYear, value: -i, to: Date()) ?? Date()
            let range = DateRangeService.createWeekRange(for: weekStartDate)
            
            let predicate = NSPredicate(format: "date >= %@ AND date <= %@",
                                       range.start as NSDate,
                                       range.end as NSDate)
            
            let foods = fetch(predicate: predicate)
            let totalCalories = foods.reduce(0) { $0 + $1.calories }
            
            weeklyData.append(WeeklyCaloriesData(
                weekStart: range.start,
                totalCalories: totalCalories
            ))
        }
        
        return weeklyData.reversed()
    }
    
    // MARK: - Create and Update
    func createFood(from dto: FoodDTO) throws -> FoodEntry {
        let food = create()
        
        food.date = dto.date
        food.foodName = dto.foodName
        food.calories = dto.calories
        food.mealType = dto.mealType.rawValue
        food.photo = dto.photoData
        
        try save()
        
        // 履歴に追加
        UserDefaultsManager.shared.addFoodToHistory(dto.foodName)
        
        return food
    }
    
    func updateFood(_ food: FoodEntry, with dto: FoodDTO) throws {
        food.date = dto.date
        food.foodName = dto.foodName
        food.calories = dto.calories
        food.mealType = dto.mealType.rawValue
        
        if let photoData = dto.photoData {
            food.photo = photoData
        }
        
        try save()
    }
    
    // MARK: - Delete Operations
    func deleteFoodsForMealType(_ mealType: MealType, on date: Date) throws {
        let datePredicate = DateRangeService.createDatePredicate(for: date)
        let mealPredicate = NSPredicate(format: "mealType == %@", mealType.rawValue)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, mealPredicate])
        
        try deleteAll(predicate: combinedPredicate)
    }
    
    // MARK: - Common Foods Management
    func getCommonFoods() -> [CommonFood] {
        return AppConstants.Food.commonFoods
    }
    
    func searchCommonFoods(query: String) -> [CommonFood] {
        return getCommonFoods().filter { food in
            food.name.localizedCaseInsensitiveContains(query)
        }
    }
}

// MARK: - Supporting Types
enum FoodSortOption {
    case date
    case name
    case calories
    case mealType
    
    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .date:
            return [NSSortDescriptor(keyPath: \FoodEntry.date, ascending: false)]
        case .name:
            return [NSSortDescriptor(keyPath: \FoodEntry.foodName, ascending: true)]
        case .calories:
            return [NSSortDescriptor(keyPath: \FoodEntry.calories, ascending: false)]
        case .mealType:
            return [NSSortDescriptor(keyPath: \FoodEntry.mealType, ascending: true)]
        }
    }
}

struct WeeklyCaloriesData {
    let weekStart: Date
    let totalCalories: Double
    
    var formattedWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: weekStart)
    }
}

struct CommonFood {
    let name: String
    let calories: Double
    
    var formattedCalories: String {
        return "\(Int(calories))kcal"
    }
}

// MARK: - Common Foods Data
extension AppConstants.Food {
    static let commonFoods = [
        CommonFood(name: "白米(茶碗1杯)", calories: 252),
        CommonFood(name: "食パン(6枚切り1枚)", calories: 177),
        CommonFood(name: "鶏胸肉(100g)", calories: 191),
        CommonFood(name: "鶏卵(1個)", calories: 91),
        CommonFood(name: "牛乳(200ml)", calories: 134),
        CommonFood(name: "バナナ(1本)", calories: 93),
        CommonFood(name: "りんご(1個)", calories: 138),
        CommonFood(name: "納豆(1パック)", calories: 100),
        CommonFood(name: "豆腐(100g)", calories: 72),
        CommonFood(name: "サラダ(100g)", calories: 20),
        CommonFood(name: "ヨーグルト(100g)", calories: 62),
        CommonFood(name: "アボカド(1個)", calories: 262),
        CommonFood(name: "ブロッコリー(100g)", calories: 33),
        CommonFood(name: "鮭(100g)", calories: 233),
        CommonFood(name: "ツナ缶(1缶)", calories: 190),
        CommonFood(name: "オートミール(30g)", calories: 114),
        CommonFood(name: "プロテインシェイク", calories: 120),
        CommonFood(name: "アーモンド(10粒)", calories: 60),
        CommonFood(name: "チーズ(20g)", calories: 68),
        CommonFood(name: "パスタ(100g)", calories: 150)
    ]
}
