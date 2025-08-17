//
//  DateRangeService.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

struct DateRangeService {
    
    // MARK: - Date Range Creation
    static func createDateRange(for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return (start: startOfDay, end: endOfDay)
    }
    
    static func createWeekRange(for date: Date) -> (start: Date, end: Date) {
        let startOfWeek = date.startOfWeek()
        let endOfWeek = date.endOfWeek()
        return (start: startOfWeek, end: endOfWeek)
    }
    
    static func createMonthRange(for date: Date) -> (start: Date, end: Date) {
        let startOfMonth = date.startOfMonth()
        let endOfMonth = date.endOfMonth()
        return (start: startOfMonth, end: endOfMonth)
    }
    
    static func createYearRange(for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let endOfYear = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))!
        return (start: startOfYear, end: endOfYear)
    }
    
    // MARK: - Predicate Creation
    static func createDatePredicate(for date: Date, keyPath: String = "date") -> NSPredicate {
        let range = createDateRange(for: date)
        return NSPredicate(format: "%K >= %@ AND %K < %@",
                          keyPath, range.start as NSDate,
                          keyPath, range.end as NSDate)
    }
    
    static func createWeekPredicate(for date: Date, keyPath: String = "date") -> NSPredicate {
        let range = createWeekRange(for: date)
        return NSPredicate(format: "%K >= %@ AND %K <= %@",
                          keyPath, range.start as NSDate,
                          keyPath, range.end as NSDate)
    }
    
    static func createMonthPredicate(for date: Date, keyPath: String = "date") -> NSPredicate {
        let range = createMonthRange(for: date)
        return NSPredicate(format: "%K >= %@ AND %K <= %@",
                          keyPath, range.start as NSDate,
                          keyPath, range.end as NSDate)
    }
    
    static func createYearPredicate(for date: Date, keyPath: String = "date") -> NSPredicate {
        let range = createYearRange(for: date)
        return NSPredicate(format: "%K >= %@ AND %K < %@",
                          keyPath, range.start as NSDate,
                          keyPath, range.end as NSDate)
    }
    
    // MARK: - Date Array Generation
    static func generateDatesInRange(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate.startOfDay()
        let calendar = Calendar.current
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    static func generateWeekDates(for date: Date) -> [Date] {
        let range = createWeekRange(for: date)
        return generateDatesInRange(from: range.start, to: range.end)
    }
    
    static func generateMonthDates(for date: Date) -> [Date] {
        let range = createMonthRange(for: date)
        return generateDatesInRange(from: range.start, to: range.end)
    }
    
    // MARK: - Period Calculation
    static func periodBetween(from startDate: Date, to endDate: Date) -> (days: Int, weeks: Int, months: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .weekOfYear, .month], from: startDate, to: endDate)
        
        return (
            days: components.day ?? 0,
            weeks: components.weekOfYear ?? 0,
            months: components.month ?? 0
        )
    }
    
    // MARK: - Relative Date Helpers
    static func today() -> Date {
        return Date()
    }
    
    static func yesterday() -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    }
    
    static func tomorrow() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }
    
    static func thisWeek() -> (start: Date, end: Date) {
        return createWeekRange(for: Date())
    }
    
    static func lastWeek() -> (start: Date, end: Date) {
        let lastWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        return createWeekRange(for: lastWeekDate)
    }
    
    static func thisMonth() -> (start: Date, end: Date) {
        return createMonthRange(for: Date())
    }
    
    static func lastMonth() -> (start: Date, end: Date) {
        let lastMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return createMonthRange(for: lastMonthDate)
    }
}
