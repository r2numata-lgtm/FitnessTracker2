//
//  ValidationService.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
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
}
