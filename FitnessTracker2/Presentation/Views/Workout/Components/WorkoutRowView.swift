//
//  WorkoutRowView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - ワークアウト行ビュー
struct WorkoutRowView: View {
    let workout: WorkoutEntry
    let showDate: Bool
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    @State private var showingActionSheet = false
    
//
//  WorkoutRowView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - ワークアウト行ビュー
struct WorkoutRowView: View {
    let workout: WorkoutEntry
    let showDate: Bool
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    @State private var showingActionSheet = false
    
    init(
        workout: WorkoutEntry,
        showDate: Bool = false,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.workout = workout
        self.showDate = showDate
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 種目アイコン
            exerciseIcon
            
            // ワークアウト情報
            workoutInfoSection
            
            Spacer()
            
            // 統計表示
            statsSection
            
            // アクションボタン
            if onEdit != nil || onDelete != nil {
                actionButton
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .contextMenu {
            contextMenuActions
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text(workout.exerciseName ?? "ワークアウト"),
                buttons: actionSheetButtons
            )
        }
    }
    
    // MARK: - 種目アイコン
    private var exerciseIcon: some View {
        ZStack {
            Circle()
                .fill(exerciseColor.opacity(0.2))
                .frame(width: 44, height: 44)
            
            Image(systemName: exerciseIconName)
                .foregroundColor(exerciseColor)
                .font(.system(size: 18, weight: .medium))
        }
    }
    
    // MARK: - ワークアウト情報セクション
    private var workoutInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 種目名
            Text(workout.exerciseName ?? "不明な種目")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            // セット数と回数
            HStack(spacing: 8) {
                WorkoutDetailTag(
                    icon: "repeat",
                    value: "\(Int(workout.sets))",
                    label: "セット",
                    color: .blue
                )
                
                WorkoutDetailTag(
                    icon: "number",
                    value: "\(Int(workout.reps))",
                    label: "回",
                    color: .green
                )
                
                if workout.weight > 0 {
                    WorkoutDetailTag(
                        icon: "scalemass",
                        value: "\(Int(workout.weight))",
                        label: "kg",
                        color: .purple
                    )
                }
            }
            
            // 日付とメモ
            if showDate || workout.memo != nil {
                additionalInfoView
            }
        }
    }
    
    // MARK: - 追加情報
    private var additionalInfoView: some View {
        VStack(alignment: .leading, spacing: 2) {
            if showDate {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let memo = workout.memo, !memo.isEmpty {
                Text(memo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - 統計セクション
    private var statsSection: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // 消費カロリー
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(workout.caloriesBurned))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text("kcal")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // 強度レベル
            if workout.weight > 0 {
                intensityIndicator
            }
        }
    }
    
    // MARK: - 強度インジケーター
    private var intensityIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(index < intensityLevel ? exerciseColor : Color(.systemGray5))
                    .frame(width: 4, height: 4)
            }
        }
    }
    
    // MARK: - アクションボタン
    private var actionButton: some View {
        Button(action: {
            showingActionSheet = true
        }) {
            Image(systemName: "ellipsis")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - コンテキストメニューアクション
    private var contextMenuActions: some View {
        Group {
            if let onEdit = onEdit {
                Button(action: onEdit) {
                    Label("編集", systemImage: "pencil")
                }
            }
            
            Button(action: {
                // 複製機能
                duplicateWorkout()
            }) {
                Label("複製", systemImage: "doc.on.doc")
            }
            
            if let onDelete = onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("削除", systemImage: "trash")
                }
            }
        }
    }
    
    // MARK: - アクションシートボタン
    private var actionSheetButtons: [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        
        if let onEdit = onEdit {
            buttons.append(.default(Text("編集"), action: onEdit))
        }
        
        buttons.append(.default(Text("複製"), action: duplicateWorkout))
        
        if let onDelete = onDelete {
            buttons.append(.destructive(Text("削除"), action: onDelete))
        }
        
        buttons.append(.cancel())
        return buttons
    }
    
    // MARK: - 計算プロパティ
    private var exerciseColor: Color {
        switch workout.exerciseName?.lowercased() {
        case let name where name?.contains("ベンチプレス") == true || name?.contains("プレス") == true:
            return .red
        case let name where name?.contains("スクワット") == true:
            return .blue
        case let name where name?.contains("デッドリフト") == true:
            return .purple
        case let name where name?.contains("懸垂") == true || name?.contains("プルアップ") == true:
            return .green
        case let name where name?.contains("腹筋") == true:
            return .orange
        case let name where name?.contains("ランニング") == true || name?.contains("走") == true:
            return .pink
        case let name where name?.contains("ウォーキング") == true || name?.contains("歩") == true:
            return .cyan
        default:
            return .gray
        }
    }
    
    private var exerciseIconName: String {
        switch workout.exerciseName?.lowercased() {
        case let name where name?.contains("ベンチプレス") == true || name?.contains("プレス") == true:
            return "figure.strengthtraining.functional"
        case let name where name?.contains("スクワット") == true:
            return "figure.strengthtraining.traditional"
        case let name where name?.contains("デッドリフト") == true:
            return "figure.mixed.cardio"
        case let name where name?.contains("懸垂") == true || name?.contains("プルアップ") == true:
            return "figure.climbing"
        case let name where name?.contains("腹筋") == true:
            return "figure.core.training"
        case let name where name?.contains("ランニング") == true || name?.contains("走") == true:
            return "figure.run"
        case let name where name?.contains("ウォーキング") == true || name?.contains("歩") == true:
            return "figure.walk"
        default:
            return "dumbbell.fill"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: workout.date ?? Date())
    }
    
    private var intensityLevel: Int {
        // 重量に基づいて強度レベルを計算（簡易版）
        let weight = workout.weight
        if weight >= 100 { return 5 }
        else if weight >= 80 { return 4 }
        else if weight >= 60 { return 3 }
        else if weight >= 40 { return 2 }
        else if weight > 0 { return 1 }
        else { return 0 }
    }
    
    // MARK: - Private Methods
    private func duplicateWorkout() {
        // TODO: ワークアウト複製機能の実装
        print("ワークアウトを複製: \(workout.exerciseName ?? "")")
    }
}

