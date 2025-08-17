//
//  Gender.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
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
