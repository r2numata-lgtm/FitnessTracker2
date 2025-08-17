//
//  BMICategory.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation
import SwiftUI

enum BMICategory: CaseIterable {
    case underweight
    case normal
    case overweight
    case obese
    
    static func from(bmi: Double) -> BMICategory {
        switch bmi {
        case ..<18.5:
            return .underweight
        case 18.5..<25:
            return .normal
        case 25..<30:
            return .overweight
        default:
            return .obese
        }
    }
    
    var description: String {
        switch self {
        case .underweight:
            return "低体重"
        case .normal:
            return "普通体重"
        case .overweight:
            return "肥満（1度）"
        case .obese:
            return "肥満（2度以上）"
        }
    }
    
    var color: Color {
        switch self {
        case .underweight:
            return .blue
        case .normal:
            return .green
        case .overweight:
            return .orange
        case .obese:
            return .red
        }
    }
    
    var range: String {
        switch self {
        case .underweight:
            return "18.5未満"
        case .normal:
            return "18.5〜25未満"
        case .overweight:
            return "25〜30未満"
        case .obese:
            return "30以上"
        }
    }
    
    var advice: String {
        switch self {
        case .underweight:
            return "適度な筋力トレーニングと栄養バランスの良い食事を心がけましょう"
        case .normal:
            return "理想的な体重です。現在の生活習慣を維持しましょう"
        case .overweight:
            return "食事量の調整と有酸素運動を取り入れることをお勧めします"
        case .obese:
            return "医師と相談して適切な減量計画を立てることをお勧めします"
        }
    }
}

//
//  ExerciseIntensity.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation
import SwiftUI

enum ExerciseIntensity: CaseIterable {
    case low
    case medium
    case high
    
    var description: String {
        switch self {
        case .low:
            return "軽度"
        case .medium:
            return "中度"
        case .high:
            return "高度"
        }
    }
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
    
    var multiplier: Double {
        switch self {
        case .low:
            return 1.0
        case .medium:
            return 1.3
        case .high:
            return 1.6
        }
    }
    
    var heartRateZone: String {
        switch self {
        case .low:
            return "50-60% HRmax"
        case .medium:
            return "60-70% HRmax"
        case .high:
            return "70-85% HRmax"
        }
    }
}

//
//  Gender.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

enum Gender: String, CaseIterable {
    case male = "male"
    case female = "female"
    
    var displayName: String {
        switch self {
        case .male:
            return "男性"
        case .female:
            return "女性"
        }
    }
    
    var bmrConstant: BMRConstant {
        switch self {
        case .male:
            return BMRConstant(base: 88.362, weight: 13.397, height: 4.799, age: 5.677)
        case .female:
            return BMRConstant(base: 447.593, weight: 9.247, height: 3.098, age: 4.330)
        }
    }
}

struct BMRConstant {
    let base: Double
    let weight: Double
    let height: Double
    let age: Double
}

//
//  ActivityLevel.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

enum ActivityLevel: CaseIterable {
    case sedentary
    case light
    case moderate
    case active
    case veryActive
    
    var displayName: String {
        switch self {
        case .sedentary:
            return "座り仕事中心"
        case .light:
            return "軽い運動"
        case .moderate:
            return "適度な運動"
        case .active:
            return "活発"
        case .veryActive:
            return "非常に活発"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .sedentary:
            return 1.2
        case .light:
            return 1.375
        case .moderate:
            return 1.55
        case .active:
            return 1.725
        case .veryActive:
            return 1.9
        }
    }
    
    var description: String {
        switch self {
        case .sedentary:
            return "ほとんど運動しない、デスクワーク中心"
        case .light:
            return "週1-3回の軽い運動"
        case .moderate:
            return "週3-5回の適度な運動"
        case .active:
            return "週6-7回の激しい運動"
        case .veryActive:
            return "1日2回の運動、肉体労働"
        }
    }
}

//
//  MealType.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation
import SwiftUI

enum MealType: String, CaseIterable {
    case breakfast = "朝食"
    case lunch = "昼食"
    case dinner = "夕食"
    case snack = "間食"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .breakfast:
            return "sun.rise.fill"
        case .lunch:
            return "sun.max.fill"
        case .dinner:
            return "moon.fill"
        case .snack:
            return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .breakfast:
            return .orange
        case .lunch:
            return .yellow
        case .dinner:
            return .purple
        case .snack:
            return .pink
        }
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
    
    var sortOrder: Int {
        switch self {
        case .breakfast:
            return 0
        case .lunch:
            return 1
        case .dinner:
            return 2
        case .snack:
            return 3
        }
    }
}

//
//  ValidationResult.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

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
    
    var firstErrorMessage: String? {
        return errorMessages.first
    }
}
