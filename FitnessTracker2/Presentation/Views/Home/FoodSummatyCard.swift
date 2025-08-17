//
//  CalorieBalanceCard.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - カロリー収支カード
struct CalorieBalanceCard: View {
    let dailyCalories: DailyCalories?
    let todayWorkouts: [WorkoutEntry]
    let todayFoods: [FoodEntry]
    let targetCalories: Double?
    
    @State private var showDetails: Bool = false
    @State private var animateProgress: Bool = false
    
    init(
        dailyCalories: DailyCalories? = nil,
        todayWorkouts: [WorkoutEntry] = [],
        todayFoods: [FoodEntry] = [],
        targetCalories: Double? = nil
    ) {
        self.dailyCalories = dailyCalories
        self.todayWorkouts = todayWorkouts
        self.todayFoods = todayFoods
        self.targetCalories = targetCalories
    }
    
    private var totalIntake: Double {
        todayFoods.reduce(0) { $0 + $1.calories }
    }
    
    private var totalBurned: Double {
        todayWorkouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    private var netCalories: Double {
        totalIntake - totalBurned
    }
    
    private var steps: Int {
        Int(dailyCalories?.steps ?? 0)
    }
    
    private var progressPercentage: Double {
        guard let target = targetCalories, target > 0 else { return 0 }
        return min(totalIntake / target, 1.5) // 最大150%まで表示
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー
            headerView
            
            // メインカロリー表示
            mainCalorieView
            
            // プログレスバー（目標がある場合）
            if targetCalories != nil {
                progressBarView
            }
            
            // 詳細統計
            statisticsView
            
            // 詳細表示切り替え
            if showDetails {
                detailsView
            }
            
            // 詳細表示ボタン
            toggleButton
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(netCaloriesColor.opacity(0.3), lineWidth: 2)
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animateProgress = true
            }
        }
    }
    
    // MARK: - ヘッダー
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("今日のカロリー収支")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("摂取 - 消費")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // ステータスインジケーター
            statusIndicator
        }
    }
    
    // MARK: - ステータスインジケーター
    private var statusIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(netCaloriesColor)
                .frame(width: 8, height: 8)
            
            Text(getCalorieStatus())
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(netCaloriesColor)
        }
    }
    
    // MARK: - メインカロリー表示
    private var mainCalorieView: some View {
        VStack(spacing: 8) {
            // ネットカロリー
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(netCalories >= 0 ? "+" : "")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(netCaloriesColor)
                
                Text("\(Int(abs(netCalories)))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(netCaloriesColor)
                
                Text("kcal")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // サブタイトル
            Text(getCalorieDescription())
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - プログレスバー
    private var progressBarView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("目標に対する摂取量")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let target = targetCalories {
                    Text("\(Int(totalIntake))/\(Int(target))kcal")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
            }
            
            // プログレスバー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    // プログレス
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: progressGradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: animateProgress ? geometry.size.width * progressPercentage : 0,
                            height: 8
                        )
                        .animation(.easeInOut(duration: 1.0), value: animateProgress)
                }
            }
            .frame(height: 8)
            
            // パーセンテージ
            HStack {
                Text("\(Int(progressPercentage * 100))%")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(progressPercentage > 1 ? .red : .green)
                
                Spacer()
            }
        }
    }
    
    // MARK: - 統計表示
    private var statisticsView: some View {
        HStack(spacing: 0) {
            // 摂取カロリー
            StatisticColumn(
                title: "摂取",
                value: "\(Int(totalIntake))",
                unit: "kcal",
                color: .blue,
                icon: "arrow.down.circle.fill"
            )
            
            Divider()
                .frame(height: 40)
            
            // 消費カロリー
            StatisticColumn(
                title: "消費",
                value: "\(Int(totalBurned))",
                unit: "kcal",
                color: .orange,
                icon: "flame.fill"
            )
            
            Divider()
                .frame(height: 40)
            
            // 歩数
            StatisticColumn(
                title: "歩数",
                value: "\(steps)",
                unit: "歩",
                color: .purple,
                icon: "figure.walk"
            )
        }
    }
    
    // MARK: - 詳細表示
    private var detailsView: some View {
        VStack(spacing: 12) {
            Divider()
            
            // 食事の内訳
            if !todayFoods.isEmpty {
                mealBreakdownView
            }
            
            // ワークアウトの内訳
            if !todayWorkouts.isEmpty {
                workoutBreakdownView
            }
            
            // 推奨事項
            recommendationView
        }
    }
    
    // MARK: - 食事内訳
    private var mealBreakdownView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("食事内訳")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            let mealGroups = Dictionary(grouping: todayFoods) { $0.mealType ?? "その他" }
            
            ForEach(["朝食", "昼食", "夕食", "間食"], id: \.self) { mealType in
                if let meals = mealGroups[mealType], !meals.isEmpty {
                    HStack {
                        Text(mealType)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(meals.count)品目")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(meals.reduce(0) { $0 + $1.calories }))kcal")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
    
    // MARK: - ワークアウト内訳
    private var workoutBreakdownView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ワークアウト内訳")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            let workoutGroups = Dictionary(grouping: todayWorkouts) { $0.exerciseName ?? "不明" }
            
            ForEach(Array(workoutGroups.keys.sorted()), id: \.self) { exerciseName in
                if let workouts = workoutGroups[exerciseName] {
                    HStack {
                        Text(exerciseName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(workouts.count)セット")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(workouts.reduce(0) { $0 + $1.caloriesBurned }))kcal")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
    
    // MARK: - 推奨事項
    private var recommendationView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.yellow)
                
                Text("今日のアドバイス")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Text(getRecommendation())
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
    
    // MARK: - 詳細表示切り替えボタン
    private var toggleButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                showDetails.toggle()
            }
        }) {
            HStack(spacing: 4) {
                Text(showDetails ? "詳細を非表示" : "詳細を表示")
                    .font(.caption)
                
                Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                    .font(.caption2)
            }
            .foregroundColor(.blue)
        }
    }
    
    // MARK: - 計算プロパティ
    private var netCaloriesColor: Color {
        if abs(netCalories) < 50 {
            return .green
        } else if netCalories > 0 {
            return .red
        } else {
            return .blue
        }
    }
    
    private var progressGradientColors: [Color] {
        if progressPercentage <= 0.8 {
            return [.green, .green]
        } else if progressPercentage <= 1.0 {
            return [.yellow, .green]
        } else {
            return [.red, .orange]
        }
    }
    
    // MARK: - Private Methods
    private func getCalorieStatus() -> String {
        if abs(netCalories) < 50 {
            return "バランス良好"
        } else if netCalories > 0 {
            return "摂取過多"
        } else {
            return "消費過多"
        }
    }
    
    private func getCalorieDescription() -> String {
        if abs(netCalories) < 50 {
            return "理想的なカロリーバランスです"
        } else if netCalories > 0 {
            return "摂取カロリーが消費カロリーを上回っています"
        } else {
            return "消費カロリーが摂取カロリーを上回っています"
        }
    }
    
    private func getRecommendation() -> String {
        let calorieBalance = netCalories
        let foodCount = todayFoods.count
        let workoutCount = todayWorkouts.count
        
        if foodCount == 0 && workoutCount == 0 {
            return "今日はまだ記録がありません。食事とワークアウトを記録して健康管理を始めましょう。"
        } else if calorieBalance > 500 {
            return "摂取カロリーが多めです。軽い運動を追加するか、次の食事で調整しましょう。"
        } else if calorieBalance < -500 {
            return "消費カロリーが多めです。栄養のある食事を摂って体力を回復させましょう。"
        } else if workoutCount == 0 {
            return "今日はまだワークアウトをしていません。軽い運動でも健康に良い効果があります。"
        } else {
            return "良いバランスです。この調子で健康的な生活を続けましょう。"
        }
    }
}

// MARK: - 統計カラム
struct StatisticColumn: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            // アイコン
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16, weight: .medium))
            
            // タイトル
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // 値
            VStack(spacing: 1) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK
