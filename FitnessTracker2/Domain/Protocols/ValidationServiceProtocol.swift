//
//  ValidationServiceProtocol.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import Foundation

// MARK: - バリデーションサービスプロトコル
protocol ValidationServiceProtocol {
    // 体組成データのバリデーション
    func validateBodyComposition(_ dto: BodyCompositionDTO) -> ValidationResult
    
    // ワークアウトデータのバリデーション
    func validateWorkout(_ dto: WorkoutDTO) -> ValidationResult
    
    // 食事データのバリデーション
    func validateFood(_ dto: FoodDTO) -> ValidationResult
    
    // 身長のバリデーション
    func validateHeight(_ height: Double) -> ValidationResult
    
    // 体重のバリデーション
    func validateWeight(_ weight: Double) -> ValidationResult
    
    // 体脂肪率のバリデーション
    func validateBodyFatPercentage(_ bodyFatPercentage: Double) -> ValidationResult
    
    // カロリーのバリデーション
    func validateCalories(_ calories: Double) -> ValidationResult
}

// MARK: - バリデーション結果
enum ValidationResult {
    case success
    case failure([String])
    
    var isValid: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var errorMessages: [String] {
        switch self {
        case .success:
            return []
        case .failure(let errors):
            return errors
        }
    }
}

// MARK: - 体組成DTO
struct BodyCompositionDTO {
    let height: Double
    let weight: Double
    let bodyFatPercentage: Double
    let basalMetabolicRate: Double
    let age: Int
    let gender: Gender
    let activityLevel: ActivityLevel
    
    init(height: Double = 0,
         weight: Double = 0,
         bodyFatPercentage: Double = 0,
         basalMetabolicRate: Double = 0,
         age: Int = 0,
         gender: Gender = .male,
         activityLevel: ActivityLevel = .moderate) {
        self.height = height
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.basalMetabolicRate = basalMetabolicRate
        self.age = age
        self.gender = gender
        self.activityLevel = activityLevel
    }
}

// MARK: - ワークアウトDTO
struct WorkoutDTO {
    let exerciseName: String
    let weight: Double
    let sets: Int
    let reps: Int
    let memo: String?
    let date: Date
    
    init(exerciseName: String = "",
         weight: Double = 0,
         sets: Int = 0,
         reps: Int = 0,
         memo: String? = nil,
         date: Date = Date()) {
        self.exerciseName = exerciseName
        self.weight = weight
        self.sets = sets
        self.reps = reps
        self.memo = memo
        self.date = date
    }
}

// MARK: - 食事DTO
struct FoodDTO {
    let foodName: String
    let calories: Double
    let mealType: String
    let protein: Double
    let carbs: Double
    let fat: Double
    let date: Date
    
    init(foodName: String = "",
         calories: Double = 0,
         mealType: String = "朝食",
         protein: Double = 0,
         carbs: Double = 0,
         fat: Double = 0,
         date: Date = Date()) {
        self.foodName = foodName
        self.calories = calories
        self.mealType = mealType
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
    }
}

// MARK: - バリデーションルール定数
struct ValidationRules {
    // 身長の範囲（cm）
    static let heightRange: ClosedRange<Double> = 50...250
    
    // 体重の範囲（kg）
    static let weightRange: ClosedRange<Double> = 20...300
    
    // 体脂肪率の範囲（%）
    static let bodyFatRange: ClosedRange<Double> = 3...60
    
    // 年齢の範囲
    static let ageRange: ClosedRange<Int> = 10...120
    
    // BMRの範囲（kcal）
    static let bmrRange: ClosedRange<Double> = 800...4000
    
    // カロリーの範囲（kcal）
    static let caloriesRange: ClosedRange<Double> = 0...10000
    
    // 重量の範囲（kg）
    static let exerciseWeightRange: ClosedRange<Double> = 0...1000
    
    // セット数の範囲
    static let setsRange: ClosedRange<Int> = 1...100
    
    // 回数の範囲
    static let repsRange: ClosedRange<Int> = 1...1000
    
    // 文字数制限
    static let maxExerciseNameLength = 50
    static let maxFoodNameLength = 100
    static let maxMemoLength = 500
}

// MARK: - Double拡張
extension Double {
    func isValidHeight() -> Bool {
        ValidationRules.heightRange.contains(self)
    }
    
    func isValidWeight() -> Bool {
        ValidationRules.weightRange.contains(self)
    }
    
    func isValidBodyFat() -> Bool {
        ValidationRules.bodyFatRange.contains(self)
    }
    
    func isValidCalories() -> Bool {
        ValidationRules.caloriesRange.contains(self)
    }
    
    func isValidExerciseWeight() -> Bool {
        ValidationRules.exerciseWeightRange.contains(self)
    }
}

// MARK: - Int拡張
extension Int {
    func isValidAge() -> Bool {
        ValidationRules.ageRange.contains(self)
    }
    
    func isValidSets() -> Bool {
        ValidationRules.setsRange.contains(self)
    }
    
    func isValidReps() -> Bool {
        ValidationRules.repsRange.contains(self)
    }
}
