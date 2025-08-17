//
//  DailyCalories+CoreData.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/27.
//
import Foundation
import CoreData

@objc(DailyCalories)
public class DailyCalories: NSManagedObject {

}

extension DailyCalories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyCalories> {
        return NSFetchRequest<DailyCalories>(entityName: "DailyCalories")
    }

    @NSManaged public var date: Date
    @NSManaged public var totalIntake: Double
    @NSManaged public var totalBurned: Double
    @NSManaged public var netCalories: Double
    @NSManaged public var steps: Int32

}

extension DailyCalories : Identifiable {

}

// MARK: - Computed Properties
extension DailyCalories {
    
    var formattedDate: String {
        return date.formatted(style: .medium)
    }
    
    var formattedTotalIntake: String {
        return totalIntake.formattedAsInteger() + "kcal"
    }
    
    var formattedTotalBurned: String {
        return totalBurned.formattedAsInteger() + "kcal"
    }
    
    var formattedNetCalories: String {
        let sign = netCalories >= 0 ? "+" : ""
        return sign + netCalories.formattedAsInteger() + "kcal"
    }
    
    var formattedSteps: String {
        return Int(steps).formatted() + "歩"
    }
    
    var calorieBalance: CalorieBalance {
        if netCalories > 500 {
            return .surplus
        } else if netCalories < -500 {
            return .deficit
        } else {
            return .balanced
        }
    }
    
    var stepsCalories: Double {
        return Double(steps).caloriesFromSteps()
    }
    
    var isToday: Bool {
        return date.isToday()
    }
}

// MARK: - Helper Methods
extension DailyCalories {
    
    func updateNetCalories() {
        netCalories = totalIntake - totalBurned
    }
    
    func addIntakeCalories(_ calories: Double) {
        totalIntake += calories
        updateNetCalories()
    }
    
    func addBurnedCalories(_ calories: Double) {
        totalBurned += calories
        updateNetCalories()
    }
    
    func updateSteps(_ newSteps: Int32) {
        steps = newSteps
    }
    
    func reset() {
        totalIntake = 0
        totalBurned = 0
        netCalories = 0
        steps = 0
    }
}

// MARK: - Enums
enum CalorieBalance {
    case surplus
    case deficit
    case balanced
    
    var description: String {
        switch self {
        case .surplus:
            return "カロリー過多"
        case .deficit:
            return "カロリー不足"
        case .balanced:
            return "バランス良好"
        }
    }
    
    var color: UIConstants.Colors {
        switch self {
        case .surplus:
            return UIConstants.Colors.error
        case .deficit:
            return UIConstants.Colors.warning
        case .balanced:
            return UIConstants.Colors.success
        }
    }
}
}
