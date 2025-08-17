//
//  CalculationService.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

protocol CalculationServiceProtocol {
    func calculateBMI(weight: Double, height: Double) -> Double
    func calculateIdealWeight(height: Double) -> Double
    func calculateBMR(weight: Double, height: Double, age: Int, gender: Gender) -> Double
    func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double
    func calculateWorkoutCalories(exerciseName: String, weight: Double, sets: Int, reps: Int) -> Double
    func calculateStepsCalories(steps: Int, bodyWeight: Double) -> Double
}

class CalculationService: CalculationServiceProtocol {
    
    static let shared = CalculationService()
    private init() {}
    
//
//  BMRCalculationService.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

class BMRCalculationService {
    
    static let shared = BMRCalculationService()
    private init() {}
    
    // MARK: - BMR Calculation Methods
    
    /// Harris-Benedict式によるBMR計算
    func calculateBMRHarrisBenedict(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        let constants = gender.bmrConstant
        return constants.base + (constants.weight * weight) + (constants.height * height) - (constants.age * Double(age))
    }
    
    /// Mifflin-St Jeor式によるBMR計算（より正確とされる）
    func calculateBMRMifflinStJeor(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        let baseCalc = (10 * weight) + (6.25 * height) - (5 * Double(age))
        
        switch gender {
        case .male:
            return baseCalc + 5
        case .female:
            return baseCalc - 161
        }
    }
    
    /// Katch-McArdle式によるBMR計算（体脂肪率を考慮）
    func calculateBMRKatchMcArdle(weight: Double, bodyFatPercentage: Double) -> Double {
        let leanBodyMass = weight * (1 - bodyFatPercentage / 100)
        return 370 + (21.6 * leanBodyMass)
    }
    
    /// 推奨されるBMR計算（体脂肪率がある場合はKatch-McArdle、ない場合はMifflin-St Jeor）
    func calculateRecommendedBMR(weight: Double, height: Double, age: Int, gender: Gender, bodyFatPercentage: Double? = nil) -> Double {
        if let bodyFat = bodyFatPercentage, bodyFat > 0 {
            return calculateBMRKatchMcArdle(weight: weight, bodyFatPercentage: bodyFat)
        } else {
            return calculateBMRMifflinStJeor(weight: weight, height: height, age: age, gender: gender)
        }
    }
    
    // MARK: - BMR Analysis
    func getBMRCategory(bmr: Double, age: Int, gender: Gender) -> BMRCategory {
        // 年齢・性別別のBMR標準値との比較
        let standardBMR = getStandardBMR(age: age, gender: gender)
        let ratio = bmr / standardBMR
        
        switch ratio {
        case ..<0.85:
            return .veryLow
        case 0.85..<0.95:
            return .low
        case 0.95..<1.05:
            return .normal
        case 1.05..<1.15:
            return .high
        default:
            return .veryHigh
        }
    }
    
    private func getStandardBMR(age: Int, gender: Gender) -> Double {
        // 年齢別標準BMR（概算値）
        let baseValue: Double
        
        switch gender {
        case .male:
            switch age {
            case 18..<30: baseValue = 1700
            case 30..<50: baseValue = 1650
            case 50..<70: baseValue = 1550
            default: baseValue = 1450
            }
        case .female:
            switch age {
            case 18..<30: baseValue = 1400
            case 30..<50: baseValue = 1350
            case 50..<70: baseValue = 1250
            default: baseValue = 1150
            }
        }
        
        return baseValue
    }
}

enum BMRCategory: CaseIterable {
    case veryLow, low, normal, high, veryHigh
    
    var description: String {
        switch self {
        case .veryLow: return "非常に低い"
        case .low: return "低い"
        case .normal: return "標準"
        case .high: return "高い"
        case .veryHigh: return "非常に高い"
        }
    }
    
    var advice: String {
        switch self {
        case .veryLow: return "筋力トレーニングで筋肉量を増やすことをお勧めします"
        case .low: return "適度な運動で基礎代謝を向上させましょう"
        case .normal: return "現在の状態を維持しましょう"
        case .high: return "良好な基礎代謝です"
        case .veryHigh: return "非常に良好な基礎代謝です"
        }
    }
}

//
//  CalorieCalculationService.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

class CalorieCalculationService {
    
    static let shared = CalorieCalculationService()
    private init() {}
    
    // MARK: - Exercise Calorie Calculation
    