// MARK: - ワークアウト詳細タグ
struct WorkoutDetailTag: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - ワークアウトリストビュー
struct WorkoutListView: View {
    let workouts: [WorkoutEntry]
    let showDateSections: Bool
    let onEdit: ((WorkoutEntry) -> Void)?
    let onDelete: ((WorkoutEntry) -> Void)?
    
    private var groupedWorkouts: [(String, [WorkoutEntry])] {
        if showDateSections {
            let grouped = Dictionary(grouping: workouts) { workout in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: workout.date ?? Date())
            }
            return grouped.sorted { $0.key > $1.key }
        } else {
            return [("", workouts)]
        }
    }
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(groupedWorkouts, id: \.0) { dateString, dailyWorkouts in
                if showDateSections && !dateString.isEmpty {
                    // 日付ヘッダー
                    HStack {
                        Text(formatDateHeader(dateString))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(dailyWorkouts.count)種目")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(dailyWorkouts.reduce(0) { $0 + $1.caloriesBurned }))kcal")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                }
                
                // ワークアウト一覧
                ForEach(dailyWorkouts, id: \.self) { workout in
                    WorkoutRowView(
                        workout: workout,
                        showDate: !showDateSections,
                        onEdit: onEdit != nil ? { onEdit?(workout) } : nil,
                        onDelete: onDelete != nil ? { onDelete?(workout) } : nil
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func formatDateHeader(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "M月d日(E)"
        displayFormatter.locale = Locale(identifier: "ja_JP")
        
        return displayFormatter.string(from: date)
    }
}

// MARK: - ワークアウトサマリービュー
struct WorkoutSummaryView: View {
    let workouts: [WorkoutEntry]
    let timeframe: TimeFrame
    
    private var totalCalories: Double {
        workouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    private var totalSets: Int {
        workouts.reduce(0) { $0 + Int($1.sets) }
    }
    
    private var uniqueExercises: Int {
        Set(workouts.compactMap { $0.exerciseName }).count
    }
    
    private var workoutDays: Int {
        Set(workouts.compactMap { workout in
            workout.date.map { Calendar.current.startOfDay(for: $0) }
        }).count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(timeframe.displayName)のサマリー")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                SummaryStatCard(
                    title: "ワークアウト日数",
                    value: "\(workoutDays)",
                    unit: "日",
                    color: .blue,
                    icon: "calendar"
                )
                
                SummaryStatCard(
                    title: "種目数",
                    value: "\(uniqueExercises)",
                    unit: "種目",
                    color: .green,
                    icon: "list.bullet"
                )
                
                SummaryStatCard(
                    title: "総セット数",
                    value: "\(totalSets)",
                    unit: "セット",
                    color: .purple,
                    icon: "repeat"
                )
                
                SummaryStatCard(
                    title: "消費カロリー",
                    value: "\(Int(totalCalories))",
                    unit: "kcal",
                    color: .orange,
                    icon: "flame.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - サマリー統計カード
struct SummaryStatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 14, weight: .medium))
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 1) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}

// MARK: - 時間枠
enum TimeFrame: String, CaseIterable {
    case week = "今週"
    case month = "今月"
    case threeMonths = "3ヶ月"
    case year = "今年"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - プレビュー
struct WorkoutRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            WorkoutRowView(
                workout: sampleWorkout,
                showDate: true,
                onEdit: {},
                onDelete: {}
            )
            
            WorkoutSummaryView(
                workouts: [sampleWorkout, sampleWorkout2],
                timeframe: .week
            )
        }
        .padding()
    }
    
    static var sampleWorkout: WorkoutEntry {
        let workout = WorkoutEntry()
        workout.exerciseName = "ベンチプレス"
        workout.weight = 80
        workout.sets = 3
        workout.reps = 10
        workout.caloriesBurned = 150
        workout.memo = "フォームを意識してゆっくりと"
        workout.date = Date()
        return workout
    }
    
    static var sampleWorkout2: WorkoutEntry {
        let workout = WorkoutEntry()
        workout.exerciseName = "スクワット"
        workout.weight = 100
        workout.sets = 4
        workout.reps = 12
        workout.caloriesBurned = 180
        workout.date = Date()
        return workout
    }
}
