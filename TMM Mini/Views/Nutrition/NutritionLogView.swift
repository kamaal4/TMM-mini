//
//  NutritionLogView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI
import CoreData

struct NutritionLogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: NutritionLogViewModel
    @State private var showScanView = false
    
    init() {
        _viewModel = StateObject(wrappedValue: NutritionLogViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    Text("Nutrition Log")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.md)
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Daily Calories Summary
                        DailyCaloriesSummary(totals: viewModel.dailyTotals)
                            .padding(.horizontal, Spacing.md)
                        
                        // Macro Stats
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.md) {
                                MacroStatCard(
                                    title: "Protein",
                                    value: "\(Int(viewModel.dailyTotals.protein))g",
                                    target: "180g",
                                    progress: viewModel.dailyTotals.protein / 180.0,
                                    color: .proteinColor,
                                    icon: "egg.fill"
                                )
                                
                                MacroStatCard(
                                    title: "Carbs",
                                    value: "\(Int(viewModel.dailyTotals.carbs))g",
                                    target: "250g",
                                    progress: viewModel.dailyTotals.carbs / 250.0,
                                    color: .carbsColor,
                                    icon: "leaf.fill"
                                )
                                
                                MacroStatCard(
                                    title: "Fat",
                                    value: "\(Int(viewModel.dailyTotals.fat))g",
                                    target: "70g",
                                    progress: viewModel.dailyTotals.fat / 70.0,
                                    color: .fatColor,
                                    icon: "drop.fill"
                                )
                            }
                            .padding(.horizontal, Spacing.md)
                        }
                        
                        // Meal List Header
                        HStack {
                            Text("Today's Meals")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Text("Edit")
                                    .font(.bodySmall)
                                    .foregroundColor(.primaryColor)
                            }
                            .accessibilityLabel("Edit meals")
                        }
                        .padding(.horizontal, Spacing.md)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Today's meals")
                        
                        // Meal List
                        if viewModel.meals.isEmpty {
                            EmptyStateView(
                                icon: "fork.knife",
                                title: "No meals logged yet",
                                message: "Start tracking your nutrition to hit your goals."
                            )
                            .frame(height: 300)
                            .padding(.horizontal, Spacing.md)
                        } else {
                            VStack(spacing: Spacing.md) {
                                ForEach(viewModel.meals, id: \.id) { meal in
                                    MealRow(meal: meal)
                                        .padding(.horizontal, Spacing.md)
                                }
                            }
                        }
                        
                        Spacer(minLength: 100) // Space for bottom sheet
                    }
                    .padding(.top, Spacing.sm)
                }
            }
            
            // Floating Action Buttons
            VStack {
                Spacer()
                HStack(spacing: Spacing.md) {
                    Spacer()
                    
                    // Scan Button (compact)
                    Button(action: {
                        showScanView = true
                    }) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 48, height: 48)
                            .background(AppTheme.cardColor)
                            .cornerRadius(24)
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.cardStroke, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                    }
                    .accessibilityLabel("Scan barcode")
                    
                    // Log Meal Button (primary)
                    Button(action: {
                        viewModel.showMealForm = true
                        HapticManager.impact(style: .light)
                    }) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                            Text("Log Meal")
                                .font(.headline)
                        }
                        .foregroundColor(.backgroundDark)
                        .frame(height: 48)
                        .padding(.horizontal, Spacing.lg)
                        .background(Color.primaryColor)
                        .cornerRadius(CornerRadius.full)
                        .primaryShadow()
                    }
                    .accessibilityLabel("Log meal")
                    .accessibilityHint("Double tap to open meal entry form")
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
            }
            
            // Bottom Sheet
            if viewModel.showMealForm {
                VStack {
                    Spacer()
                    MealFormView(viewModel: viewModel, isPresented: $viewModel.showMealForm)
                        .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .sheet(isPresented: $showScanView) {
            ScannerView(isPresented: $showScanView) { code in
                viewModel.handleScannedCode(code)
            }
        }
        .onAppear {
            viewModel.loadMeals()
        }
    }
}

