//
//  ErrorMessages.swift
//  FitnessTracker
//
//  Created by 沼田蓮二朗 on 2025/07/26.
//
import Foundation

struct ErrorMessages {
    
    // MARK: - Validation Errors
    struct Validation {
        static let exerciseNameEmpty = "運動種目名を入力してください"
        static let exerciseNameTooLong = "運動種目名は30文字以内で入力してください"
        static let invalidCharacters = "使用できない文字が含まれています"
        
        static let foodNameEmpty = "食べ物の名前を入力してください"
        static let foodNameTooLong = "食べ物の名前は50文字以内で入力してください"
        static let caloriesInvalid = "カロリーは0より大きい値を入力してください"
        
        static let heightInvalid = "身長は100cm〜250cmの範囲で入力してください"
        static let weightInvalid = "体重は30kg〜200kgの範囲で入力してください"
        static let ageInvalid = "年齢は10歳〜120歳の範囲で入力してください"
        static let bodyFatInvalid = "体脂肪率は0%〜50%の範囲で入力してください"
    }
    
    // MARK: - Data Errors
    struct Data {
        static let saveError = "データの保存に失敗しました"
        static let loadError = "データの読み込みに失敗しました"
        static let deleteError = "データの削除に失敗しました"
        static let notFound = "データが見つかりません"
        static let duplicateEntry = "同じデータが既に存在します"
    }
    
    // MARK: - HealthKit Errors
    struct HealthKit {
        static let notAvailable = "HealthKitはこのデバイスで利用できません"
        static let authorizationFailed = "HealthKitの認証に失敗しました"
        static let dataFetchFailed = "健康データの取得に失敗しました"
        static let dataSaveFailed = "健康データの保存に失敗しました"
    }
    
    // MARK: - Photo Errors
    struct Photo {
        static let selectionFailed = "写真の選択に失敗しました"
        static let loadFailed = "写真の読み込みに失敗しました"
        static let saveFailed = "写真の保存に失敗しました"
        static let analysisFailed = "写真の解析に失敗しました"
    }
    
    // MARK: - Network Errors
    struct Network {
        static let connectionFailed = "ネットワーク接続に失敗しました"
        static let requestTimeout = "リクエストがタイムアウトしました"
        static let serverError = "サーバーエラーが発生しました"
        static let invalidResponse = "無効なレスポンスです"
    }
    
    // MARK: - General Errors
    struct General {
        static let unknown = "不明なエラーが発生しました"
        static let featureNotAvailable = "この機能は現在利用できません"
        static let permissionDenied = "必要な権限が許可されていません"
    }
}
