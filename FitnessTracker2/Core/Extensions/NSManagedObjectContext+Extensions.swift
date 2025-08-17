//
//  NSManagedObjectContext+Extensions.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import CoreData
import Foundation

extension NSManagedObjectContext {
    
    // MARK: - Save Context
    func saveIfNeeded() {
        guard hasChanges else { return }
        
        do {
            try save()
        } catch {
            print("Core Data保存エラー: \(error.localizedDescription)")
        }
    }
    
    func saveWithErrorHandling() throws {
        guard hasChanges else { return }
        try save()
    }
    
    // MARK: - Fetch Helpers
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            return try fetch(request)
        } catch {
            print("Core Data取得エラー: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchFirst<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> T? {
        request.fetchLimit = 1
        return fetch(request).first
    }
    
    func count<T: NSManagedObject>(for request: NSFetchRequest<T>) -> Int {
        do {
            return try count(for: request)
        } catch {
            print("Core Dataカウントエラー: \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - Delete Helpers
    func deleteAll<T: NSManagedObject>(_ entityType: T.Type) {
        let request = NSFetchRequest<T>(entityName: String(describing: entityType))
        let objects = fetch(request)
        
        objects.forEach { delete($0) }
        saveIfNeeded()
    }
    
    func deleteObjects<T: NSManagedObject>(_ objects: [T]) {
        objects.forEach { delete($0) }
        saveIfNeeded()
    }
    
    // MARK: - Batch Operations
    func performAndSave(_ block: () throws -> Void) throws {
        try block()
        try saveWithErrorHandling()
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = self
        
        backgroundContext.perform {
            block(backgroundContext)
        }
    }
    
    // MARK: - Entity Creation
    func create<T: NSManagedObject>(_ entityType: T.Type) -> T {
        let entityName = String(describing: entityType)
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: self)!
        return T(entity: entity, insertInto: self)
    }
}
