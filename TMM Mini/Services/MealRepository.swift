//
//  MealRepository.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import Foundation
import CoreData

struct MealModel {
    let id: UUID
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let timestamp: Date
}

class MealRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAllMeals(for date: Date = Date()) -> [MealModel] {
        let startOfDay = date.startOfDay
        let endOfDay = date.endOfDay
        
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Meal.timestamp, ascending: false)]
        
        guard let meals = try? context.fetch(request) else {
            return []
        }
        
        return meals.map { meal in
            MealModel(
                id: meal.id ?? UUID(),
                name: meal.name ?? "",
                calories: Int(meal.calories),
                protein: meal.protein,
                carbs: meal.carbs,
                fat: meal.fat,
                timestamp: meal.timestamp ?? Date()
            )
        }
    }
    
    func saveMeal(_ meal: MealModel) throws {
        let entity = Meal(context: context)
        entity.id = meal.id
        entity.name = meal.name
        entity.calories = Int64(meal.calories)
        entity.protein = meal.protein
        entity.carbs = meal.carbs
        entity.fat = meal.fat
        entity.timestamp = meal.timestamp
        
        try context.save()
    }
    
    func deleteMeal(_ meal: MealModel) throws {
        let request: NSFetchRequest<Meal> = Meal.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", meal.id as CVarArg)
        request.fetchLimit = 1
        
        if let mealToDelete = try? context.fetch(request).first {
            context.delete(mealToDelete)
            try context.save()
        }
    }
    
    func getDailyTotals(for date: Date = Date()) -> (calories: Int, protein: Double, carbs: Double, fat: Double) {
        let meals = getAllMeals(for: date)
        let calories = meals.reduce(0) { $0 + $1.calories }
        let protein = meals.reduce(0.0) { $0 + $1.protein }
        let carbs = meals.reduce(0.0) { $0 + $1.carbs }
        let fat = meals.reduce(0.0) { $0 + $1.fat }
        
        return (calories, protein, carbs, fat)
    }
}

