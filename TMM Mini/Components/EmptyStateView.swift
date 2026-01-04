//
//  EmptyStateView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    var action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.primaryColor.opacity(0.6))
            
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(message)
                    .font(.bodySmall)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.body)
                        .foregroundColor(.primaryColor)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.primaryColor.opacity(0.1))
                        .cornerRadius(CornerRadius.md)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xl)
    }
}

struct ErrorStateView: View {
    let title: String
    let message: String
    let actionTitle: String
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundColor(.red.opacity(0.6))
            
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(message)
                    .font(.bodySmall)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            
            Button(action: action) {
                Text(actionTitle)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.red)
                    .cornerRadius(CornerRadius.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xl)
    }
}

