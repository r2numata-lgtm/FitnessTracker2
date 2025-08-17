//
//  ExerciseIntensity.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
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
