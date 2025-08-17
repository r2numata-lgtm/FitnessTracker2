//
//  BodyCompositionDTO.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import Foundation

struct BodyCompositionDTO {
    let date: Date
    let height: Double
    let weight: Double
    let bodyFatPercentage: Double
    let basalMetabolicRate: Double
    
    init(date: Date = Date(), height: Double, weight: Double, bodyFatPercentage: Double = 0, basalMetabolicRate: Double) {
        self.date = date
        self.height = height
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.basalMetabolicRate = basalMetabolicRate
    }
    
    // MARK: - Validation
    func validate() -> ValidationResult {
        var errors: [String] = []
        
        if !height.isValidHeight() {
            errors.append(ErrorMessages.Validation.heightInvalid)
        }
        
        if !weight.isValidWeight() {
            errors.append(ErrorMessages.Validation.weightInvalid)
        }
        
        if bodyFatPercentage > 0 && !bodyFatPercentage.isValidBodyFat() {
            errors.append(ErrorMessages.Validation.bodyFatInvalid)
        }
        
        if basalMetabolicRate < 800 || basalMetabolicRate > 4000 {
            errors.append("基礎代謝量は800〜4000kcalの範囲で入力してください")
        }
        
        return errors.isEmpty ? .success : .failure(errors)
    }
}
