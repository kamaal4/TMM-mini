//
//  DashboardView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: DashboardViewModel
    @State private var showCelebration = false
    
    init() {
        // Initialize with shared context - will be updated when view appears
        _viewModel = StateObject(wrappedValue: DashboardViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor
                .ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.todayMetrics == nil {
                LoadingView()
            } else if let error = viewModel.error {
                ErrorStateView(
                    title: "Error Loading Data",
                    message: error.localizedDescription,
                    actionTitle: "Retry"
                ) {
                    Task {
                        await viewModel.refreshData()
                    }
                }
            } else if viewModel.todayMetrics == nil && viewModel.weeklyMetrics.isEmpty {
                EmptyStateView(
                    icon: "figure.walk",
                    title: "No Data Yet",
                    message: "Start moving to see your activity data here.",
                    actionTitle: "Refresh",
                    action: {
                        Task {
                            await viewModel.refreshData()
                        }
                    }
                )
            } else {
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
                        DashboardHeader(
                            onSimulateGoal: {
                                viewModel.simulateGoalReached()
                                showCelebration = true
                            }
                        )
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.md)
                        
                        // Circular Progress Ring
                        if let today = viewModel.todayMetrics {
                            CircularProgressView(
                                progress: viewModel.stepProgress,
                                value: today.steps,
                                unit: "\(viewModel.stepGoalValue) steps",
                                icon: "figure.walk"
                            )
                            .padding(.vertical, Spacing.md)
                            .accessibilityLabel("Step progress: \(today.steps) of \(viewModel.stepGoalValue) steps")
                            .accessibilityValue("\(Int(viewModel.stepProgress * 100)) percent complete")
                        }
                        
                        // Metrics Grid
                        if let today = viewModel.todayMetrics {
                            HStack(spacing: Spacing.md) {
                                MetricCard(
                                    title: "Calories",
                                    value: "\(Int(today.activeCalories))",
                                    unit: "kcal",
                                    icon: "flame.fill",
                                    iconColor: .caloriesColor,
                                    progress: viewModel.calorieProgress,
                                    progressColor: .caloriesColor
                                )
                                
                                MetricCard(
                                    title: "Intake",
                                    value: "0",
                                    unit: "kcal",
                                    icon: "fork.knife",
                                    iconColor: .proteinColor,
                                    progress: 0.0,
                                    progressColor: .proteinColor
                                )
                            }
                            .padding(.horizontal, Spacing.lg)
                        }
                        
                        // Weekly Trend Chart
                        if !viewModel.weeklyMetrics.isEmpty {
                            TrendChartView(data: viewModel.weeklyMetrics)
                                .padding(.horizontal, Spacing.lg)
                        }
                        
                        // Insight Cards
                        if let bestDay = viewModel.bestDay {
                            HStack(spacing: Spacing.md) {
                                InsightCard(
                                    title: "Best Day",
                                    subtitle: bestDay.date.weekdayShort,
                                    value: "\(bestDay.steps)",
                                    unit: "Steps",
                                    icon: "trophy.fill",
                                    iconColor: .yellow.opacity(0.8),
                                    valueColor: .primaryColor
                                )
                                
                                if let comparison = viewModel.weeklyComparisonText {
                                    InsightCard(
                                        title: "vs Last Week",
                                        subtitle: comparison.isAhead ? "Ahead" : "Behind",
                                        value: comparison.text,
                                        unit: "",
                                        icon: comparison.isAhead ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill",
                                        iconColor: comparison.isAhead ? .green.opacity(0.8) : .orange.opacity(0.8),
                                        valueColor: comparison.isAhead ? .green : .orange
                                    )
                                } else {
                                    InsightCard(
                                        title: "7-Day Avg",
                                        subtitle: "Average",
                                        value: "\(viewModel.weeklyAverage)",
                                        unit: "Steps/day",
                                        icon: "chart.line.uptrend.xyaxis",
                                        iconColor: .primaryColor,
                                        valueColor: AppTheme.textPrimary
                                    )
                                }
                            }
                            .padding(.horizontal, Spacing.lg)
                        }
                        
                        // Sync Status (Bonus Feature)
                        if let lastSync = HealthKitManager.shared.lastSyncDate {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.captionSmall)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Text("Last sync: \(lastSync, style: .relative)")
                                    .font(.captionSmall)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                if HealthKitManager.shared.updateCount > 0 {
                                    Text("• \(HealthKitManager.shared.updateCount) updates")
                                        .font(.captionSmall)
                                        .foregroundColor(.primaryColor)
                                }
                            }
                            .padding(.top, Spacing.sm)
                            .padding(.bottom, Spacing.xl)
                        }
                    }
                }
            }
        }
        .overlay {
            if showCelebration {
                GoalCelebrationView(isPresented: $showCelebration)
            }
        }
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
}

struct DashboardHeader: View {
    let onSimulateGoal: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hello, Alex")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text("Today")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
            }
            
            Spacer()
            
            Button(action: onSimulateGoal) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                    Text("Simulate Goal")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .foregroundColor(.primaryColor)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color.primaryColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.full)
                        .stroke(Color.primaryColor.opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(CornerRadius.full)
            }
            .accessibilityLabel("Simulate goal reached")
            .accessibilityHint("Double tap to simulate reaching your daily step goal")
        }
    }
}

struct GoalCelebrationView: View {
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            VStack(spacing: Spacing.lg) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.primaryColor)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("Goal Reached!")
                    .font(.displayMedium)
                    .foregroundColor(AppTheme.textPrimary)
                    .opacity(opacity)
                
                Text("You've hit your daily step goal. Keep it up!")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(opacity)
            }
            .padding(Spacing.xl)
            .background(AppTheme.cardColor)
            .cornerRadius(CornerRadius.xl)
            .padding(Spacing.xl)
            .scaleEffect(scale)
        }
        .onAppear {
            HapticManager.notification(type: .success)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