    func calculateExerciseCalories(
        exerciseName: String,
        weight: Double,
        duration: TimeInterval, // 秒
        intensity: ExerciseIntensity = .medium
    ) -> Double {
        let metValue = (AppConstants.Calories.metValues[exerciseName] ?? AppConstants.Calories.defaultMET) * intensity.multiplier
        let durationHours = duration / 3600.0
        return metValue * weight * durationHours
    }
    
    func calculateExerciseCaloriesFromSetsReps(
        exerciseName: String,
        weight: Double,
        sets: Int,
        reps: Int,
        restTime: TimeInterval = 60 // 秒
    ) -> Double {
        let workTime = Double(sets * reps) * 3.0 // 1repあたり3秒と仮定
        let totalRestTime = Double(sets - 1) * restTime
        let totalDuration = workTime + totalRestTime
        
        return calculateExerciseCalories(
            exerciseName: exerciseName,
            weight: weight,
            duration: totalDuration
        )
    }
    
    // MARK: - Daily Calorie Goals
    
    func calculateDailyCalorieGoal(
        bmr: Double,
        activityLevel: ActivityLevel,
        goal: CalorieGoal
    ) -> Double {
        let tdee = bmr * activityLevel.multiplier
        
        switch goal {
        case .maintain:
            return tdee
        case .lose(let kgPerWeek):
            let dailyDeficit = (kgPerWeek * 7700) / 7 // 1kg = 7700kcal
            return tdee - dailyDeficit
        case .gain(let kgPerWeek):
            let dailySurplus = (kgPerWeek * 7700) / 7
            return tdee + dailySurplus
        }
    }
    
    // MARK: - Macronutrient Distribution
    
    func calculateMacronutrients(
        totalCalories: Double,
        goal: CalorieGoal,
        dietType: DietType = .balanced
    ) -> MacronutrientDistribution {
        let ratios = dietType.macroRatios(for: goal)
        
        return MacronutrientDistribution(
            calories: totalCalories,
            proteinGrams: (totalCalories * ratios.protein) / 4, // 1g protein = 4kcal
            carbGrams: (totalCalories * ratios.carbs) / 4, // 1g carbs = 4kcal
            fatGrams: (totalCalories * ratios.fat) / 9 // 1g fat = 9kcal
        )
    }
    
    // MARK: - Meal Planning
    
    func distributeMealsCalories(
        totalCalories: Double,
        mealTypes: [MealType]
    ) -> [MealType: Double] {
        var distribution: [MealType: Double] = [:]
        
        for mealType in mealTypes {
            distribution[mealType] = totalCalories * mealType.recommendedCalorieRatio
        }
        
        return distribution
    }
    
    // MARK: - Calorie Burn Estimates
    
    func estimateCalorieBurn(
        for activity: DailyActivity,
        weight: Double,
        duration: TimeInterval
    ) -> Double {
        let metValue = activity.metValue
        let durationHours = duration / 3600.0
        return metValue * weight * durationHours
    }
}

// MARK: - Supporting Types

enum CalorieGoal {
    case maintain
    case lose(kgPerWeek: Double)
    case gain(kgPerWeek: Double)
    
    var description: String {
        switch self {
        case .maintain:
            return "体重維持"
        case .lose(let kg):
            return "週\(kg.formatted(decimalPlaces: 1))kg減量"
        case .gain(let kg):
            return "週\(kg.formatted(decimalPlaces: 1))kg増量"
        }
    }
}

enum DietType {
    case balanced
    case lowCarb
    case highProtein
    case keto
    
