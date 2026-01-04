//
//  OnboardingView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI
import Foundation

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var isComplete: Bool
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Page Indicators
                    HStack(spacing: Spacing.md) {
                        ForEach(0..<4) { index in
                            if index == 1 {
                                Capsule()
                                    .fill(Color.primaryColor)
                                    .frame(width: 24, height: 4)
                                    .primaryShadow()
                            } else {
                                Circle()
                                    .fill(Color.primaryColor.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                    
                    // Hero Visual
                    VStack(spacing: Spacing.lg) {
                        ZStack {
                            Circle()
                                .fill(Color.surfaceDark)
                                .frame(width: 128, height: 128)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            Circle()
                                .fill(Color.primaryColor.opacity(0.1))
                                .frame(width: 128, height: 128)
                                .blur(radius: 20)
                            
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.primaryColor)
                                .primaryShadow()
                            
                            Circle()
                                .stroke(Color.primaryColor.opacity(0.2), lineWidth: 2)
                                .frame(width: 128, height: 128)
                                .scaleEffect(1.2)
                                .opacity(0.5)
                        }
                        .padding(.top, Spacing.xl)
                    }
                    
                    // Headline Text
                    VStack(spacing: Spacing.sm) {
                        HStack(spacing: 0) {
                            Text("Sync Your ")
                                .font(.displayLarge)
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Health Data")
                                .font(.displayLarge)
                                .foregroundColor(.primaryColor)
                        }
                        
                        Text("To provide accurate insights and personalized calorie goals, we need to sync with your Apple Health data.")
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.sm)
                    }
                    .padding(.top, Spacing.xl)
                    .padding(.bottom, Spacing.lg)
                    
                    // Benefit Bullets
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        BenefitRow(
                            icon: "checkmark.circle.fill",
                            title: "Accurate Step Counting",
                            description: "Automatically import steps without draining battery."
                        )
                        
                        BenefitRow(
                            icon: "bolt.fill",
                            title: "Real-time Active Energy",
                            description: "Precise calorie burn calculation from workouts."
                        )
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                    
                    // Visual Toggles
                    CardView(
                        cornerRadius: CornerRadius.md,
                        padding: Spacing.md,
                        backgroundColor: Color.surfaceDark
                    ) {
                        VStack(spacing: Spacing.md) {
                            PermissionToggleRow(
                                icon: "figure.walk",
                                title: "Steps",
                                isEnabled: true
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.05))
                            
                            PermissionToggleRow(
                                icon: "flame.fill",
                                title: "Active Energy",
                                isEnabled: true
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                    
                    // Limited Mode State
                    if viewModel.showLimitedMode {
                        LimitedModeView(
                            onOpenSettings: viewModel.openSettings,
                            onRetry: viewModel.retryAuthorization
                        )
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.xl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // CTA Button
                    VStack(spacing: Spacing.md) {
                        PrimaryButton(
                            title: "Connect Health",
                            icon: "arrow.forward"
                        ) {
                            Task { @MainActor in
                                await viewModel.requestHealthPermissions()
                                
                                // Always check if authorized after the request completes
                                // Check both authorizationStatus and shouldCompleteOnboarding flag
                                // Also do a direct status check as a fallback
                                let directStatusCheck = HealthKitManager.shared.getAuthorizationStatus()
                                
                                if viewModel.authorizationStatus == .authorized || viewModel.shouldCompleteOnboarding || directStatusCheck == .authorized {
                                    withAnimation {
                                        isComplete = true
                                    }
                                }
                            }
                        }
                        .disabled(viewModel.isRequesting)
                        .opacity(viewModel.isRequesting ? 0.6 : 1.0)
                        
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                            Text("Your data stays on your device and is never sold.")
                                .font(.captionSmall)
                        }
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.top, Spacing.sm)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .onAppear {
            // Check authorization status when view appears
            viewModel.checkAuthorizationStatus()
            if viewModel.authorizationStatus == .authorized || viewModel.shouldCompleteOnboarding {
                withAnimation {
                    isComplete = true
                }
            }
        }
        .onChange(of: viewModel.authorizationStatus) { _, newStatus in
            if newStatus == .authorized {
                withAnimation {
                    isComplete = true
                }
            }
        }
        .onChange(of: viewModel.shouldCompleteOnboarding) { _, shouldComplete in
            if shouldComplete {
                withAnimation {
                    isComplete = true
                }
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.primaryColor.opacity(0.1))
                    .frame(width: 24, height: 24)
                
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(description)
                    .font(.bodySmall)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
}

struct PermissionToggleRow: View {
    let icon: String
    let title: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.backgroundDark)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.primaryColor)
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Spacer()
            
            ZStack(alignment: isEnabled ? .trailing : .leading) {
                Capsule()
                    .fill(isEnabled ? Color.primaryColor : Color.gray.opacity(0.3))
                    .frame(width: 48, height: 28)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .padding(4)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEnabled)
        }
    }
}

struct LimitedModeView: View {
    let onOpenSettings: () -> Void
    let onRetry: () -> Void
    
    var body: some View {
        CardView(
            cornerRadius: CornerRadius.md,
            padding: Spacing.md,
            backgroundColor: Color.red.opacity(0.1)
        ) {
            HStack(alignment: .top, spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Limited Mode Active")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Without health access, automatic tracking is disabled. Please enable permissions in Settings to use premium features.")
                        .font(.bodySmall)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    HStack(spacing: Spacing.md) {
                        Button(action: onOpenSettings) {
                            Text("Open Settings")
                                .font(.bodySmall)
                                .foregroundColor(.white)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(Color.red)
                                .cornerRadius(CornerRadius.sm)
                        }
                        
                        Button(action: onRetry) {
                            Text("Retry")
                                .font(.bodySmall)
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .cornerRadius(CornerRadius.sm)
                        }
                    }
                    .padding(.top, Spacing.xs)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    OnboardingView(isComplete: .constant(false))
}

