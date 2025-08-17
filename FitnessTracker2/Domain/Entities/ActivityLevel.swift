//
//  ActivityLevel.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
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
