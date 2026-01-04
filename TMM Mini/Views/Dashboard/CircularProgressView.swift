//
//  CircularProgressView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let value: Int
    let unit: String
    let icon: String
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, value: Int, unit: String, icon: String = "figure.walk", size: CGFloat = 256) {
        self.progress = max(0, min(1, progress))
        self.value = value
        self.unit = unit
        self.icon = icon
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                .frame(width: size, height: size)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color.primaryColor,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .primaryShadow()
            
            // Inner content
            VStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.primaryColor.opacity(0.8))
                    .padding(.bottom, Spacing.xs)
                
                Text("\(value)")
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(AppTheme.textPrimary)
                    .monospacedDigit()
                
                Text("of \(unit)")
                    .font(.bodySmall)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newProgress in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedProgress = newProgress
            }
        }
    }
}

