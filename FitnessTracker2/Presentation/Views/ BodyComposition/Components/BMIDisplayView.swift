//
//  BMIDisplayView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - BMI表示ビュー
struct BMIDisplayView: View {
    let bmi: Double
    let height: Double
    let weight: Double
    let idealWeight: Double
    
    @State private var showDetails: Bool = false
    
    private var bmiCategory: BMICategory {
        BMICategory.category(for: bmi)
    }
    
    private var weightDifference: Double {
        weight - idealWeight
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // メインBMI表示
            mainBMICard
            
            // 詳細情報
            if showDetails {
                detailsSection
            }
            
            // 詳細表示切り替えボタン
            toggleButton
        }
    }
    
    // MARK: - メインBMIカード
    private var mainBMICard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("BMI")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // BMI値
                Text("\(bmi, specifier: "%.1f")")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(bmiCategory.color)
            }
            
            // BMI分類
            HStack {
                Text(bmiCategory.rawValue)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(bmiCategory.color)
                
                Spacer()
                
                // BMIインジケーター
                bmiIndicator
            }
            
            // BMIゲージ
            bmiGauge
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(bmiCategory.color.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    // MARK: - BMIインジケーター
    private var bmiIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(bmiCategory.color)
                .frame(width: 8, height: 8)
            
            Text(getBMIStatus())
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - BMIゲージ
    private var bmiGauge: some View {
        VStack(spacing: 8) {
            // ゲージバー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    // BMI範囲カラー
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(BMICategory.underweight.color)
                            .frame(width: geometry.size.width * 0.185) // 18.5/40
                        
                        Rectangle()
                            .fill(BMICategory.normal.color)
                            .frame(width: geometry.size.width * 0.165) // 6.5/40
                        
                        Rectangle()
                            .fill(BMICategory.overweight.color)
                            .frame(width: geometry.size.width * 0.125) // 5/40
                        
                        Rectangle()
                            .fill(BMICategory.obeseClass1.color)
                            .frame(width: geometry.size.width * 0.125) // 5/40
                        
                        Rectangle()
                            .fill(BMICategory.obeseClass2.color)
                            .frame(width: geometry.size.width * 0.125) // 5/40
                        
                        Rectangle()
                            .fill(BMICategory.obeseClass3.color)
                    }
                    .frame(height: 8)
                    .cornerRadius(4)
                    .mask(
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                            .cornerRadius(4)
                    )
                    
                    // BMI位置インジケーター
                    let position = min(max(bmi / 40.0, 0), 1) * geometry.size.width
                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(bmiCategory.color, lineWidth: 2)
                        )
                        .position(x: position, y: 8)
                }
            }
            .frame(height: 16)
            
            // ゲージラベル
            HStack {
                Text("18.5")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("25")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("30")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - 詳細セクション
    private var detailsSection: some View {
        VStack(spacing: 12) {
            Divider()
            
            // 体重比較
            weightComparisonView
            
            // アドバイス
            adviceView
            
            // BMI計算式
            calculationView
        }
    }
    
    // MARK: - 体重比較
    private var weightComparisonView: some View {
        VStack(spacing: 8) {
            Text("理想体重との比較")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("現在の体重")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(weight, specifier: "%.1f")kg")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Image(systemName: weightDifference >= 0 ? "arrow.right" : "arrow.left")
                    .foregroundColor(weightDifference >= 0 ? .red : .green)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("理想体重")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(idealWeight, specifier: "%.1f")kg")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            
            // 差分表示
            if abs(weightDifference) > 0.1 {
                HStack {
                    Text(weightDifference > 0 ? "理想体重より" : "理想体重まで")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(abs(weightDifference), specifier: "%.1f")kg")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(weightDifference > 0 ? .red : .blue)
                    
                    Text(weightDifference > 0 ? "重い" : "軽い")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - アドバイス
    private var adviceView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb")
                    .foregroundColor(.orange)
                
                Text("アドバイス")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Text(bmiCategory.advice)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 計算式
    private var calculationView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BMI計算式")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("BMI = 体重(kg) ÷ 身長(m)²")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("= \(weight, specifier: "%.1f") ÷ (\(height/100, specifier: "%.2f"))²")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("= \(bmi, specifier: "%.1f")")
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - トグルボタン
    private var toggleButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                showDetails.toggle()
            }
        }) {
            HStack {
                Text(showDetails ? "詳細を非表示" : "詳細を表示")
                    .font(.caption)
                
                Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                    .font(.caption)
            }
            .foregroundColor(.blue)
        }
    }
    
    // MARK: - Private Methods
    private func getBMIStatus() -> String {
        switch bmi {
        case ..<18.5: return "低い"
        case 18.5..<25: return "理想的"
        case 25..<30: return "やや高い"
        default: return "高い"
        }
    }
}

// MARK: - BMIサマリーカード（簡易版）
struct BMISummaryCard: View {
    let bmi: Double
    let category: BMICategory
    
    var body: some View {
        HStack(spacing: 12) {
            // BMI値
            VStack(spacing: 2) {
                Text("BMI")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(bmi, specifier: "%.1f")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(category.color)
            }
            
            Divider()
                .frame(height: 40)
            
            // 分類
            VStack(alignment: .leading, spacing: 2) {
                Text("分類")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(category.color)
            }
            
            Spacer()
            
            // インジケーター
            Circle()
                .fill(category.color)
                .frame(width: 12, height: 12)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - プレビュー
struct BMIDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            BMIDisplayView(
                bmi: 22.5,
                height: 170,
                weight: 65,
                idealWeight: 63.6
            )
            
            BMISummaryCard(
                bmi: 22.5,
                category: .normal
            )
        }
        .padding()
    }
}
