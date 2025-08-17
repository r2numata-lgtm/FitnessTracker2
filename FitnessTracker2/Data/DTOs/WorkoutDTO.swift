//
//  WorkoutDTO.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import Foundation

struct WorkoutDTO {
    let date: Date
    let exerciseName: String
    let weight: Double
    let sets: Int
    let reps: Int
    let memo: String?
    let photoData: Data?
    let bodyWeight: Double?
    
    init(date: Date = Date(), exerciseName: String, weight: Double, sets: Int, reps: Int, memo: String? = nil, photoData: Data? = nil, bodyWeight: Double? = nil) {
        self.date = date
        self.exerciseName = exerciseName
        self.weight = weight
        self.sets = sets
        self.reps = reps
        self.memo = memo
        self.photoData = photoData
        self.bodyWeight = bodyWeight
    }
    
    // MARK: - Validation
    func validate() -> ValidationResult {
        var errors: [String] = []
        
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            errors.append(ErrorMessages.Validation.exerciseNameEmpty)
        }
        
        if trimmedName.count > AppConstants.Validation.maxExerciseNameLength {
            errors.append(ErrorMessages.Validation.exerciseNameTooLong)
        }
        
        if weight < 0 || weight > 1000 {
            errors.append("重量は0〜1000kgの範囲で入力してください")
        }
        
        if sets < 1 || sets > 100 {
            errors.append("セット数は1〜100の範囲で入力してください")
        }
        
        if reps < 1 || reps > 1000 {
            errors.append("回数は1〜1000の範囲で入力してください")
        }
        
        if let memo = memo, memo.count > AppConstants.Validation.maxMemoLength {
            errors.append("メモは\(AppConstants.Validation.maxMemoLength)文字以内で入力してください")
        }
        
        return errors.isEmpty ? .success : .failure(errors)
    }
}
