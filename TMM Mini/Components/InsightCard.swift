//
//  InsightCard.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI

struct InsightCard: View {
    let title: String
    let subtitle: String
    let value: String
    let unit: String
    let icon: String
    let iconColor: Color
    let valueColor: Color
    
    init(
        title: String,
        subtitle: String,
        value: String,
        unit: String,
        icon: String,
        iconColor: Color = .primaryColor,
        valueColor: Color = .primaryColor
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.unit = unit
        self.icon = icon
        self.iconColor = iconColor
        self.valueColor = valueColor
    }
    
    var body: some View {
        CardView(padding: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(title)
                        .font(.label)
                        .foregroundColor(AppTheme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    Spacer()
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                
                Text(subtitle)
                    .font(.bodySmall)
                    .foregroundColor(AppTheme.textPrimary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.headline)
                        .foregroundColor(valueColor)
                        .monospacedDigit()
                    
                    Text(unit)
                        .font(.captionSmall)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
}

