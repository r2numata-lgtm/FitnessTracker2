//
//  FoodEntry+CoreData.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/27.
//
import Foundation
import CoreData
import UIKit

@objc(FoodEntry)
public class FoodEntry: NSManagedObject {

}

extension FoodEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodEntry> {
        return NSFetchRequest<FoodEntry>(entityName: "FoodEntry")
    }

    @NSManaged public var date: Date
    @NSManaged public var foodName: String?
    @NSManaged public var calories: Double
    @NSManaged public var mealType: String?
    @NSManaged public var photo: Data?

}

extension FoodEntry : Identifiable {

}

// MARK: - Computed Properties
extension FoodEntry {
    
    var formattedDate: String {
        return date.formatted(style: .medium)
    }
    
    var formattedTime: String {
        return date.timeFormatted()
    }
    
    var formattedCalories: String {
        return calories.formattedAsInteger() + "kcal"
    }
    
    var safeFoodName: String {
        return foodName ?? "不明な食べ物"
    }
    
    var safeMealType: String {
        return mealType ?? "その他"
    }
    
    var mealTypeEnum: MealType {
        return MealType(rawValue: safeMealType) ?? .snack
    }
    
    var hasPhoto: Bool {
        return photo != nil
    }
    
    var photoImage: UIImage? {
        guard let photoData = photo else { return nil }
        return UIImage(data: photoData)
    }
    
    var isToday: Bool {
        return date.isToday()
    }
    
    var relativeDateString: String {
        return date.relativeDateString()
    }
}

// MARK: - Validation
extension FoodEntry {
    
    func validate() -> ValidationResult {
        var errors: [String] = []
        
        if safeFoodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(ErrorMessages.Validation.foodNameEmpty)
        }
        
        if safeFoodName.count > AppConstants.Validation.maxFoodNameLength {
            errors.append(ErrorMessages.Validation.foodNameTooLong)
        }
        
        if !calories.isValidCalories() {
            errors.append(ErrorMessages.Validation.caloriesInvalid)
        }
        
        if errors.isEmpty {
            return .success
        } else {
            return .failure(errors)
        }
    }
}

// MARK: - Helper Methods
extension FoodEntry {
    
    func setPhoto(_ image: UIImage, compressionQuality: CGFloat = 0.8) {
        photo = image.jpegData(compressionQuality: compressionQuality)
    }
    
    func clearPhoto() {
        photo = nil
    }
    
    static func createSample(context: NSManagedObjectContext) -> FoodEntry {
        let food = FoodEntry(context: context)
        food.date = Date()
        food.foodName = "サンプル食品"
        food.calories = 200
        food.mealType = MealType.lunch.rawValue
        return food
    }
}
