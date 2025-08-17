//
//  FoodDTO.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import Foundation

struct FoodDTO {
    let date: Date
    let foodName: String
    let calories: Double
    let mealType: MealType
    let photoData: Data?
    
    init(date: Date = Date(), foodName: String, calories: Double, mealType: MealType, photoData: Data? = nil) {
        self.date = date
        self.foodName = foodName
        self.calories = calories
        self.mealType = mealType
        self.photoData = photoData
    }
    
    // MARK: - Validation
    func validate() -> ValidationResult {
        var errors: [String] = []
        
        let trimmedName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errors.append(ErrorMessages.Validation.foodNameEmpty)
        }
        
        if trimmedName.count > AppConstants.Validation.maxFoodNameLength {
            errors.append(ErrorMessages.Validation.foodNameTooLong)
        }
        
        if !calories.isValidCalories() {
            errors.append(ErrorMessages.Validation.caloriesInvalid)
        }
        
        return errors.isEmpty ? .success : .failure(errors)
    }
}

// MARK: - MealType enum (既にBMICategory.swiftにあるが、再定義)
enum MealType: String, CaseIterable {
    case breakfast = "朝食"
    case lunch = "昼食"
    case dinner = "夕食"
    case snack = "間食"
    
    var displayName: String {
        return self.rawValue
    }
    
    var recommendedCalorieRatio: Double {
        switch self {
        case .breakfast:
            return 0.25 // 25%
        case .lunch:
            return 0.35 // 35%
        case .dinner:
            return 0.30 // 30%
        case .snack:
            return 0.10 // 10%
        }
    }
}
