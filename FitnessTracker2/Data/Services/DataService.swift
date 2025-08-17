//
//  DataService.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import CoreData
import Foundation

protocol DataServiceProtocol {
    associatedtype Entity: NSManagedObject
    
    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [Entity]
    func fetchFirst(predicate: NSPredicate?) -> Entity?
    func create() -> Entity
    func save() throws
    func delete(_ entity: Entity) throws
    func deleteAll(predicate: NSPredicate?) throws
}

class DataService<T: NSManagedObject>: DataServiceProtocol {
    typealias Entity = T
    
    private let context: NSManagedObjectContext
    private let entityName: String
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        self.entityName = String(describing: T.self)
    }
    
    // MARK: - DataServiceProtocol
    func fetch(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error for \(entityName): \(error)")
            return []
        }
    }
    
    func fetchFirst(predicate: NSPredicate? = nil) -> T? {
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("FetchFirst error for \(entityName): \(error)")
            return nil
        }
    }
    
    func create() -> T {
        return context.create(T.self)
    }
    
    func save() throws {
        try context.saveWithErrorHandling()
    }
    
    func delete(_ entity: T) throws {
        context.delete(entity)
        try save()
    }
    
    func deleteAll(predicate: NSPredicate? = nil) throws {
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        
        let entities = try context.fetch(request)
        entities.forEach { context.delete($0) }
        
        try save()
    }
    
    // MARK: - Convenience Methods
    func count(predicate: NSPredicate? = nil) -> Int {
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        
        return context.count(for: request)
    }
    
    func exists(predicate: NSPredicate) -> Bool {
        return fetchFirst(predicate: predicate) != nil
    }
    
    // MARK: - Date Range Queries
    func fetchForDate(_ date: Date, keyPath: String = "date") -> [T] {
        let predicate = DateRangeService.createDatePredicate(for: date, keyPath: keyPath)
        return fetch(predicate: predicate)
    }
    
    func fetchForWeek(_ date: Date, keyPath: String = "date") -> [T] {
        let predicate = DateRangeService.createWeekPredicate(for: date, keyPath: keyPath)
        return fetch(predicate: predicate)
    }
    
    func fetchForMonth(_ date: Date, keyPath: String = "date") -> [T] {
        let predicate = DateRangeService.createMonthPredicate(for: date, keyPath: keyPath)
        return fetch(predicate: predicate)
    }
    
    func fetchForDateRange(from startDate: Date, to endDate: Date, keyPath: String = "date") -> [T] {
        let predicate = NSPredicate(format: "%K >= %@ AND %K <= %@",
                                   keyPath, startDate as NSDate,
                                   keyPath, endDate as NSDate)
        return fetch(predicate: predicate)
    }
    
    // MARK: - Batch Operations
    func batchCreate<DTO>(_ dtos: [DTO], configure: (T, DTO) -> Void) throws {
        for dto in dtos {
            let entity = create()
            configure(entity, dto)
        }
        try save()
    }
    
    func batchUpdate(predicate: NSPredicate, update: (T) -> Void) throws {
        let entities = fetch(predicate: predicate)
        entities.forEach(update)
        try save()
    }
}
