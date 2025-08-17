//
//  FoodRowView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - 食事行ビュー
struct FoodRowView: View {
    let food: FoodEntry
    let showDate: Bool
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    @State private var showingActionSheet = false
    
    init(
        food: FoodEntry,
        showDate: Bool = false,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.food = food
        self.showDate = showDate
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 食事タイプアイコン
            mealTypeIcon
            
            // 食事情報
            foodInfoSection
            
            Spacer()
            
            // カロリー表示
            caloriesSection
            
            // アクションボタン
            if onEdit != nil || onDelete != nil {
                actionButton
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .contextMenu {
            contextMenuActions
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text(food.foodName ?? "食事"),
                buttons: actionSheetButtons
            )
        }
    }
    
    // MARK: - 食事タイプアイコン
    private var mealTypeIcon: some View {
        ZStack {
            Circle()
                .fill(mealTypeColor.opacity(0.2))
                .frame(width: 36, height: 36)
            
            Image(systemName: mealTypeIconName)
                .foregroundColor(mealTypeColor)
                .font(.system(size: 16, weight: .medium))
        }
    }
    
    // MARK: - 食事情報セクション
    private var foodInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 食事名
            Text(food.foodName ?? "不明な食事")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            // 食事タイプと日付
            HStack(spacing: 8) {
                Text(food.mealType ?? "その他")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(mealTypeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(mealTypeColor.opacity(0.15))
                    .cornerRadius(8)
                
                if showDate {
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 栄養素情報（ある場合）
            if hasNutritionInfo {
                nutritionInfoView
            }
        }
    }
    
    // MARK: - 栄養素情報
    private var nutritionInfoView: some View {
        HStack(spacing: 12) {
            if food.protein > 0 {
                NutrientTag(label: "P", value: food.protein, unit: "g", color: .red)
            }
            
            if food.carbs > 0 {
                NutrientTag(label: "C", value: food.carbs, unit: "g", color: .orange)
            }
            
            if food.fat > 0 {
                NutrientTag(label: "F", value: food.fat, unit: "g", color: .yellow)
            }
        }
    }
    
    // MARK: - カロリーセクション
    private var caloriesSection: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("\(Int(food.calories))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("kcal")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - アクションボタン
    private var actionButton: some View {
        Button(action: {
            showingActionSheet = true
        }) {
            Image(systemName: "ellipsis")
                .foregroundColor(.secondary)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 24, height: 24)
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
        
        if let onDelete = onDelete {
            buttons.append(.destructive(Text("削除"), action: onDelete))
        }
        
        buttons.append(.cancel())
        return buttons
    }
    
    // MARK: - 計算プロパティ
    private var mealTypeColor: Color {
        switch food.mealType {
        case "朝食": return .orange
        case "昼食": return .blue
        case "夕食": return .purple
        case "間食": return .green
        default: return .gray
        }
    }
    
    private var mealTypeIconName: String {
        switch food.mealType {
        case "朝食": return "sun.max"
        case "昼食": return "sun.max.fill"
        case "夕食": return "moon"
        case "間食": return "leaf"
        default: return "fork.knife"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: food.date ?? Date())
    }
    
    private var hasNutritionInfo: Bool {
        food.protein > 0 || food.carbs > 0 || food.fat > 0
    }
}

// MARK: - 栄養素タグ
struct NutrientTag: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text("\(value, specifier: "%.1f")\(unit)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.1))
        .cornerRadius(4)
    }
}

// MARK: - 食事サマリー行
struct FoodSummaryRowView: View {
    let foods: [FoodEntry]
    let mealType: String
    
    private var totalCalories: Double {
        foods.reduce(0) { $0 + $1.calories }
    }
    
    private var foodCount: Int {
        foods.count
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 食事タイプアイコン
            ZStack {
                Circle()
                    .fill(mealTypeColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: mealTypeIconName)
                    .foregroundColor(mealTypeColor)
                    .font(.system(size: 14, weight: .medium))
            }
            
            // 食事情報
            VStack(alignment: .leading, spacing: 2) {
                Text(mealType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("\(foodCount)品目")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 合計カロリー
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(totalCalories))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text("kcal")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
    
    private var mealTypeColor: Color {
        switch mealType {
        case "朝食": return .orange
        case "昼食": return .blue
        case "夕食": return .purple
        case "間食": return .green
        default: return .gray
        }
    }
    
    private var mealTypeIconName: String {
        switch mealType {
        case "朝食": return "sun.max"
        case "昼食": return "sun.max.fill"
        case "夕食": return "moon"
        case "間食": return "leaf"
        default: return "fork.knife"
        }
    }
}

// MARK: - 食事リストビュー
struct FoodListView: View {
    let foods: [FoodEntry]
    let showDateSections: Bool
    let onEdit: ((FoodEntry) -> Void)?
    let onDelete: ((FoodEntry) -> Void)?
    
    private var groupedFoods: [(String, [FoodEntry])] {
        if showDateSections {
            let grouped = Dictionary(grouping: foods) { food in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: food.date ?? Date())
            }
            return grouped.sorted { $0.key > $1.key }
        } else {
            return [("", foods)]
        }
    }
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(groupedFoods, id: \.0) { dateString, dailyFoods in
                if showDateSections && !dateString.isEmpty {
                    // 日付ヘッダー
                    HStack {
                        Text(formatDateHeader(dateString))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(Int(dailyFoods.reduce(0) { $0 + $1.calories }))kcal")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal)
                }
                
                // 食事タイプ別グループ
                let mealGroups = Dictionary(grouping: dailyFoods) { $0.mealType ?? "その他" }
                
                ForEach(["朝食", "昼食", "夕食", "間食"], id: \.self) { mealType in
                    if let mealFoods = mealGroups[mealType], !mealFoods.isEmpty {
                        VStack(spacing: 8) {
                            FoodSummaryRowView(foods: mealFoods, mealType: mealType)
                                .padding(.horizontal)
                            
                            ForEach(mealFoods, id: \.self) { food in
                                FoodRowView(
                                    food: food,
                                    showDate: false,
                                    onEdit: onEdit != nil ? { onEdit?(food) } : nil,
                                    onDelete: onDelete != nil ? { onDelete?(food) } : nil
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
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

// MARK: - プレビュー
struct FoodRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            FoodRowView(
                food: sampleFood,
                showDate: true,
                onEdit: {},
                onDelete: {}
            )
            
            FoodSummaryRowView(
                foods: [sampleFood, sampleFood2],
                mealType: "朝食"
            )
        }
        .padding()
    }
    
    static var sampleFood: FoodEntry {
        let food = FoodEntry()
        food.foodName = "鶏胸肉のサラダ"
        food.calories = 250
        food.mealType = "昼食"
        food.protein = 30
        food.carbs = 10
        food.fat = 8
        food.date = Date()
        return food
    }
    
    static var sampleFood2: FoodEntry {
        let food = FoodEntry()
        food.foodName = "玄米ご飯"
        food.calories = 160
        food.mealType = "朝食"
        food.protein = 3
        food.carbs = 35
        food.fat = 1
        food.date = Date()
        return food
    }
}
