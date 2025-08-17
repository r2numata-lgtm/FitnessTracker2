//
//  LoadingView.swift
//  FitnessTracker2
//
//  Created by Assistant on 2025/08/17.
//

import SwiftUI

struct LoadingView: View {
    let message: String?
    
    init(message: String? = "読み込み中...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct LoadingOverlay: View {
    let message: String?
    
    init(message: String? = "読み込み中...") {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                if let message = message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            .padding(24)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LoadingView()
            LoadingOverlay()
        }
    }
}
