//
//  NutritionLogViewModel.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import Foundation
import SwiftUI
import CoreData
import Combine

struct MealFormData {
    var name: String = ""
    var calories: String = ""
    var protein: String = ""
    var carbs: String = ""
    var fat: String = ""
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !calories.isEmpty &&
        Int(calories) != nil &&
        Int(calories) ?? 0 > 0
    }
    
    var mealModel: MealModel? {
        guard isValid,
              let caloriesValue = Int(calories) else {
            return nil
        }
        
        return MealModel(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            calories: caloriesValue,
            protein: Double(protein) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0,
            timestamp: Date()
        )
    }
}

@MainActor
class NutritionLogViewModel: ObservableObject {
    @Published var meals: [MealModel] = []
    @Published var showMealForm = false
    @Published var formData = MealFormData()
    @Published var selectedDate = Date()
    
    private let mealRepository: MealRepository
    
    var dailyTotals: (calories: Int, protein: Double, carbs: Double, fat: Double) {
        mealRepository.getDailyTotals(for: selectedDate)
    }
    
    init(context: NSManagedObjectContext) {
        self.mealRepository = MealRepository(context: context)
        loadMeals()
    }
    
    func loadMeals() {
        meals = mealRepository.getAllMeals(for: selectedDate)
    }
    
    func saveMeal() {
        guard let meal = formData.mealModel else { return }
        
        do {
            try mealRepository.saveMeal(meal)
            HapticManager.notification(type: .success)
            formData = MealFormData()
            showMealForm = false
            loadMeals()
        } catch {
            HapticManager.notification(type: .error)
        }
    }
    
    func deleteMeal(_ meal: MealModel) {
        do {
            try mealRepository.deleteMeal(meal)
            HapticManager.impact(style: .light)
            loadMeals()
        } catch {
            HapticManager.notification(type: .error)
        }
    }
    
    func resetForm() {
        formData = MealFormData()
    }
}

