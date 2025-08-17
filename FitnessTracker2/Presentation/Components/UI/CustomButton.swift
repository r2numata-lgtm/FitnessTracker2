//
//  CustomButton.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

// MARK: - カスタムボタンスタイル
struct CustomButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(style.backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - ボタンスタイル定義
enum ButtonStyle {
    case primary
    case secondary
    case destructive
    case outline
    case text
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return .blue
        case .secondary:
            return Color(.systemGray6)
        case .destructive:
            return .red
        case .outline, .text:
            return .clear
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .destructive:
            return .white
        case .secondary:
            return .primary
        case .outline:
            return .blue
        case .text:
            return .blue
        }
    }
    
    var borderColor: Color {
        switch self {
        case .outline:
            return .blue
        default:
            return .clear
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .outline:
            return 1
        default:
            return 0
        }
    }
}

// MARK: - フローティングアクションボタン
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - アイコンボタン
struct IconButton: View {
    let icon: String
    let size: CGFloat
    let color: Color
    let backgroundColor: Color?
    let action: () -> Void
    
    init(icon: String, size: CGFloat = 24, color: Color = .primary, backgroundColor: Color? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.color = color
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(color)
                .frame(width: size + 16, height: size + 16)
                .background(backgroundColor)
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - セグメントボタン
struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - プレビュー
struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CustomButton("保存", icon: "checkmark", style: .primary) {
                print("保存ボタンがタップされました")
            }
            
            CustomButton("キャンセル", style: .secondary) {
                print("キャンセルボタンがタップされました")
            }
            
            CustomButton("削除", icon: "trash", style: .destructive) {
                print("削除ボタンがタップされました")
            }
            
            CustomButton("編集", style: .outline) {
                print("編集ボタンがタップされました")
            }
            
            FloatingActionButton(icon: "plus") {
                print("FABがタップされました")
            }
            
            IconButton(icon: "heart", color: .red, backgroundColor: Color.red.opacity(0.1)) {
                print("ハートボタンがタップされました")
            }
            
            HStack {
                SegmentButton(title: "今日", isSelected: true) {
                    print("今日がタップされました")
                }
                SegmentButton(title: "週", isSelected: false) {
                    print("週がタップされました")
                }
                SegmentButton(title: "月", isSelected: false) {
                    print("月がタップされました")
                }
            }
        }
        .padding()
    }
}
