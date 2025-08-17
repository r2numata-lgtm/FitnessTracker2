//
//  DataServiceProtocol.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import Foundation
import CoreData

protocol DataServiceProtocol {
    associatedtype Entity: NSManagedObject
    
    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Entity]
    func fetchFirst(predicate: NSPredicate?) -> Entity?
    func create() -> Entity
    func save() throws
    func delete(_ entity: Entity) throws
    func deleteAll(predicate: NSPredicate?) throws
    func count(predicate: NSPredicate?) -> Int
}

protocol WorkoutDataServiceProtocol: DataServiceProtocol where Entity == WorkoutEntry {
    func fetchWorkoutsForDate(_ date: Date) -> [WorkoutEntry]
    func fetchWorkoutsByExercise(_ exerciseName: String, limit: Int?) -> [WorkoutEntry]
    func fetchGroupedWorkoutsForDate(_ date: Date) -> [String: [WorkoutEntry]]
    func getTotalCaloriesForDate(_ date: Date) -> Double
    func deleteWorkoutsForExercise(_ exerciseName: String, on date: Date) throws
}

protocol FoodDataServiceProtocol: DataServiceProtocol where Entity == FoodEntry {
    func fetchFoodsForDate(_ date: Date) -> [FoodEntry]
    func fetchFoodsByMealType(_ mealType: MealType, date: Date) -> [FoodEntry]
    func fetchGroupedFoodsForDate(_ date: Date) -> [String: [FoodEntry]]
    func getTotalCaloriesForDate(_ date: Date) -> Double
}

protocol BodyCompositionDataServiceProtocol: DataServiceProtocol where Entity == BodyComposition {
    func fetchLatestEntry() -> BodyComposition?
    func fetchWeightHistory(limit: Int) -> [BodyComposition]
    func fetchEntryForDate(_ date: Date) -> BodyComposition?
}
