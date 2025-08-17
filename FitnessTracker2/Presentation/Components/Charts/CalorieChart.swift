//
//  CalorieChart.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI
import Charts

// MARK: - カロリーチャート
struct CalorieChart: View {
    let data: [CalorieData]
    let chartType: CalorieChartType
    
    @State private var selectedRange: DateRange = .week
    @State private var selectedDate: Date?
    
    var filteredData: [CalorieData] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return data.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return data.filter { $0.date >= monthAgo }
        case .threeMonths:
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return data.filter { $0.date >= threeMonthsAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return data.filter { $0.date >= yearAgo }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 期間選択
            dateRangePicker
            
            // チャート
            chartView
            
            // 統計情報
            statisticsView
        }
        .padding()
    }
    
    // MARK: - 期間選択ピッカー
    private var dateRangePicker: some View {
        Picker("期間", selection: $selectedRange) {
            ForEach(DateRange.allCases, id: \.self) { range in
                Text(range.displayName).tag(range)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    // MARK: - チャートビュー
    private var chartView: some View {
        Chart(filteredData) { item in
            switch chartType {
            case .line:
                LineMark(
                    x: .value("日付", item.date),
                    y: .value("カロリー", item.calories)
                )
                .foregroundStyle(item.calories >= 0 ? .green : .red)
                .interpolationMethod(.catmullRom)
                
            case .bar:
                BarMark(
                    x: .value("日付", item.date),
                    y: .value("カロリー", item.calories)
                )
                .foregroundStyle(item.calories >= 0 ? .green : .red)
                
            case .area:
                AreaMark(
                    x: .value("日付", item.date),
                    y: .value("カロリー", item.calories)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: item.calories >= 0 ? [.green.opacity(0.6), .green.opacity(0.2)] : [.red.opacity(0.6), .red.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
            case .combined:
                // 摂取カロリー（棒グラフ）
                BarMark(
                    x: .value("日付", item.date),
                    y: .value("摂取", item.intake)
                )
                .foregroundStyle(.blue.opacity(0.7))
                
                // 消費カロリー（棒グラフ）
                BarMark(
                    x: .value("日付", item.date),
                    y: .value("消費", -item.burned)
                )
                .foregroundStyle(.orange.opacity(0.7))
                
                // ネットカロリー（線グラフ）
                LineMark(
                    x: .value("日付", item.date),
                    y: .value("収支", item.calories)
                )
                .foregroundStyle(.primary)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: .stride(by: selectedRange.axisStride)) { value in
                AxisGridLine()
                AxisValueLabel(format: selectedRange.dateFormat)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartAngleSelection(value: .constant(selectedDate))
    }
    
    // MARK: - 統計情報
    private var statisticsView: some View {
        VStack(spacing: 12) {
            HStack {
                StatisticCard(
                    title: "平均",
                    value: "\(Int(filteredData.map(\.calories).average))kcal",
                    color: .blue
                )
                
                StatisticCard(
                    title: "最大",
                    value: "\(Int(filteredData.map(\.calories).max() ?? 0))kcal",
                    color: .green
                )
                
                StatisticCard(
                    title: "最小",
                    value: "\(Int(filteredData.map(\.calories).min() ?? 0))kcal",
                    color: .red
                )
            }
            
            if chartType == .combined {
                HStack {
                    StatisticCard(
                        title: "総摂取",
                        value: "\(Int(filteredData.map(\.intake).sum))kcal",
                        color: .blue
                    )
                    
                    StatisticCard(
                        title: "総消費",
                        value: "\(Int(filteredData.map(\.burned).sum))kcal",
                        color: .orange
                    )
                }
            }
        }
    }
}

// MARK: - 統計カード
struct StatisticCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - カロリーデータモデル
struct CalorieData: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Double  //
