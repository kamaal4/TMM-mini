//
//  DashboardViewModel.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import Foundation
import SwiftUI
import CoreData
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var todayMetrics: DailyHealthMetrics?
    @Published var weeklyMetrics: [DailyHealthMetrics] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showGoalCelebration = false
    
    private let healthDataRepository: HealthDataRepository
    private let healthKitService: HealthKitServiceProtocol
    
    // Goals
    private let stepGoal = 10000
    private let calorieGoal = 600.0
    
    var stepGoalValue: Int {
        stepGoal
    }
    
    var stepProgress: Double {
        guard let today = todayMetrics else { return 0 }
        return min(1.0, Double(today.steps) / Double(stepGoal))
    }
    
    var calorieProgress: Double {
        guard let today = todayMetrics else { return 0 }
        return min(1.0, today.activeCalories / calorieGoal)
    }
    
    var bestDay: DailyHealthMetrics? {
        weeklyMetrics.max { $0.steps < $1.steps }
    }
    
    var weeklyAverage: Int {
        guard !weeklyMetrics.isEmpty else { return 0 }
        let total = weeklyMetrics.reduce(0) { $0 + $1.steps }
        return total / weeklyMetrics.count
    }
    
    var isGoalReached: Bool {
        guard let today = todayMetrics else { return false }
        return today.steps >= stepGoal
    }
    
    init(
        context: NSManagedObjectContext,
        healthKitService: HealthKitServiceProtocol? = nil
    ) {
        self.healthKitService = healthKitService ?? HealthKitManager.shared
        self.healthDataRepository = HealthDataRepository(context: context, healthKitService: self.healthKitService)
    }
    
    func loadData() async {
        // #region agent log
        DebugLogger.log(location: "DashboardViewModel.swift:loadData", message: "Function called", hypothesisId: "H")
        // #endregion
        isLoading = true
        error = nil
        
        // #region agent log
        let authStatus = healthKitService.getAuthorizationStatus()
        DebugLogger.log(location: "DashboardViewModel.swift:loadData", message: "Authorization status", data: ["status": "\(authStatus)"], hypothesisId: "H")
        // #endregion
        
        // Load cached data first
        // #region agent log
        DebugLogger.log(location: "DashboardViewModel.swift:loadData", message: "Fetching today metrics", hypothesisId: "H")
        // #endregion
        todayMetrics = await healthDataRepository.getTodayMetrics()
        // #region agent log
        DebugLogger.log(location: "DashboardViewModel.swift:loadData", message: "Today metrics received", data: [
            "steps": todayMetrics?.steps ?? -1,
            "calories": todayMetrics?.activeCalories ?? -1
        ], hypothesisId: "H")
        // #endregion
        
        // #region agent log
        DebugLogger.log(location: "DashboardViewModel.swift:loadData", message: "Fetching weekly metrics", hypothesisId: "H")
        // #endregion
        weeklyMetrics = await healthDataRepository.getLast7DaysMetrics()
        // #region agent log
        DebugLogger.log(location: "DashboardViewModel.swift:loadData", message: "Weekly metrics received", data: ["count": weeklyMetrics.count], hypothesisId: "H")
        // #endregion
        
        isLoading = false
        
        // #region agent log
        DebugLogger.log(location: "DashboardViewModel.swift:loadData", message: "Load complete", data: [
            "hasTodayMetrics": todayMetrics != nil,
            "weeklyCount": weeklyMetrics.count
        ], hypothesisId: "H")
        // #endregion
        
        // Check if goal is reached
        if isGoalReached && !showGoalCelebration {
            showGoalCelebration = true
            HapticManager.notification(type: .success)
        }
    }
    
    func simulateGoalReached() {
        guard var today = todayMetrics else { return }
        today = DailyHealthMetrics(
            date: today.date,
            steps: stepGoal,
            activeCalories: today.activeCalories
        )
        todayMetrics = today
        showGoalCelebration = true
        HapticManager.notification(type: .success)
    }
    
    func refreshData() async {
        // #region agent log
        print("DEBUG [DashboardViewModel]: refreshData called")
        // #endregion
        isLoading = true
        error = nil
        
        do {
            let dates = Date.datesForLast7Days()
            // #region agent log
            print("DEBUG [DashboardViewModel]: Refreshing metrics for \(dates.count) dates")
            // #endregion
            
            try await healthDataRepository.refreshMetrics(for: dates)
            
            // #region agent log
            print("DEBUG [DashboardViewModel]: Refresh complete, fetching updated metrics...")
            // #endregion
            
            todayMetrics = await healthDataRepository.getTodayMetrics()
            weeklyMetrics = await healthDataRepository.getLast7DaysMetrics()
            
            // #region agent log
            print("DEBUG [DashboardViewModel]: Refresh complete - today: \(todayMetrics?.steps ?? -1) steps, weekly count: \(weeklyMetrics.count)")
            // #endregion
        } catch {
            // #region agent log
            print("DEBUG [DashboardViewModel]: Error in refreshData: \(error)")
            print("DEBUG [DashboardViewModel]: Error type: \(type(of: error))")
            // #endregion
            self.error = error
        }
        
        isLoading = false
    }
}

