//
//  BodyComposition+CoreData.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/27.
//
import Foundation
import CoreData

@objc(BodyComposition)
public class BodyComposition: NSManagedObject {

}

extension BodyComposition {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BodyComposition> {
        return NSFetchRequest<BodyComposition>(entityName: "BodyComposition")
    }

    @NSManaged public var date: Date
    @NSManaged public var height: Double
    @NSManaged public var weight: Double
    @NSManaged public var bodyFatPercentage: Double
    @NSManaged public var basalMetabolicRate: Double

}

extension BodyComposition : Identifiable {

}

// MARK: - Computed Properties
extension BodyComposition {
    
    var bmi: Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    var idealWeight: Double {
        let heightInMeters = height / 100.0
        return 22.0 * heightInMeters * heightInMeters
    }
    
    var bmiCategory: BMICategory {
        return BMICategory.from(bmi: bmi)
    }
    
    var tdee: Double {
        return basalMetabolicRate * 1.6 // Moderate activity level
    }
    
    var formattedDate: String {
        return date.formatted(style: .medium)
    }
    
    var formattedWeight: String {
        return weight.formatted(decimalPlaces: 1) + "kg"
    }
    
    var formattedHeight: String {
        return height.formattedAsInteger() + "cm"
    }
    
    var formattedBMI: String {
        return bmi.formatted(decimalPlaces: 1)
    }
    
    var formattedBodyFat: String {
        return bodyFatPercentage.formatted(decimalPlaces: 1) + "%"
    }
    
    var formattedBMR: String {
        return basalMetabolicRate.formattedAsInteger() + "kcal"
    }
}

// MARK: - Validation
extension BodyComposition {
    
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
        
        if errors.isEmpty {
            return .success
        } else {
            return .failure(errors)
        }
    }
}
