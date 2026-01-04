//
//  CardView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = CornerRadius.lg
    var padding: CGFloat = Spacing.md
    var backgroundColor: Color? = nil
    
    init(
        cornerRadius: CGFloat = CornerRadius.lg,
        padding: CGFloat = Spacing.md,
        backgroundColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor ?? AppTheme.cardColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
    }
}

