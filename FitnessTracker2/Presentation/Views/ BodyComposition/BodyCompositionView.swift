//
//  BodyCompositionView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI
import CoreData

struct BodyCompositionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @State private var showingAddEntry = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BodyComposition.date, ascending: false)],
        animation: .default)
    private var bodyCompositions: FetchedResults<BodyComposition>
    
    var latestEntry: BodyComposition? {
        bodyCompositions.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 現在の体組成表示
                    CurrentStatsCard(bodyComposition: latestEntry)
                    
                    // 基礎代謝計算結果
                    BMRCard(bodyComposition: latestEntry)
                    
                    // 履歴グラフ（簡易版）
                    if !bodyCompositions.isEmpty {
                        HistoryChartCard(bodyCompositions: Array(bodyCompositions.prefix(30)))
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("体組成管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddEntry = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddBodyCompositionView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(healthKitManager)
            }
        }
    }
}

// MARK: - 現在の体組成カード
struct CurrentStatsCard: View {
    let bodyComposition: BodyComposition?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("現在の体組成")
                .font(.headline)
            
            if let composition = bodyComposition {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    StatItem(title: "身長", value: "\(Int(composition.height))cm", color: .blue)
                    StatItem(title: "体重", value: String(format: "%.1fkg", composition.weight), color: .green)
                    
                    if composition.bodyFatPercentage > 0 {
                        StatItem(title: "体脂肪率", value: String(format: "%.1f%%", composition.bodyFatPercentage), color: .orange)
                    }
                    
                    StatItem(title: "BMI", value: String(format: "%.1f", calculateBMI(composition)), color: .purple)
                }
                
                Text("最終更新: \(composition.date, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
            } else {
                Text("データがありません")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    private func calculateBMI(_ composition: BodyComposition) -> Double {
        let heightInMeters = composition.height / 100
        return composition.weight / (heightInMeters * heightInMeters)
    }
}

// MARK: - 統計アイテム
struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

// MARK: - 基礎代謝カード
struct BMRCard: View {
    let bodyComposition: BodyComposition?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("基礎代謝")
                .font(.headline)
            
            if let composition = bodyComposition {
                HStack {
                    VStack(alignment: .leading) {
                        Text("基礎代謝量 (BMR)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(composition.basalMetabolicRate))kcal/日")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("活動代謝量 (TDEE)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(composition.basalMetabolicRate * 1.6))kcal/日")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
                
                Text("※ 活動代謝量は軽度の活動を想定した推定値です")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("体組成データを入力してください")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 履歴グラフカード
struct HistoryChartCard: View {
    let bodyCompositions: [BodyComposition]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("体重の推移")
                .font(.headline)
            
            // 簡易グラフ表示
            WeightChart(data: bodyCompositions)
                .frame(height: 200)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// MARK: - 体重グラフ
struct WeightChart: View {
    let data: [BodyComposition]
    
    var body: some View {
        GeometryReader { geometry in
            let maxWeight = data.map { $0.weight }.max() ?? 100
            let minWeight = data.map { $0.weight }.min() ?? 50
            let weightRange = maxWeight - minWeight
            
            Path { path in
                let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                
                for (index, composition) in data.enumerated() {
                    let x = CGFloat(index) * stepX
                    let normalizedWeight = (composition.weight - minWeight) / max(weightRange, 1)
                    let y = geometry.size.height - (normalizedWeight * geometry.size.height)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.green, lineWidth: 2)
            
            // データポイント
            ForEach(Array(data.enumerated()), id: \.offset) { index, composition in
                let x = CGFloat(index) * (geometry.size.width / CGFloat(max(data.count - 1, 1)))
                let normalizedWeight = (composition.weight - minWeight) / max(weightRange, 1)
                let y = geometry.size.height - (normalizedWeight * geometry.size.height)
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                    .position(x: x, y: y)
            }
        }
    }
}

// MARK: - 日付フォーマッター
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()

struct BodyCompositionView_Previews: PreviewProvider {
    static var previews: some View {
        BodyCompositionView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(HealthKitManager())
    }
}
