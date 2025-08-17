//
//  WorkoutSummaryCard.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - ワークアウトサマリーカード
struct WorkoutSummaryCard: View {
    let workouts: [WorkoutEntry]
    let showDate: Bool
    let onViewAll: (() -> Void)?
    
    @State private var showDetails: Bool = false
    
    init(
        workouts: [WorkoutEntry],
        showDate: Bool = false,
        onViewAll: (() -> Void)? = nil
    ) {
        self.workouts = workouts
        self.showDate = showDate
        self.onViewAll = onViewAll
    }
    
    private var groupedWorkouts: [String: [WorkoutEntry]] {
        Dictionary(grouping: workouts) { workout in
            workout.exerciseName ?? "不明な種目"
        }
    }
    
    private var totalCaloriesBurned: Double {
        workouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    private var totalSets: Int {
        workouts.reduce(0) { $0 + Int($1.sets) }
    }
    
    private var workoutDuration: TimeInterval {
        guard let firstWorkout = workouts.last?.date,
              let lastWorkout = workouts.first?.date else { return 0 }
        return lastWorkout.timeIntervalSince(firstWorkout)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー
            headerView
            
            // サマリー統計
            summaryStatsView
            
            // 種目リスト
            exerciseListView
            
            // 詳細表示
            if showDetails {
                detailsView
            }
            
            // アクションボタン
            actionButtonsView
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - ヘッダー
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(showDate ? "ワークアウト記録" : "今日のワークアウト")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if showDate, let date = workouts.first?.date {
                    Text(dateFormatter.string(from: date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // ワークアウトアイコン
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "dumbbell.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 18, weight: .medium))
            }
        }
    }
    
    // MARK: - サマリー統計
    private var summaryStatsView: some View {
        HStack(spacing: 0) {
            // 種目数
            StatColumn(
                title: "種目",
                value: "\(groupedWorkouts.count)",
                unit: "種目",
                color: .blue,
                icon: "list.bullet"
            )
            
            Divider()
                .frame(height: 40)
            
            // 総セット数
            StatColumn(
                title: "セット",
                value: "\(totalSets)",
                unit: "セット",
                color: .green,
                icon: "repeat"
            )
            
            Divider()
                .frame(height: 40)
            
            // 消費カロリー
            StatColumn(
                title: "消費",
                value: "\(Int(totalCaloriesBurned))",
                unit: "kcal",
                color: .orange,
                icon: "flame.fill"
            )
            
            if workoutDuration > 0 {
                Divider()
                    .frame(height: 40)
                
                // 時間
                StatColumn(
                    title: "時間",
                    value: formatDuration(workoutDuration),
                    unit: "",
                    color: .purple,
                    icon: "clock"
                )
            }
        }
    }
    
    // MARK: - 種目リスト
    private var exerciseListView: some View {
        VStack(spacing: 8) {
            ForEach(Array(groupedWorkouts.keys.sorted()), id: \.self) { exerciseName in
                if let exerciseWorkouts = groupedWorkouts[exerciseName] {
                    ExerciseRowView(
                        exerciseName: exerciseName,
                        workouts: exerciseWorkouts
                    )
                }
            }
        }
    }
    
    // MARK: - 詳細表示
    private var detailsView: some View {
        VStack(spacing: 12) {
            Divider()
            
            // 種目別詳細
            exerciseDetailsView
            
            // ワークアウト分析
            if workouts.count > 1 {
                workoutAnalysisView
            }
        }
    }
    
    // MARK: - 種目別詳細
    private var exerciseDetailsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("種目別詳細")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach(Array(groupedWorkouts.keys.sorted()), id: \.self) { exerciseName in
                if let exerciseWorkouts = groupedWorkouts[exerciseName] {
                    ExerciseDetailRow(
                        exerciseName: exerciseName,
                        workouts: exerciseWorkouts
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }
    
    // MARK: - ワークアウト分析
    private var workoutAnalysisView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ワークアウト分析")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("• 最も負荷の高い種目: \(getMostIntenseExercise())")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• 平均セット数: \(String(format: "%.1f", Double(totalSets) / Double(groupedWorkouts.count)))セット/種目")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• カロリー効率: \(String(format: "%.1f", totalCaloriesBurned / max(workoutDuration / 60, 1)))kcal/分")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }
    
    // MARK: - アクションボタン
    private var actionButtonsView: some View {
        HStack {
            // 詳細表示切り替え
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
                .foregroundColor(.orange)
            }
            
            Spacer()
            
            // 全て表示ボタン
            if let onViewAll = onViewAll {
                Button(action: onViewAll) {
                    HStack(spacing: 4) {
                        Text("全て表示")
                            .font(.caption)
                        
                        Image(systemName: "arrow.right")
                            .font
