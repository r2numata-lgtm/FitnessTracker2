//
//  EmptyStateView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - 空の状態表示ビュー
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        title: String,
        message: String,
        systemImage: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // アイコン
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundColor(.secondary)
                .opacity(0.6)
            
            // テキスト
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // アクションボタン
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(25)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(32)
    }
}

// MARK: - 特定用途の空状態ビュー

// MARK: - データなし状態
struct NoDataEmptyState: View {
    let dataType: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        EmptyStateView(
            title: "\(dataType)がありません",
            message: "まだ\(dataType)が記録されていません。\n新しい記録を追加してみましょう。",
            systemImage: "tray",
            actionTitle: actionTitle,
            action: action
        )
    }
}

// MARK: - ワークアウト用空状態
struct WorkoutEmptyState: View {
    let action: (() -> Void)?
    
    var body: some View {
        EmptyStateView(
            title: "ワークアウト記録がありません",
            message: "最初のワークアウトを記録して、\nフィットネスの旅を始めましょう！",
            systemImage: "dumbbell",
            actionTitle: "ワークアウトを記録",
            action: action
        )
    }
}

// MARK: - 食事用空状態
struct FoodEmptyState: View {
    let action: (() -> Void)?
    
    var body: some View {
        EmptyStateView(
            title: "食事記録がありません",
            message: "今日の食事を記録して、\n栄養管理を始めましょう！",
            systemImage: "fork.knife",
            actionTitle: "食事を記録",
            action: action
        )
    }
}

// MARK: - 体組成用空状態
struct BodyCompositionEmptyState: View {
    let action: (() -> Void)?
    
    var body: some View {
        EmptyStateView(
            title: "体組成データがありません",
            message: "身長、体重などの基本情報を入力して、\n健康管理を始めましょう！",
            systemImage: "figure.stand",
            actionTitle: "体組成を記録",
            action: action
        )
    }
}

// MARK: - 検索結果なし状態
struct SearchEmptyState: View {
    let searchTerm: String
    
    var body: some View {
        EmptyStateView(
            title: "検索結果がありません",
            message: "「\(searchTerm)」に一致する結果が見つかりませんでした。\n別のキーワードで検索してみてください。",
            systemImage: "magnifyingglass"
        )
    }
}

// MARK: - ネットワークエラー状態
struct NetworkErrorEmptyState: View {
    let action: (() -> Void)?
    
    var body: some View {
        EmptyStateView(
            title: "接続エラー",
            message: "インターネット接続を確認して、\nもう一度お試しください。",
            systemImage: "wifi.slash",
            actionTitle: "再試行",
            action: action
        )
    }
}

// MARK: - メンテナンス状態
struct MaintenanceEmptyState: View {
    var body: some View {
        EmptyStateView(
            title: "メンテナンス中",
            message: "現在システムメンテナンス中です。\nしばらくお待ちください。",
            systemImage: "wrench.and.screwdriver"
        )
    }
}