struct DailyCaloriesSummary: View {
    let totals: (calories: Int, protein: Double, carbs: Double, fat: Double)
    private let calorieGoal = 2400
    
    var progress: Double {
        min(1.0, Double(totals.calories) / Double(calorieGoal))
    }
    
    var remaining: Int {
        max(0, calorieGoal - totals.calories)
    }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text("Daily Calories")
                    .font(.bodySmall)
                    .foregroundColor(AppTheme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(totals.calories)")
                        .font(.headline)
                        .foregroundColor(.primaryColor)
                        .monospacedDigit()
                    
                    Text("/ \(calorieGoal) Kcal")
                        .font(.bodySmall)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                        .cornerRadius(8)
                    
                    Rectangle()
                        .fill(Color.primaryColor)
                        .frame(width: geometry.size.width * progress, height: 16)
                        .cornerRadius(8)
                        .primaryShadow()
                }
            }
            .frame(height: 16)
            
            Text("\(remaining) remaining")
                .font(.captionSmall)
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(Spacing.md)
        .background(AppTheme.cardColor)
        .cornerRadius(CornerRadius.lg)
    }
}

struct MacroStatCard: View {
    let title: String
    let value: String
    let target: String
    let progress: Double
    let color: Color
    let icon: String
    
    var body: some View {
        CardView(padding: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("of \(target)")
                        .font(.captionSmall)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.black.opacity(0.2))
                        Rectangle()
                            .fill(color)
                            .frame(width: geometry.size.width * min(1.0, progress))
                    }
                }
                .frame(height: 4)
                .cornerRadius(2)
            }
            .frame(width: 120)
        }
    }
}

struct MealRow: View {
    let meal: MealModel
    
    var mealType: String {
        let hour = Calendar.current.component(.hour, from: meal.timestamp)
        if hour < 11 {
            return "Breakfast"
        } else if hour < 15 {
            return "Lunch"
        } else if hour < 18 {
            return "Snack"
        } else {
            return "Dinner"
        }
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: meal.timestamp)
    }
    
    var iconColor: Color {
        switch mealType {
        case "Breakfast": return .orange
        case "Lunch": return .green
        case "Snack": return .purple
        default: return .blue
        }
    }
    
    var body: some View {
        CardView(padding: Spacing.md) {
            HStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: iconForMealType(mealType))
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }
                
                // Meal Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.name)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("\(mealType) • \(timeString)")
                        .font(.captionSmall)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    // Macro chips
                    HStack(spacing: Spacing.xs) {
                        if meal.protein > 0 {
                            MacroChip(value: Int(meal.protein), unit: "P", color: .proteinColor)
                        }
                        if meal.carbs > 0 {
                            MacroChip(value: Int(meal.carbs), unit: "C", color: .carbsColor)
                        }
                        if meal.fat > 0 {
                            MacroChip(value: Int(meal.fat), unit: "F", color: .fatColor)
                        }
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
                
                // Calories
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(meal.calories)")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                        .monospacedDigit()
                    
                    Text("kcal")
                        .font(.captionSmall)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }
    
    private func iconForMealType(_ type: String) -> String {
        switch type {
        case "Breakfast": return "sunrise.fill"
        case "Lunch": return "sun.max.fill"
        case "Snack": return "leaf.fill"
        default: return "moon.fill"
        }
    }
}

struct MacroChip: View {
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        Text("\(value)\(unit)")
            .font(.captionSmall)
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.1))
            .cornerRadius(4)
    }
}

struct ScanPlaceholderView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Barcode Scanner")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Point your camera at a barcode to scan nutrition information")
                        .font(.bodySmall)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }
            }
            .navigationTitle("Scan Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.primaryColor)
                }
            }
        }
    }
}

#Preview {
    NutritionLogView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

