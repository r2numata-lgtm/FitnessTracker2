//
//  AppConstants.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

struct AppConstants {
    
    // MARK: - Calorie Calculation
    struct Calories {
        static let defaultBodyWeight: Double = 70.0
        static let stepsCalorieMultiplier: Double = 0.04
        static let idealBMI: Double = 22.0
        
        // MET Values for exercises
        static let metValues: [String: Double] = [
            "ベンチプレス": 6.0,
            "インクラインベンチプレス": 6.5,
            "スクワット": 5.0,
            "デッドリフト": 6.0,
            "懸垂": 8.0,
            "腕立て伏せ": 3.8,
            "ショルダープレス": 4.0,
            "ラットプルダウン": 4.5,
            "ランニング": 8.0,
            "ウォーキング": 3.5,
            "サイクリング": 7.0,
            "水泳": 8.0
        ]
        
        static let defaultMET: Double = 5.0
    }
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 15.0
        static let smallCornerRadius: CGFloat = 8.0
        static let cardPadding: CGFloat = 16.0
        static let defaultSpacing: CGFloat = 20.0
        static let smallSpacing: CGFloat = 8.0
        
        static let fabSize: CGFloat = 56.0
        static let fabPadding: CGFloat = 20.0
        
        static let thumbnailSize: CGFloat = 60.0
        static let photoDetailHeight: CGFloat = 200.0
    }
    
    // MARK: - Exercise Categories
    struct Exercise {
        static let categories = ["胸", "背中", "肩", "腕", "脚", "腹筋", "有酸素"]
        
        static let defaultExercises: [String: [String]] = [
            "胸": ["ベンチプレス", "インクラインベンチプレス", "ダンベルフライ", "腕立て伏せ"],
            "背中": ["デッドリフト", "懸垂", "ラットプルダウン", "ベントオーバーロー"],
            "肩": ["ショルダープレス", "サイドレイズ", "リアレイズ", "アップライトロー"],
            "腕": ["バーベルカール", "トライセプスエクステンション", "ハンマーカール", "ディップス"],
            "脚": ["スクワット", "レッグプレス", "レッグカール", "カーフレイズ"],
            "腹筋": ["クランチ", "プランク", "レッグレイズ", "バイシクルクランチ"],
            "有酸素": ["ランニング", "サイクリング", "ウォーキング", "エリプティカル"]
        ]
        
        static let exerciseExamples: [String: String] = [
            "胸": "インクラインダンベルプレス",
            "背中": "ワンハンドロー",
            "肩": "フロントレイズ",
            "腕": "プリーチャーカール",
            "脚": "ブルガリアンスクワット",
            "腹筋": "ロシアンツイスト",
            "有酸素": "エアロバイク"
        ]
    }
    
    // MARK: - Food Categories
    struct Food {
        static let mealTypes = ["朝食", "昼食", "夕食", "間食"]
        static let mealOrder = ["朝食", "昼食", "夕食", "間食"]
    }
    
    // MARK: - Validation
    struct Validation {
        static let maxExerciseNameLength = 30
        static let maxMemoLength = 100
        static let maxFoodNameLength = 50
        
        static let minHeight: Double = 100.0
        static let maxHeight: Double = 250.0
        static let minWeight: Double = 30.0
        static let maxWeight: Double = 200.0
        static let minAge = 10
        static let maxAge = 120
    }
    
    // MARK: - Notification
    struct Notifications {
        static let dailyReminderIdentifier = "dailyCalorieUpdate"
        static let reminderHour = 23
        static let reminderMinute = 0
    }
}
