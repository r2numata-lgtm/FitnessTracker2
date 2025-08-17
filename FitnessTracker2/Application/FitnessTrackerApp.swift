//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import SwiftUI
import UserNotifications

@main
struct FitnessTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(healthKitManager)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        requestNotificationPermission()
        scheduleCalorieUpdates()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("通知許可エラー: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleCalorieUpdates() {
        let content = UNMutableNotificationContent()
        content.title = "今日のカロリー収支"
        content.body = "今日の記録を確認しましょう"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 23
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyCalorieUpdate", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error.localizedDescription)")
            }
        }
    }
}
