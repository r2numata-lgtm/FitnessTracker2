//
//  CalendarView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - カレンダービュー
struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var displayedMonth = Date()
    @State private var calendarData: [Date: CalendarDayData] = [:]
    
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            headerView
            
            // 曜日ヘッダー
            weekdayHeaderView
            
            // カレンダーグリッド
            calendarGridView
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .onAppear {
            loadCalendarData()
        }
        .onChange(of: displayedMonth) { _ in
            loadCalendarData()
        }
    }
    
    // MARK: - ヘッダー
    private var headerView: some View {
        HStack {
            // 前月ボタン
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            
            Spacer()
            
            // 月年表示
            VStack(spacing: 2) {
                Text(monthYearString)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("今日: \(todayString)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 次月ボタン
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - 曜日ヘッダー
    private var weekdayHeaderView: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - カレンダーグリッド
    private var calendarGridView: some View {
        VStack(spacing: 4) {
            ForEach(calendarWeeks, id: \.self) { week in
                HStack(spacing: 4) {
                    ForEach(week, id: \.self) { date in
                        CalendarDayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month),
                            dayData: calendarData[calendar.startOfDay(for: date)],
                            onTap: {
                                selectedDate = date
                                onDateSelected(date)
                            }
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 計算プロパティ
    
    private var monthYearString: String {
        dateFormatter.dateFormat = "yyyy年M月"
        return dateFormatter.string(from: displayedMonth)
    }
    
    private var todayString: String {
        dateFormatter.dateFormat = "M月d日(E)"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.string(from: Date())
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        // 日曜日を最初に移動
        return Array(symbols[1...]) + [symbols[0]]
    }
    
    private var calendarWeeks: [[Date]] {
        let startOfMonth = calendar.dateInterval(of: .month, for: displayedMonth)?.start ?? displayedMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: displayedMonth)?.end ?? displayedMonth
        
        var weeks: [[Date]] = []
        var currentWeek: [Date] = []
        
        // 月の最初の日から始まる週の最初の日を取得
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var currentDate = startOfWeek
        
        while currentDate < endOfMonth {
            currentWeek.append(currentDate)
            
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // 最後の週が7日未満の場合、残りの日を追加
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            weeks.append(currentWeek)
        }
        
        return weeks
    }
    
    // MARK: - Private Methods
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        }
    }
    
    private func loadCalendarData() {
        // TODO: Core Dataから該当月のデータを取得
        // 仮のデータを設定
        calendarData = generateSampleCalendarData()
    }
    
    private func generateSampleCalendarData() -> [Date: CalendarDayData] {
        var data: [Date: CalendarDayData] = [:]
        
        let startOfMonth = calendar.dateInterval(of: .month, for: displayedMonth)?.start ?? displayedMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: displayedMonth)?.end ?? displayedMonth
        
        var currentDate = startOfMonth
        while currentDate < endOfMonth {
            let dayData = CalendarDayData(
                hasWorkout: Bool.random(),
                hasFood: Bool.random(),
                hasBodyComposition: Bool.random(),
                calorieBalance: Double.random(in: -500...500)
            )
            
            data[calendar.startOfDay(for: currentDate)] = dayData
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return data
    }
}

// MARK: - カレンダー日表示
struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let dayData: CalendarDayData?
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            // 日付
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: isToday ? .bold : .medium))
                .foregroundColor(textColor)
            
            // インジケーター
            HStack(spacing: 1) {
                if dayData?.hasWorkout == true {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 4, height: 4)
                }
                
                if dayData?.hasFood == true {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 4, height: 4)
                }
                
                if dayData?.hasBodyComposition == true {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 6)
        }
        .frame(width: 36, height: 36)
        .background(
            Circle()
                .fill(backgroundColor)
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        )
        .onTapGesture {
            onTap()
        }
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .secondary.opacity(0.5)
        } else if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isToday && !isSelected {
            return .blue.opacity(0.1)
        } else {
            return .clear
        }
    }
    
    private var borderColor: Color {
        if isToday && !isSelected {
            return .blue
        } else {
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        isToday && !isSelected ? 1 : 0
    }
}

// MARK: - カレンダー日データ
struct CalendarDayData {
    let hasWorkout: Bool
    let hasFood: Bool
    let hasBodyComposition: Bool
    let calorieBalance: Double
    
    var hasAnyData: Bool {
        hasWorkout || hasFood || hasBodyComposition
    }
}

// MARK: - カレンダーレジェンド
struct CalendarLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("凡例")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                LegendItem(color: .orange, label: "ワークアウト")
                LegendItem(color: .green, label: "食事")
                LegendItem(color: .blue, label: "体組成")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 月間統計ビュー
struct MonthlyStatsView: View {
    let monthlyData: MonthlyStats
    
    var body: some View {
        VStack(spacing: 12) {
            Text("今月の統計")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                MonthStatCard(
                    title: "ワークアウト日数",
                    value: "\(monthlyData.workoutDays)",
                    subtitle: "日",
                    color: .orange,
                    icon: "dumbbell.fill"
                )
                
                MonthStatCard(
                    title: "記録日数",
                    value: "\(monthlyData.recordedDays)",
                    subtitle: "日",
                    color: .blue,
                    icon: "calendar"
                )
                
                MonthStatCard(
                    title: "平均カロリー",
                    value: "\(Int(monthlyData.averageCalories))",
                    subtitle: "kcal",
                    color: .green,
                    icon: "flame"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MonthStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16, weight: .medium))
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 1) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(subtitle)
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

// MARK: - 月間統計データ
struct MonthlyStats {
    let workoutDays: Int
    let recordedDays: Int
    let averageCalories: Double
    let totalSteps: Int
}

// MARK: - プレビュー
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CalendarView { date in
                print("Selected date: \(date)")
            }
            
            CalendarLegendView()
            
            MonthlyStatsView(
                monthlyData: MonthlyStats(
                    workoutDays: 15,
                    recordedDays: 28,
                    averageCalories: 2100,
                    totalSteps: 280000
                )
            )
        }
        .padding()
    }
}
