//
//  PrimaryButton.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    var action: () -> Void
    @State private var isPressed = false
    
    init(
        title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticManager.impact(style: .medium)
            action()
        }) {
            HStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.backgroundDark)
                
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.backgroundDark)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.primaryColor)
            .cornerRadius(CornerRadius.md)
            .primaryShadow()
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
        .accessibilityHint("Double tap to activate")
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

