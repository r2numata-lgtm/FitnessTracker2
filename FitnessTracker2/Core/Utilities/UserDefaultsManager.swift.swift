//
//  UserDefaultsManager.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Keys
    private enum Keys: String {
        case userHeight = "userHeight"
        case userWeight = "userWeight"
        case userAge = "userAge"
        case userGender = "userGender"
        case dailyCalorieGoal = "dailyCalorieGoal"
        case lastSyncDate = "lastSyncDate"
        case isFirstLaunch = "isFirstLaunch"
        case notificationEnabled = "notificationEnabled"
        case reminderTime = "reminderTime"
        case preferredUnits = "preferredUnits"
        case exerciseHistory = "exerciseHistory"
        case foodHistory = "foodHistory"
    }
    
    // MARK: - User Profile
    var userHeight: Double {
        get { userDefaults.double(forKey: Keys.userHeight.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.userHeight.rawValue) }
    }
    
    var userWeight: Double {
        get { userDefaults.double(forKey: Keys.userWeight.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.userWeight.rawValue) }
    }
    
    var userAge: Int {
        get { userDefaults.integer(forKey: Keys.userAge.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.userAge.rawValue) }
    }
    
    var userGender: String {
        get { userDefaults.string(forKey: Keys.userGender.rawValue) ?? "male" }
        set { userDefaults.set(newValue, forKey: Keys.userGender.rawValue) }
    }
    
    // MARK: - App Settings
    var dailyCalorieGoal: Double {
        get { userDefaults.double(forKey: Keys.dailyCalorieGoal.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.dailyCalorieGoal.rawValue) }
    }
    
    var isFirstLaunch: Bool {
        get { userDefaults.bool(forKey: Keys.isFirstLaunch.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.isFirstLaunch.rawValue) }
    }
    
    var notificationEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.notificationEnabled.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.notificationEnabled.rawValue) }
    }
    
    var reminderTime: Date {
        get {
            if let data = userDefaults.data(forKey: Keys.reminderTime.rawValue) {
                return (try? JSONDecoder().decode(Date.self, from: data)) ?? defaultReminderTime()
            }
            return defaultReminderTime()
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: Keys.reminderTime.rawValue)
            }
        }
    }
    
    var lastSyncDate: Date? {
        get {
            if let data = userDefaults.data(forKey: Keys.lastSyncDate.rawValue) {
                return try? JSONDecoder().decode(Date.self, from: data)
            }
            return nil
        }
        set {
            if let date = newValue, let data = try? JSONEncoder().encode(date) {
                userDefaults.set(data, forKey: Keys.lastSyncDate.rawValue)
            } else {
                userDefaults.removeObject(forKey: Keys.lastSyncDate.rawValue)
            }
        }
    }
    
    // MARK: - History Management
    var exerciseHistory: [String] {
        get { userDefaults.stringArray(forKey: Keys.exerciseHistory.rawValue) ?? [] }
        set { userDefaults.set(newValue, forKey: Keys.exerciseHistory.rawValue) }
    }
    
    var foodHistory: [String] {
        get { userDefaults.stringArray(forKey: Keys.foodHistory.rawValue) ?? [] }
        set { userDefaults.set(newValue, forKey: Keys.foodHistory.rawValue) }
    }
    
    // MARK: - Helper Methods
    private func defaultReminderTime() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = AppConstants.Notifications.reminderHour
        components.minute = AppConstants.Notifications.reminderMinute
        return calendar.date(from: components) ?? Date()
    }
    
    func addExerciseToHistory(_ exerciseName: String) {
        var history = exerciseHistory
        
        // 重複を削除
        history.removeAll { $0 == exerciseName }
        
        // 先頭に追加
        history.insert(exerciseName, at: 0)
        
        // 最大20件まで保持
        if history.count > 20 {
            history = Array(history.prefix(20))
        }
        
        exerciseHistory = history
    }
    
    func addFoodToHistory(_ foodName: String) {
        var history = foodHistory
        
        // 重複を削除
        history.removeAll { $0 == foodName }
        
        // 先頭に追加
        history.insert(foodName, at: 0)
        
        // 最大50件まで保持
        if history.count > 50 {
            history = Array(history.prefix(50))
        }
        
        foodHistory = history
    }
    
    func clearAllData() {
        let keys = [
            Keys.userHeight.rawValue,
            Keys.userWeight.rawValue,
            Keys.userAge.rawValue,
            Keys.userGender.rawValue,
            Keys.dailyCalorieGoal.rawValue,
            Keys.lastSyncDate.rawValue,
            Keys.exerciseHistory.rawValue,
            Keys.foodHistory.rawValue
        ]
        
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
    
    // MARK: - Validation
    func hasValidUserProfile() -> Bool {
        return userHeight > 0 && userWeight > 0 && userAge > 0
    }
    
    func setDefaultValues() {
        if userHeight == 0 { userHeight = 170.0 }
        if userWeight == 0 { userWeight = 70.0 }
        if userAge == 0 { userAge = 30 }
        if dailyCalorieGoal == 0 { dailyCalorieGoal = 2000.0 }
    }
}
