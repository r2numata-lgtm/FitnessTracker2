//
//  CardView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - 基本カードビュー
struct CardView<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let shadowRadius: CGFloat
    
    init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 15,
        backgroundColor: Color = Color(.systemGray6),
        shadowRadius: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.shadowRadius = shadowRadius
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
    }
}

// MARK: - 統計カード
struct StatsCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String?
    let color: Color
    
    init(title: String, value: String, subtitle: String? = nil, icon: String? = nil, color: Color = .blue) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        CardView {
            VStack(spacing: 8) {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.title2)
                    }
                    
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                HStack {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                    Spacer()
                }
                
                if let subtitle = subtitle {
                    HStack {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - プログレスカード
struct ProgressCard: View {
    let title: String
    let current: Double
    let target: Double
    let unit: String
    let color: Color
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }
    
    private var progressText: String {
        "\(Int(current))/\(Int(target)) \(unit)"
    }
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(progressText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                HStack {
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(color)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if progress >= 1.0 {
                        Text("目標達成！")
                            .font(.caption)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
}

// MARK: - アクションカード
struct ActionCard: View {
    let title: String
    let subtitle: String?
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            CardView(backgroundColor: color.opacity(0.1)) {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - サマリーカード
struct SummaryCard: View {
    let title: String
    let items: [SummaryItem]
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.headline)
                
                VStack(spacing: 12) {
                    ForEach(items, id: \.title) { item in
                        HStack {
                            HStack(spacing: 8) {
                                if let icon = item.icon {
                                    Image(systemName: icon)
                                        .foregroundColor(item.color)
                                        .frame(width: 20)
                                }
                                
                                Text(item.title)
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            Text(item.value)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(item.color)
                        }
                    }
                }
            }
        }
    }
}

struct SummaryItem {
    let title: String
    let value: String
    let icon: String?
    let color: Color
    
    init(title: String, value: String, icon: String? = nil, color: Color = .primary) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
    }
}

// MARK: - プレビュー
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 16) {
                StatsCard(
                    title: "今日のカロリー",
                    value: "1,850",
                    subtitle: "目標まであと150kcal",
                    icon: "flame",
                    color: .orange
                )
                
                ProgressCard(
                    title: "歩数",
                    current: 7500,
                    target: 10000,
                    unit: "歩",
                    color: .purple
                )
                
                ActionCard(
                    title: "筋トレを記録",
                    subtitle: "今日のワークアウトを追加",
                    icon: "dumbbell",
                    color: .blue
                ) {
                    print("筋トレ記録がタップされました")
                }
                
                SummaryCard(
                    title: "今日の記録",
                    items: [
                        SummaryItem(title: "筋トレ", value: "3種目", icon: "dumbbell", color: .orange),
                        SummaryItem(title: "食事", value: "4回", icon: "fork.knife", color: .green),
                        SummaryItem(title: "歩数", value: "7,500歩", icon: "figure.walk", color: .purple)
                    ]
                )
            }
            .padding()
        }
    }
}
