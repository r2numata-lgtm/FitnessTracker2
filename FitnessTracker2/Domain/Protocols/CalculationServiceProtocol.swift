//
//  CalculationServiceProtocol.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import Foundation

// MARK: - 計算サービスプロトコル
protocol CalculationServiceProtocol {
    // BMI計算
    func calculateBMI(weight: Double, height: Double) -> Double
    
    // 理想体重計算
    func calculateIdealWeight(height: Double) -> Double
    
    // 基礎代謝量計算（Harris-Benedict式）
    func calculateBMR(weight: Double, height: Double, age: Int, gender: Gender) -> Double
    
    // 総消費エネルギー計算（TDEE）
    func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double
    
    // ワークアウトによる消費カロリー計算
    func calculateWorkoutCalories(exerciseName: String, weight: Double, sets: Int, reps: Int) -> Double
    
    // 歩数による消費カロリー計算
    func calculateStepsCalories(steps: Int, bodyWeight: Double) -> Double
    
    // マクロ栄養素分布計算
    func calculateMacronutrients(totalCalories: Double, goal: CalorieGoal) -> MacronutrientDistribution
    
    // 体脂肪率を考慮したBMR計算（Katch-McArdle式）
    func calculateBMRWithBodyFat(weight: Double, bodyFatPercentage: Double) -> Double
    
    // 水分摂取目標量計算
    func calculateWaterIntakeGoal(weight: Double, activityLevel: ActivityLevel) -> Double
}

// MARK: - 性別
enum Gender: String, CaseIterable {
    case male = "男性"
    case female = "女性"
    
    var bmrConstant: BMRConstants {
        switch self {
        case .male:
            return BMRConstants(base: 88.362, weight: 13.397, height: 4.799, age: 5.677)
        case .female:
            return BMRConstants(base: 447.593, weight: 9.247, height: 3.098, age: 4.330)
        }
    }
}

// MARK: - 活動レベル
enum ActivityLevel: String, CaseIterable {
    case sedentary = "座り仕事中心"
    case light = "軽い運動"
    case moderate = "適度な運動"
    case active = "活発"
    case veryActive = "非常に活発"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
    
    var description: String {
        switch self {
        case .sedentary: return "ほぼ運動しない"
        case .light: return "週1-3回の軽い運動"
        case .moderate: return "週3-5回の適度な運動"
        case .active: return "週6-7回の激しい運動"
        case .veryActive: return "1日2回の運動または肉体労働"
        }
    }
}

// MARK: - カロリー目標
enum CalorieGoal: String, CaseIterable {
    case balanced = "バランス重視"
    case lowCarb = "低炭水化物"
    case highProtein = "高タンパク質"
    case keto = "ケトジェニック"
    
    func macroRatios() -> (protein: Double, carbs: Double, fat: Double) {
        switch self {
        case .balanced:
            return (0.25, 0.45, 0.30) // 25% protein, 45% carbs, 30% fat
        case .lowCarb:
            return (0.30, 0.25, 0.45)
        case .highProtein:
            return (0.35, 0.35, 0.30)
        case .keto:
            return (0.25, 0.05, 0.70)
        }
    }
}

// MARK: - BMR計算定数
struct BMRConstants {
    let base: Double
    let weight: Double
    let height: Double
    let age: Double
}

// MARK: - マクロ栄養素分布
struct MacronutrientDistribution {
    let calories: Double
    let proteinGrams: Double
    let carbGrams: Double
    let fatGrams: Double
    
    var proteinCalories: Double { proteinGrams * 4 }
    var carbCalories: Double { carbGrams * 4 }
    var fatCalories: Double { fatGrams * 9 }
    
    var proteinPercentage: Double { (proteinCalories / calories) * 100 }
    var carbPercentage: Double { (carbCalories / calories) * 100 }
    var fatPercentage: Double { (fatCalories / calories) * 100 }
}
