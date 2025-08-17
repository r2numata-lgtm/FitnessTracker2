//
//  WorkoutEntry+CoreData.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/27.
//
import Foundation
import CoreData
import UIKit

@objc(WorkoutEntry)
public class WorkoutEntry: NSManagedObject {

}

extension WorkoutEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutEntry> {
        return NSFetchRequest<WorkoutEntry>(entityName: "WorkoutEntry")
    }

    @NSManaged public var date: Date
    @NSManaged public var exerciseName: String?
    @NSManaged public var weight: Double
    @NSManaged public var sets: Int16
    @NSManaged public var reps: Int16
    @NSManaged public var caloriesBurned: Double
    @NSManaged public var photo: Data?
    @NSManaged public var memo: String?

}

extension WorkoutEntry : Identifiable {

}

// MARK: - Computed Properties
extension WorkoutEntry {
    
    var formattedDate: String {
        return date.formatted(style: .medium)
    }
    
    var formattedTime: String {
        return date.timeFormatted()
    }
    
    var formattedWeight: String {
        return weight.formatted(decimalPlaces: 1) + "kg"
    }
    
    var formattedReps: String {
        return "\(reps)回"
    }
    
    var formattedSets: String {
        return "\(sets)セット"
    }
    
    var formattedCalories: String {
        return caloriesBurned.formattedAsInteger() + "kcal"
    }
    
    var safeExerciseName: String {
        return exerciseName ?? "不明な運動"
    }
    
    var safeMemo: String {
        return memo ?? ""
    }
    
    var hasPhoto: Bool {
        return photo != nil
    }
    
    var hasMemo: Bool {
        return !safeMemo.isEmpty
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
    
    var exerciseCategory: String {
        for (category, exercises) in AppConstants.Exercise.defaultExercises {
            if exercises.contains(safeExerciseName) {
                return category
            }
        }
        return "その他"
    }
    
    var intensity: ExerciseIntensity {
        let totalReps = Int(sets) * Int(reps)
        
        if weight >= 80 && totalReps >= 30 {
            return .high
        } else if weight >= 50 && totalReps >= 20 {
            return .medium
        } else {
            return .low
        }
    }
    
    var totalVolume: Double {
        return weight * Double(sets) * Double(reps)
    }
}

// MARK: - Validation
extension WorkoutEntry {
    
    func validate() -> ValidationResult {
        var errors: [String] = []
        
        if safeExerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(ErrorMessages.Validation.exerciseNameEmpty)
        }
        
        if safeExerciseName.count > AppConstants.Validation.maxExerciseNameLength {
            errors.append(ErrorMessages.Validation.exerciseNameTooLong)
        }
        
        if weight < 0 || weight > 1000 {
            errors.append("重量は0kg〜1000kgの範囲で入力してください")
        }
        
        if sets < 1 || sets > 100 {
            errors.append("セット数は1〜100の範囲で入力してください")
        }
        
        if reps < 1 || reps > 1000 {
            errors.append("回数は1〜1000の範囲で入力してください")
        }
        
        if memo != nil && memo!.count > AppConstants.Validation.maxMemoLength {
            errors.append("メモは100文字以内で入力してください")
        }
        
        if errors.isEmpty {
            return .success
        } else {
            return .failure(errors)
        }
    }
}

// MARK: - Helper Methods
extension WorkoutEntry {
    
    func setPhoto(_ image: UIImage, compressionQuality: CGFloat = 0.8) {
        photo = image.jpegData(compressionQuality: compressionQuality)
    }
    
    func clearPhoto() {
        photo = nil
    }
    
    func calculateCalories(bodyWeight: Double = AppConstants.Calories.defaultBodyWeight) {
        let metValue = AppConstants.Calories.metValues[safeExerciseName] ?? AppConstants.Calories.defaultMET
        let estimatedDurationHours = Double(sets * reps) / 60.0 // 1分あたり1回と仮定
        caloriesBurned = metValue * bodyWeight * estimatedDurationHours
    }
    
    static func createSample(context: NSManagedObjectContext) -> WorkoutEntry {
        let workout = WorkoutEntry(context: context)
        workout.date = Date()
        workout.exerciseName = "ベンチプレス"
        workout.weight = 80
        workout.sets = 3
        workout.reps = 10
        workout.caloriesBurned = 150
        return workout
    }
    
    func copyToNewSet() -> WorkoutEntry? {
        guard let context = managedObjectContext else { return nil }
        
        let newWorkout = WorkoutEntry(context: context)
        newWorkout.date = date
        newWorkout.exerciseName = exerciseName
        newWorkout.weight = weight
        newWorkout.sets = 1
        newWorkout.reps = reps
        newWorkout.caloriesBurned = caloriesBurned / Double(sets) // 1セット分のカロリー
        newWorkout.memo = memo
        newWorkout.photo = photo
        
        return newWorkout
    }
}