    func macroRatios(for goal: CalorieGoal) -> (protein: Double, carbs: Double, fat: Double) {
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

enum DailyActivity {
    case sleeping
    case sitting
    case standing
    case walking
    case climbing
    case housework
    case cooking
    case reading
    case driving
    
    var metValue: Double {
        switch self {
        case .sleeping: return 0.9
        case .sitting: return 1.3
        case .standing: return 1.8
        case .walking: return 3.5
        case .climbing: return 8.0
        case .housework: return 3.0
        case .cooking: return 2.5
        case .reading: return 1.3
        case .driving: return 2.0
        }
    }
}

//
//  ValidationService.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

protocol ValidationServiceProtocol {
    func validateBodyComposition(_ dto: BodyCompositionDTO) -> ValidationResult
    func validateWorkout(_ dto: WorkoutDTO) -> ValidationResult
    func validateFood(_ dto: FoodDTO) -> ValidationResult
}

class ValidationService: ValidationServiceProtocol {
    
    static let shared = ValidationService()
    private init() {}
    
    // MARK: - Body Composition Validation
    func validateBodyComposition(_ dto: BodyCompositionDTO) -> ValidationResult {
        var errors: [String] = []
        
        if !dto.height.isValidHeight() {
            errors.append(ErrorMessages.Validation.heightInvalid)
        }
        
        if !dto.weight.isValidWeight() {
            errors.append(ErrorMessages.Validation.weightInvalid)
        }
        
        if dto.bodyFatPercentage > 0 && !dto.bodyFatPercentage.isValidBodyFat() {
            errors.append(ErrorMessages.Validation.bodyFatInvalid)
        }
        
        if dto.basalMetabolicRate < 800 || dto.basalMetabolicRate > 4000 {
            errors.append("基礎代謝量は800〜4000kcalの範囲で入力してください")
        }
        
        return errors.isEmpty ? .success : .failure(errors)
    }
    
    // MARK: - Workout Validation
    func validateWorkout(_ dto: WorkoutDTO) -> ValidationResult {
        var errors: [String] = []
        
        let trimmedName = dto.exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errors.append(ErrorMessages.Validation.exerciseNameEmpty)
        }
        
        if trimmedName.count > AppConstants.Validation.maxExerciseNameLength {
            errors.append(ErrorMessages.Validation.exerciseNameTooLong)
        }
        
        if !isValidExerciseName(trimmedName) {
            errors.append(ErrorMessages.Validation.invalidCharacters)
        }
        
        if dto.weight < 0 || dto.weight > 1000 {
            errors.append("重量は0〜1000kgの範囲で入力してください")
        }
        
        if dto.sets < 1 || dto.sets > 100 {
            errors.append("セット数は1〜100の範囲で入力してください")
        }
        
        if dto.reps < 1 || dto.reps > 1000 {
            errors.append("回数は1〜1000の範囲で入力してください")
        }
        
        if let memo = dto.memo, memo.count > AppConstants.Validation.maxMemoLength {
            errors.append("メモは\(AppConstants.Validation.maxMemoLength)文字以内で入力してください")
        }
        
        return errors.isEmpty ? .success : .failure(errors)
    }
    
    // MARK: - Food Validation
    func validateFood(_ dto: FoodDTO) -> ValidationResult {
        var errors: [String] = []
        
        let trimmedName = dto.foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errors.append(ErrorMessages.Validation.foodNameEmpty)
        }
        
        if trimmedName.count > AppConstants.Validation.maxFoodNameLength {
            errors.append(ErrorMessages.Validation.foodNameTooLong)
        }
        
        if !dto.calories.isValidCalories() {
            errors.append(ErrorMessages.Validation.caloriesInvalid)
        }
        
        return errors.isEmpty ? .success : .failure(errors)
    }
    
    // MARK: - Helper Methods
    private func isValidExerciseName(_ name: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゃゅょっァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモヤユヨラリルレロワヲンヴー・（）()【】[]、。・")
        
        return name.rangeOfCharacter(from: allowedCharacters.inverted) == nil
    }
} - BMI Calculation
    func calculateBMI(weight: Double, height: Double) -> Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    // MARK: - Ideal Weight Calculation
    func calculateIdealWeight(height: Double) -> Double {
        let heightInMeters = height / 100.0
        return AppConstants.Calories.idealBMI * heightInMeters * heightInMeters
    }
    
    // MARK: - BMR Calculation (Harris-Benedict Formula)
    func calculateBMR(weight: Double, height: Double, age: Int, gender: Gender) -> Double {
        let constants = gender.bmrConstant
        return constants.base + (constants.weight * weight) + (constants.height * height) - (constants.age * Double(age))
    }
    
    // MARK: - TDEE Calculation
    func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        return bmr * activityLevel.multiplier
    }
    
    // MARK: - Workout Calories Calculation
    func calculateWorkoutCalories(exerciseName: String, weight: Double, sets: Int, reps: Int) -> Double {
        let metValue = AppConstants.Calories.metValues[exerciseName] ?? AppConstants.Calories.defaultMET
        let estimatedDurationHours = Double(sets * reps) / 60.0 // 1分あたり1回と仮定
        return metValue * weight * estimatedDurationHours
    }
    
    // MARK: - Steps Calories Calculation
    func calculateStepsCalories(steps: Int, bodyWeight: Double) -> Double {
        return Double(steps) * bodyWeight * AppConstants.Calories.stepsCalorieMultiplier
    }
}

//
//  BMRCalculationService.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

class BMRCalculationService {
    
    static let shared = BMRCalculationService()
    private init() {}
    
    // MARK:
