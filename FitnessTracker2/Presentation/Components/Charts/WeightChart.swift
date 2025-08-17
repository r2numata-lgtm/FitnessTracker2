//
//  WeightChart.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI
import Charts

// MARK: - 体重チャート
struct WeightChart: View {
    let data: [WeightData]
    
    @State private var selectedRange: DateRange = .month
    @State private var selectedPoint: WeightData?
    @State private var showTrendLine: Bool = true
    
    var filteredData: [WeightData] {
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
    
    var trendLineData: [WeightData] {
        guard filteredData.count > 1 else { return [] }
        
        let xValues = filteredData.enumerated().map { Double($0.offset) }
        let yValues = filteredData.map { $0.weight }
        
        let slope = calculateSlope(xValues: xValues, yValues: yValues)
        let intercept = calculateIntercept(xValues: xValues, yValues: yValues, slope: slope)
        
        return filteredData.enumerated().map { index, original in
            let trendWeight = slope * Double(index) + intercept
            return WeightData(date: original.date, weight: trendWeight, bodyFat: nil)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー
            headerView
            
            // チャート
            chartView
            
            // 統計情報
            statisticsView
            
            // オプション
            optionsView
        }
        .padding()
    }
    
    // MARK: - ヘッダー
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("体重の推移")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Picker("期間", selection: $selectedRange) {
                    ForEach(DateRange.allCases, id: \.self) { range in
                        Text(range.displayName).tag(range)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            if let latest = filteredData.last {
                HStack {
                    Text("現在: \(latest.weight, specifier: "%.1f")kg")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let change = weightChange {
                        HStack(spacing: 4) {
                            Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                .foregroundColor(change >= 0 ? .red : .green)
                            Text("\(abs(change), specifier: "%.1f")kg")
                                .foregroundColor(change >= 0 ? .red : .green)
                        }
                        .font(.subheadline)
                    }
                }
            }
        }
    }
    
    // MARK: - チャート
    private var chartView: some View {
        Chart {
            ForEach(filteredData) { item in
                LineMark(
                    x: .value("日付", item.date),
                    y: .value("体重", item.weight)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                PointMark(
                    x: .value("日付", item.date),
                    y: .value("体重", item.weight)
                )
                .foregroundStyle(.blue)
                .symbolSize(selectedPoint?.id == item.id ? 100 : 36)
            }
            
            // トレンドライン
            if showTrendLine && trendLineData.count > 1 {
                ForEach(trendLineData) { item in
                    LineMark(
                        x: .value("日付", item.date),
                        y: .value("トレンド", item.weight)
                    )
                    .foregroundStyle(.orange.opacity(0.7))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                }
            }
            
            // 理想体重ライン（もしあれば）
            if let idealWeight = idealWeight {
                RuleMark(y: .value("理想体重", idealWeight))
                    .foregroundStyle(.green.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [2, 2]))
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
                AxisValueLabel(format: .number.precision(.fractionLength(1)))
            }
        }
        .chartAngleSelection(value: .constant(selectedPoint?.date))
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateSelectedPoint(at: value.location, geometry: geometry, chartProxy: chartProxy)
                            }
                    )
            }
        }
    }
    
    // MARK: - 統計情報
    private var statisticsView: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "最新",
                value: "\(filteredData.last?.weight ?? 0, specifier: "%.1f")kg",
                color: .blue
            )
            
            StatCard(
                title: "最高",
                value: "\(filteredData.map(\.weight).max() ?? 0, specifier: "%.1f")kg",
                color: .red
            )
            
            StatCard(
                title: "最低",
                value: "\(filteredData.map(\.weight).min() ?? 0, specifier: "%.1f")kg",
                color: .green
            )
            
            StatCard(
                title: "平均",
                value: "\(filteredData.map(\.weight).average, specifier: "%.1f")kg",
                color: .orange
            )
        }
    }
    
    // MARK: - オプション
    private var optionsView: some View {
        HStack {
            Toggle("トレンドライン", isOn: $showTrendLine)
                .font(.caption)
            
            Spacer()
            
            if let selected = selectedPoint {
                Text("\(dateFormatter.string(from: selected.date)): \(selected.weight, specifier: "%.1f")kg")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - 計算プロパティ
    private var weightChange: Double? {
        guard filteredData.count > 1 else { return nil }
        let first = filteredData.first?.weight ?? 0
        let last = filteredData.last?.weight ?? 0
        return last - first
    }
    
    private var idealWeight: Double? {
        // 身長が分かれば理想体重を計算（BMI 22として）
        // ここでは仮の値として nil を返す
        return nil
    }
    
    // MARK: - Private Methods
    private func updateSelectedPoint(at location: CGPoint, geometry: GeometryProxy, chartProxy: ChartProxy) {
        let frame = geometry[chartProxy.plotAreaFrame]
        let origin = frame.origin
        
        guard frame.contains(location) else {
            selectedPoint = nil
            return
        }
        
        let relativeXPosition = location.x - origin.x
        let relativeXRatio = relativeXPosition / frame.width
        
        guard let minDate = filteredData.first?.date,
              let maxDate = filteredData.last?.date else { return }
        
        let timeInterval = maxDate.timeIntervalSince(minDate)
        let targetDate = minDate.addingTimeInterval(timeInterval * relativeXRatio)
        
        // 最も近いデータポイントを見つける
        selectedPoint = filteredData.min { first, second in
            abs(first.date.timeIntervalSince(targetDate)) < abs(second.date.timeIntervalSince(targetDate))
        }
    }
    
    private func calculateSlope(xValues: [Double], yValues: [Double]) -> Double {
        let n = Double(xValues.count)
        let sumX = xValues.reduce(0, +)
        let sumY = yValues.reduce(0, +)
        let sumXY = zip(xValues, yValues).map(*).reduce(0, +)
        let sumXX = xValues.map { $0 * $0 }.reduce(0, +)
        
        return (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX)
    }
    
    private func calculateIntercept(xValues: [Double], yValues: [Double], slope: Double) -> Double {
        let meanX = xValues.average
        let meanY = yValues.average
        return meanY - slope * meanX
    }
}

// MARK: - 統計カード
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

// MARK: - 体重データモデル
struct WeightData: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let bodyFat: Double?
    
    init(date: Date, weight: Double, bodyFat: Double? = nil) {
        self.date = date
        self.weight = weight
        self.bodyFat = bodyFat
    }
}

// MARK: - 日付フォーマッター
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()

// MARK: - プレビュー用サンプルデータ
extension WeightData {
    static var sampleData: [WeightData] {
        let calendar = Calendar.current
        let now = Date()
        var baseWeight = 70.0
        
        return (0..<60).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { return nil }
            
            // 徐々に体重が減少するトレンドを作成
            let randomVariation = Double.random(in: -0.5...0.5)
            let trendChange = Double(dayOffset) * -0.02 // 1日あたり0.02kg減少
            let weight = baseWeight + trendChange + randomVariation
            
            let bodyFat = Double.random(in: 15...25)
            
            return WeightData(date: date, weight: weight, bodyFat: bodyFat)
        }.reversed()
    }
}
