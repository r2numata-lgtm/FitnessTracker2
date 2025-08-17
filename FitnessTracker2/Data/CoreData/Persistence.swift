//
//  Persistence.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // プレビュー用のサンプルデータ
        let sampleWorkout = WorkoutEntry(context: viewContext)
        sampleWorkout.date = Date()
        sampleWorkout.exerciseName = "ベンチプレス"
        sampleWorkout.weight = 80
        sampleWorkout.sets = 3
        sampleWorkout.reps = 10
        sampleWorkout.caloriesBurned = 150
        
        let sampleFood = FoodEntry(context: viewContext)
        sampleFood.date = Date()
        sampleFood.foodName = "鶏胸肉"
        sampleFood.calories = 200
        sampleFood.mealType = "昼食"
        
        let sampleBody = BodyComposition(context: viewContext)
        sampleBody.date = Date()
        sampleBody.height = 175
        sampleBody.weight = 70
        sampleBody.bodyFatPercentage = 15
        sampleBody.basalMetabolicRate = 1800
        
        let sampleCalories = DailyCalories(context: viewContext)
        sampleCalories.date = Date()
        sampleCalories.totalIntake = 2000
        sampleCalories.totalBurned = 500
        sampleCalories.netCalories = 1500
        sampleCalories.steps = 8000
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FitnessTracker")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Core Data設定
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber,
                                                              forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber,
                                                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // 本番環境では適切なエラーハンドリングを実装
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data保存エラー: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Background Context
    func backgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Batch Operations
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            block(context)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Background context保存エラー: \(error)")
                }
            }
        }
    }
    
    // MARK: - Data Migration
    func migrateIfNeeded() {
        // 将来のデータマイグレーション用
    }
    
    // MARK: - Cleanup
    func cleanupOldData(olderThan days: Int = 365) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        performBackgroundTask { context in
            // 古いワークアウトデータを削除
            let workoutRequest: NSFetchRequest<WorkoutEntry> = WorkoutEntry.fetchRequest()
            workoutRequest.predicate = NSPredicate(format: "date < %@", cutoffDate as NSDate)
            
            if let oldWorkouts = try? context.fetch(workoutRequest) {
                oldWorkouts.forEach { context.delete($0) }
            }
            
            // 古い食事データを削除
            let foodRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
            foodRequest.predicate = NSPredicate(format: "date < %@", cutoffDate as NSDate)
            
            if let oldFoods = try? context.fetch(foodRequest) {
                oldFoods.forEach { context.delete($0) }
            }
            
            // 古いカロリーデータを削除
            let calorieRequest: NSFetchRequest<DailyCalories> = DailyCalories.fetchRequest()
            calorieRequest.predicate = NSPredicate(format: "date < %@", cutoffDate as NSDate)
            
            if let oldCalories = try? context.fetch(calorieRequest) {
                oldCalories.forEach { context.delete($0) }
            }
        }
    }
}
