//
//  BMRCalculationService.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
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
