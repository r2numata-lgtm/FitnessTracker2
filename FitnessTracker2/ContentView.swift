//
//  ContentView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some View {
        TabView {
            // ホーム画面
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(healthKitManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            
            // 筋トレ画面
            WorkoutView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(healthKitManager)
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("筋トレ")
                }
            
            // 食事画面
            FoodView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("食事")
                }
            
            // 体組成画面
            BodyCompositionView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(healthKitManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("体組成")
                }
            
            // 設定画面
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
        }
    }
}

// MARK: - 設定画面（簡易版）
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section("基本設定") {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("プロフィール設定")
                    }
                    
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("通知設定")
                    }
                    
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("データエクスポート")
                    }
                }
                
                Section("その他") {
                    HStack {
                        Image(systemName: "questionmark.circle")
                        Text("ヘルプ")
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                        Text("アプリについて")
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
