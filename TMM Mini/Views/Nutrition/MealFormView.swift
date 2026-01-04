//
//  MealFormView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI

struct MealFormView: View {
    @ObservedObject var viewModel: NutritionLogViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Handle
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 48, height: 4)
                .padding(.top, Spacing.sm)
            
            // Header
            HStack {
                Text("Add New Entry")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Button(action: {
                    viewModel.resetForm()
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.lg)
            
            ScrollView {
                VStack(spacing: Spacing.md) {
                    // Food Name Input
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Food Name")
                            .font(.label)
                            .foregroundColor(AppTheme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        TextField("e.g. Grilled Salmon", text: $viewModel.formData.name)
                            .textFieldStyle(FormTextFieldStyle())
                    }
                    
                    // Calories Input
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Calories")
                            .font(.label)
                            .foregroundColor(AppTheme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        HStack {
                            TextField("0", text: $viewModel.formData.calories)
                                .keyboardType(.numberPad)
                                .textFieldStyle(FormTextFieldStyle())
                            
                            Text("kcal")
                                .font(.bodySmall)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.trailing, Spacing.md)
                        }
                    }
                    
                    // Macros Row
                    HStack(spacing: Spacing.md) {
                        MacroInputField(
                            label: "Protein (g)",
                            value: $viewModel.formData.protein,
                            color: .proteinColor
                        )
                        
                        MacroInputField(
                            label: "Carbs (g)",
                            value: $viewModel.formData.carbs,
                            color: .carbsColor
                        )
                        
                        MacroInputField(
                            label: "Fat (g)",
                            value: $viewModel.formData.fat,
                            color: .fatColor
                        )
                    }
                    
                    // Save Button
                    Button(action: {
                        viewModel.saveMeal()
                    }) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18))
                            Text("Log Meal")
                                .font(.headline)
                        }
                        .foregroundColor(.backgroundDark)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(viewModel.formData.isValid ? Color.primaryColor : Color.gray.opacity(0.3))
                        .cornerRadius(CornerRadius.md)
                        .primaryShadow()
                    }
                    .disabled(!viewModel.formData.isValid)
                    .accessibilityLabel("Save meal")
                    .accessibilityHint(viewModel.formData.isValid ? "Double tap to save meal" : "Fill in required fields to enable save")
                    .accessibilityValue(viewModel.formData.isValid ? "Ready to save" : "Form incomplete")
                    .padding(.top, Spacing.md)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }
        }
        .background(AppTheme.cardColor)
        .cornerRadius(CornerRadius.xl, corners: [.topLeft, .topRight])
    }
}

struct FormTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.body)
            .foregroundColor(AppTheme.textPrimary)
            .padding(Spacing.md)
            .background(Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor(Color.inputDark) : UIColor.systemGray6
            }))
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

struct MacroInputField: View {
    let label: String
    @Binding var value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label)
                .font(.captionSmall)
                .foregroundColor(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            TextField("0", text: $value)
                .keyboardType(.decimalPad)
                .font(.body)
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(Spacing.md)
                .background(Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ? UIColor(Color.inputDark) : UIColor.systemGray6
                }))
                .cornerRadius(CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(color.opacity(0.3), lineWidth: 2)
                )
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

