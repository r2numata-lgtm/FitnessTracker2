//
//  Double+Extensions.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

extension Double {
    
    // MARK: - Rounding
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func roundedToInt() -> Int {
        return Int(self.rounded())
    }
    
    // MARK: - Formatting
    func formatted(decimalPlaces: Int = 1) -> String {
        return String(format: "%.\(decimalPlaces)f", self)
    }
    
    func formattedAsInteger() -> String {
        return String(Int(self))
    }
    
    func formattedWithComma() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
    
    // MARK: - Unit Conversion
    func kilogramsToGrams() -> Double {
        return self * 1000
    }
    
    func gramsToKilograms() -> Double {
        return self / 1000
    }
    
    func metersTocentimeters() -> Double {
        return self * 100
    }
    
    func centimetersToMeters() -> Double {
        return self / 100
    }
    
    func poundsToKilograms() -> Double {
        return self * 0.453592
    }
    
    func kilogramsToPounds() -> Double {
        return self / 0.453592
    }
    
    func feetTocentimeters() -> Double {
        return self * 30.48
    }
    
    func centimetersToFeet() -> Double {
        return self / 30.48
    }
    
    // MARK: - Health Calculations
    func calculateBMI(height: Double) -> Double {
        let heightInMeters = height / 100.0
        return self / (heightInMeters * heightInMeters)
    }
    
    func calculateIdealWeight(height: Double) -> Double {
        let heightInMeters = height / 100.0
        return 22.0 * heightInMeters * heightInMeters
    }
    
    // MARK: - Calorie Calculations
    func caloriesFromSteps(bodyWeight: Double = AppConstants.Calories.defaultBodyWeight) -> Double {
        return self * bodyWeight * AppConstants.Calories.stepsCalorieMultiplier
    }
    
    func calculateWorkoutCalories(exerciseName: String, bodyWeight: Double, duration: Double) -> Double {
        let metValue = AppConstants.Calories.metValues[exerciseName] ?? AppConstants.Calories.defaultMET
        return metValue * bodyWeight * duration
    }
    
    // MARK: - Validation
    func isValidHeight() -> Bool {
        return self >= AppConstants.Validation.minHeight && self <= AppConstants.Validation.maxHeight
    }
    
    func isValidWeight() -> Bool {
        return self >= AppConstants.Validation.minWeight && self <= AppConstants.Validation.maxWeight
    }
    
    func isValidBodyFat() -> Bool {
        return self >= 0 && self <= 50
    }
    
    func isValidCalories() -> Bool {
        return self > 0 && self <= 10000
    }
    
    // MARK: - Percentage
    func asPercentage(of total: Double) -> Double {
        guard total > 0 else { return 0 }
        return (self / total) * 100
    }
    
    func fromPercentage(of total: Double) -> Double {
        return (self / 100) * total
    }
    
    // MARK: - Range Checking
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
    
    func isWithin(_ range: ClosedRange<Double>) -> Bool {
        return range.contains(self)
    }
    
    // MARK: - Comparison
    func isApproximately(_ other: Double, tolerance: Double = 0.001) -> Bool {
        return abs(self - other) < tolerance
    }
    
    func isZero(tolerance: Double = 0.001) -> Bool {
        return abs(self) < tolerance
    }
}
