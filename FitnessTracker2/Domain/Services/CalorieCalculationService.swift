//
//  CalorieCalculationService.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import Foundation

// MARK: - カロリー計算サービス
class CalorieCalculationService: CalculationServiceProtocol {
    
    static let shared = CalorieCalculationService()
    private init() {}
    
    // MARK: - BMI計算
    func calculateBMI(weight: Double, height: Double) -> Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    // MARK: - 理想体重計算
    func calculateIdealWeight(height: Double) -> Double {
        let heightInMeters = height / 100.0
        let idealBMI = 22.0 // 理想的なBMI値
        return idealBMI * heightInMeters * heightInMeters
    }
    
    // MARK: - 基礎代謝量計算（Harris-Benedict式）
    func calculateBMR(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        let constants = gender.bmrConstant
        return constants.base + (constants.weight * weight) + (constants.height * height) - (constants.age * Double(age))
    }
    
    // MARK: - 総消費エネルギー計算（TDEE）
    func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        return bmr * activityLevel.multiplier
    }
    
    // MARK: - ワークアウトによる消費カロリー計算
    func calculateWorkoutCalories(exerciseName: String, weight: Double, sets: Int, reps: Int) -> Double {
        let metValue = getMetValue(for: exerciseName)
        let estimatedDurationHours = Double(sets * reps) / 60.0 // 1分あたり1回と仮定
        return metValue * weight * estimatedDurationHours
    }
    
    // MARK: - 歩数による消費カロリー計算
    func calculateStepsCalories(steps: Int, bodyWeight: Double) -> Double {
        let caloriesPerStep = 0.04 // 体重1kgあたり1歩で0.04kcal
        return Double(steps) * bodyWeight * caloriesPerStep / 1000
    }
    
    // MARK: - マクロ栄養素分布計算
    func calculateMacronutrients(totalCalories: Double, goal: CalorieGoal) -> MacronutrientDistribution {
        let ratios = goal.macroRatios()
        
        let proteinCalories = totalCalories * ratios.protein
        let carbCalories = totalCalories * ratios.carbs
        let fatCalories = totalCalories * ratios.fat
        
        return MacronutrientDistribution(
            calories: totalCalories,
            proteinGrams: proteinCalories / 4, // 1gあたり4kcal
            carbGrams: carbCalories / 4,       // 1gあたり4kcal
            fatGrams: fatCalories / 9          // 1gあたり9kcal
        )
    }
    
    // MARK: - 体脂肪率を考慮したBMR計算（Katch-McArdle式）
    func calculateBMRWithBodyFat(weight: Double, bodyFatPercentage: Double) -> Double {
        let leanBodyMass = weight * (1 - bodyFatPercentage / 100)
        return 370 + (21.6 * leanBodyMass)
    }
    
    // MARK: - 水分摂取目標量計算
    func calculateWaterIntakeGoal(weight: Double, activityLevel: ActivityLevel) -> Double {
        let baseWater = weight * 35 // 体重1kgあたり35ml
        let activityMultiplier = getWaterMultiplier(for: activityLevel)
        return baseWater * activityMultiplier
    }
    
    // MARK: - Private Methods
    
    /// 運動種目に対応するMET値を取得
    private func getMetValue(for exerciseName: String) -> Double {
        let metValues: [String: Double] = [
            "ベンチプレス": 6.0,
            "スクワット": 5.0,
            "デッドリフト": 6.0,
            "懸垂": 8.0,
            "腕立て伏せ": 3.8,
            "腹筋": 4.3,
            "ランニング": 8.0,
            "ウォーキング": 3.5,
            "サイクリング": 6.8,
            "水泳": 10.0,
            "ヨガ": 2.5,
            "筋力トレーニング": 5.0
        ]
        
        return metValues[exerciseName] ?? 5.0 // デフォルト値
    }
    
    /// 活動レベルに応じた水分摂取量の倍率を取得
    private func getWaterMultiplier(for activityLevel: ActivityLevel) -> Double {
        switch activityLevel {
        case .sedentary: return 1.0
        case .light: return 1.1
        case .moderate: return 1.2
        case .active: return 1.3
        case .veryActive: return 1.4
        }
    }
}

// MARK: - BMR計算サービス（より詳細な計算用）
class BMRCalculationService {
    
    static let shared = BMRCalculationService()
    private init() {}
    
    // MARK: - Harris-Benedict式によるBMR計算
    func calculateBMRHarrisBenedict(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        let constants = gender.bmrConstant
        return constants.base + (constants.weight * weight) + (constants.height * height) - (constants.age * Double(age))
    }
    
    // MARK: - Mifflin-St Jeor式によるBMR計算（より正確とされる）
    func calculateBMRMifflinStJeor(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        let baseCalc = (10 * weight) + (6.25 * height) - (5 * Double(age))
        
        switch gender {
        case .male:
            return baseCalc + 5
        case .female:
            return baseCalc - 161
        }
    }
    
    // MARK: - Katch-McArdle式によるBMR計算（体脂肪率を考慮）
    func calculateBMRKatchMcArdle(weight: Double, bodyFatPercentage: Double) -> Double {
        let leanBodyMass = weight * (1 - bodyFatPercentage / 100)
        return 370 + (21.6 * leanBodyMass)
    }
    
    // MARK: - 推奨されるBMR計算（体脂肪率がある場合はKatch-McArdle、ない場合はMifflin-St Jeor）
    func calculateRecommendedBMR(weight: Double, height: Double, age: Int, gender: Gender, bodyFatPercentage: Double? = nil) -> Double {
        if let bodyFat = bodyFatPercentage, bodyFat > 0 {
            return calculateBMRKatchMcArdle(weight: weight, bodyFatPercentage: bodyFat)
        } else {
            return calculateBMRMifflinStJeor(weight: weight, height: height, age: age, gender: gender)
        }
    }
}

// MARK: - カロリー目標設定サービス
class CalorieGoalService {
    
    static let shared = CalorieGoalService()
    private init() {}
    
    // MARK: - 体重変化目標に基づくカロリー目標計算
    func calculateCalorieGoal(currentWeight: Double, targetWeight: Double, timeFrameWeeks: Int, tdee: Double) -> CalorieGoalResult {
        let weightDifference = targetWeight - currentWeight
        let totalCalorieAdjustment = weightDifference * 7700 // 1kgあたり7700kcal
        let weeklyCalorieAdjustment = totalCalorieAdjustment / Double(timeFrameWeeks)
        let dailyCalorieAdjustment = weeklyCalorieAdjustment / 7
        
        let targetCalories = tdee + dailyCalorieAdjustment
        
        return CalorieGoalResult(
            targetCalories: targetCalories,
            dailyAdjustment: dailyCalorieAdjustment,
            weightChangeGoal: weightDifference,
            timeFrameWeeks: timeFrameWeeks
        )
    }
}

// MARK: - カロリー目標結果
struct CalorieGoalResult {
    let targetCalories: Double
    let dailyAdjustment: Double
    let weightChangeGoal: Double
    let timeFrameWeeks: Int
    
    var isWeightLoss: Bool {
        return weightChangeGoal < 0
    }
    
    var isWeightGain: Bool {
        return weightChangeGoal > 0
    }
    
    var weeklyWeightChange: Double {
        return weightChangeGoal / Double(timeFrameWeeks)
    }
}
