//
//  LoadingView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.primaryColor)
            
            Text("Loading...")
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.backgroundColor)
    }
}

struct ShimmerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.05),
                Color.white.opacity(0.1),
                Color.white.opacity(0.05)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .offset(x: isAnimating ? 200 : -200)
        .animation(
            Animation.linear(duration: 1.5)
                .repeatForever(autoreverses: false),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
}

struct SkeletonCard: View {
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 60, height: 20)
                    Spacer()
                }
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 32)
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 6)
            }
            .overlay(
                ShimmerView()
                    .mask(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                    )
            )
        }
    }
}

