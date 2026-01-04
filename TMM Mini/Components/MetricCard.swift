//
//  MetricCard.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let iconColor: Color
    let progress: Double // 0.0 to 1.0
    let progressColor: Color
    
    var body: some View {
        CardView(padding: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(iconColor)
                            .frame(width: 24, height: 24)
                            .background(iconColor.opacity(0.2))
                            .cornerRadius(6)
                        
                        Text(title)
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(iconColor.opacity(0.1))
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(AppTheme.textPrimary)
                        .monospacedDigit()
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(progressColor)
                            .frame(width: geometry.size.width * progress, height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }
        }
    }
}

