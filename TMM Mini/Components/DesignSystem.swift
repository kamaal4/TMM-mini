//
//  DesignSystem.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI

// MARK: - Colors
extension Color {
    static let primaryColor = Color(hex: "13eca4")
    static let primaryDark = Color(hex: "0ba876")
    static let backgroundLight = Color(hex: "f6f8f7")
    static let backgroundDark = Color(hex: "101010")
    static let backgroundDarkAlt = Color(hex: "10221c")
    static let cardDark = Color(hex: "1c1c1e")
    static let cardDarkAlt = Color(hex: "1c322a")
    static let surfaceDark = Color(hex: "1a2e26")
    static let inputDark = Color(hex: "23483c")
    static let textSecondaryBase = Color(hex: "9CA3AF")
    
    // Macro colors
    static let proteinColor = Color(hex: "60A5FA") // Blue
    static let carbsColor = Color(hex: "FB923C") // Orange
    static let fatColor = Color(hex: "FBBF24") // Yellow
    static let caloriesColor = Color(hex: "F97316") // Orange-red
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
extension Font {
    static func display(size: CGFloat, weight: Weight = .regular) -> Font {
        // Using SF Pro as iOS equivalent to Manrope
        return .system(size: size, weight: weight, design: .default)
    }
    
    static let displayLarge = Font.display(size: 32, weight: .bold)
    static let displayMedium = Font.display(size: 24, weight: .bold)
    static let displaySmall = Font.display(size: 20, weight: .semibold)
    
    static let headline = Font.display(size: 18, weight: .bold)
    static let title = Font.display(size: 16, weight: .semibold)
    static let body = Font.display(size: 16, weight: .regular)
    static let bodySmall = Font.display(size: 14, weight: .regular)
    static let caption = Font.display(size: 12, weight: .medium)
    static let captionSmall = Font.display(size: 10, weight: .medium)
    static let label = Font.display(size: 12, weight: .semibold)
    static let labelSmall = Font.display(size: 10, weight: .semibold)
}

// MARK: - Spacing
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Shadows
extension View {
    func primaryShadow() -> some View {
        self.shadow(color: Color.primaryColor.opacity(0.3), radius: 10, x: 0, y: 0)
    }
    
    func cardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Theme
struct AppTheme {
    static var backgroundColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(Color.backgroundDark) : UIColor(Color.backgroundLight)
        })
    }
    
    static var cardColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(Color.cardDark) : UIColor.white
        })
    }
    
    static var textPrimary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        })
    }
    
    static var textSecondary: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(Color.textSecondaryBase)
            } else {
                return UIColor(Color(hex: "4B5563"))
            }
        })
    }

    static var mutedFill: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(white: 1.0, alpha: 0.12)
            } else {
                return UIColor(white: 0.0, alpha: 0.08)
            }
        })
    }
    
    static var cardStroke: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(white: 1.0, alpha: 0.05)
            } else {
                return UIColor(white: 0.0, alpha: 0.06)
            }
        })
    }
}

