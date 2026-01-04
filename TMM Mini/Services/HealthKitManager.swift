//
//  HealthKitManager.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import Foundation
import HealthKit

@MainActor
class HealthKitManager: HealthKitServiceProtocol {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    // HealthKit types we need
    private let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    
    private var readTypes: Set<HKObjectType> {
        [stepCountType, activeEnergyType]
    }
    
    // For bonus feature: incremental updates
    private var observerQueries: [HKObserverQuery] = []
    private var anchoredQueries: [HKAnchoredObjectQuery] = []
    // Store active statistics queries to prevent deallocation
    private var activeStatisticsQueries: [HKStatisticsCollectionQuery] = []
    private var lastAnchor: HKQueryAnchor?
    private var _updateCount = 0
    private var updateHandler: (([DailyHealthMetrics]) -> Void)?
    
    var lastSyncDate: Date? {
        UserDefaults.standard.object(forKey: "HealthKitLastSyncDate") as? Date
    }
    
    var updateCount: Int {
        _updateCount
    }
    
    private init() {
        // Load saved anchor if exists
        if let anchorData = UserDefaults.standard.data(forKey: "HealthKitAnchor"),
           let anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: anchorData) {
            lastAnchor = anchor
        }
    }
    
    func requestAuthorization() async throws -> HealthKitAuthorizationStatus {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKitManager: Health Data not available")
            throw HealthKitError.notAvailable
        }
        
        // Mark that we are about to request permissions
        // We do this BEFORE requesting because if the user dismisses the sheet or 
        // if the system decides not to show it (already determined), code execution continues.
        // We want to ensure we treat this as a "try" regardless of outcome.
        UserDefaults.standard.set(true, forKey: "HasRequestedHealthKit")
        print("HealthKitManager: Set HasRequestedHealthKit to true")
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            print("HealthKitManager: Request authorization returned")
            // After requesting, check status
            return getAuthorizationStatus()
        } catch {
            print("HealthKitManager: Request authorization failed: \(error)")
            // If there's an error, check current status
            return getAuthorizationStatus()
        }
    }
    
    func getAuthorizationStatus() -> HealthKitAuthorizationStatus {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKitManager: Status check - Health Data not available")
            return .denied
        }
        
        // IMPORTANT: We do NOT check `healthStore.authorizationStatus(for:)`.
        // That method returns the status for SHARE (Write) permissions.
        // Since we only requested READ permissions, that method will correctly return
        // .notDetermined or .sharingDenied (if we didn't ask to share).
        // It tells us NOTHING about whether we can Read.
        // Therefore, we trust our "HasRequested" flag.
        
        // Check for our custom flag
        let hasRequested = UserDefaults.standard.bool(forKey: "HasRequestedHealthKit")
        print("HealthKitManager: HasRequested flag: \(hasRequested)")
        
        if hasRequested {
            // Assume authorized if we've requested.
            // Even if the user denied reading in the UI, we can't know that (privacy).
            // We just treat it as authorized and get 0 data if denied.
            print("HealthKitManager: Assuming authorized based on flag")
            return .authorized
        }
        
        // Fallback
        print("HealthKitManager: Returning notDetermined")
        return .notDetermined
    }
    
    func fetchDailyMetrics(for date: Date) async throws -> DailyHealthMetrics? {
        // #region agent log
        DebugLogger.log(location: "HealthKitManager.swift:fetchDailyMetrics", message: "Function called", data: ["date": date.description], hypothesisId: "A")
        // #endregion
        
        // Don't pre-check authorization - HealthKit's status check is unreliable for read-only
        // Just try to execute queries and let them fail if not authorized
        // This matches the reference app's approach
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? date
        // #region agent log
        DebugLogger.log(location: "HealthKitManager.swift:fetchDailyMetrics", message: "Date range calculated", data: [
            "startOfDay": startOfDay.description,
            "endOfDay": endOfDay.description,
            "durationHours": endOfDay.timeIntervalSince(startOfDay) / 3600
        ], hypothesisId: "B")
        // #endregion
        
        // #region agent log
        DebugLogger.log(location: "HealthKitManager.swift:fetchDailyMetrics", message: "Starting parallel fetch", hypothesisId: "C")
        // #endregion
        async let steps = fetchSteps(from: startOfDay, to: endOfDay)
        async let calories = fetchActiveCalories(from: startOfDay, to: endOfDay)
        
        let (stepCount, activeCalories) = try await (steps, calories)
        // #region agent log
        DebugLogger.log(location: "HealthKitManager.swift:fetchDailyMetrics", message: "Fetch completed", data: [
            "steps": stepCount,
            "calories": activeCalories
        ], hypothesisId: "C")
        // #endregion
        
        // Save sync date
        UserDefaults.standard.set(Date(), forKey: "HealthKitLastSyncDate")
        
        let metrics = DailyHealthMetrics(
            date: date,
            steps: stepCount,
            activeCalories: activeCalories
        )
        
        // #region agent log
        DebugLogger.log(location: "HealthKitManager.swift:fetchDailyMetrics", message: "Returning metrics", data: [
            "date": metrics.date.description,
            "steps": metrics.steps,
            "calories": metrics.activeCalories
        ], hypothesisId: "C")
        // #endregion
        
        return metrics
    }
    
    func fetchDailyMetrics(for dates: [Date]) async throws -> [DailyHealthMetrics] {
        // Don't pre-check authorization - just try to fetch and handle errors
        var metrics: [DailyHealthMetrics] = []
        
        for date in dates {
            if let metric = try await fetchDailyMetrics(for: date) {
                metrics.append(metric)
            }
        }
        
        return metrics
    }
    
    private func fetchSteps(from startDate: Date, to endDate: Date) async throws -> Int {
        // #region agent log
        DebugLogger.log(location: "HealthKitManager.swift:fetchSteps", message: "Function called", data: [
            "startDate": startDate.description,
            "endDate": endDate.description,
            "healthKitAvailable": HKHealthStore.isHealthDataAvailable()
        ], hypothesisId: "D")
        // #endregion
        
        guard HKHealthStore.isHealthDataAvailable() else {
            DebugLogger.log(location: "HealthKitManager.swift:fetchSteps", message: "HealthKit not available", hypothesisId: "D")
            return 0
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            // #region agent log
            DebugLogger.log(location: "HealthKitManager.swift:fetchSteps", message: "Creating query", hypothesisId: "D")
            // #endregion
            
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                // Match FitTribe's approach: ignore errors, default to 0
                // #region agent log
                DebugLogger.log(location: "HealthKitManager.swift:fetchSteps", message: "Query handler called", data: [
                    "hasError": error != nil,
                    "errorDescription": error?.localizedDescription ?? "none",
                    "hasResult": result != nil
                ], hypothesisId: "D")
                // #endregion
                
                // Use optional chaining like FitTribe - default to 0 if anything is nil
                let totalSteps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                // #region agent log
                DebugLogger.log(location: "HealthKitManager.swift:fetchSteps", message: "Query completed", data: [
                    "totalSteps": Int(totalSteps),
                    "hasError": error != nil,
                    "hasResult": result != nil
                ], hypothesisId: "D")
                // #endregion
                continuation.resume(returning: Int(totalSteps))
            }
            
            // #region agent log
            DebugLogger.log(location: "HealthKitManager.swift:fetchSteps", message: "Executing query on healthStore", hypothesisId: "D")
            // #endregion
            
            // Execute query - HealthKit retains the query, so we don't need to store it
            healthStore.execute(query)
            
            // #region agent log
            DebugLogger.log(location: "HealthKitManager.swift:fetchSteps", message: "Query executed successfully", hypothesisId: "D")
            // #endregion
        }
    }
    
    private func fetchActiveCalories(from startDate: Date, to endDate: Date) async throws -> Double {
        // #region agent log
        DebugLogger.log(location: "HealthKitManager.swift:fetchActiveCalories", message: "Function called", data: [
            "startDate": startDate.description,
            "endDate": endDate.description
        ], hypothesisId: "D")
        // #endregion
        
        guard HKHealthStore.isHealthDataAvailable() else {
            DebugLogger.log(location: "HealthKitManager.swift:fetchActiveCalories", message: "HealthKit not available", hypothesisId: "D")
            return 0.0
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            // #region agent log
            DebugLogger.log(location: "HealthKitManager.swift:fetchActiveCalories", message: "Creating query", hypothesisId: "D")
            // #endregion
            
            let query = HKStatisticsQuery(
                quantityType: activeEnergyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                // Match FitTribe's approach: ignore errors, default to 0
                // #region agent log
                DebugLogger.log(location: "HealthKitManager.swift:fetchActiveCalories", message: "Query handler called", data: [
                    "hasError": error != nil,
                    "errorDescription": error?.localizedDescription ?? "none",
                    "hasResult": result != nil
                ], hypothesisId: "D")
                // #endregion
                
                // Use optional chaining like FitTribe - default to 0 if anything is nil
                let totalCalories = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0
                // #region agent log
                DebugLogger.log(location: "HealthKitManager.swift:fetchActiveCalories", message: "Query completed", data: [
                    "totalCalories": totalCalories,
                    "hasError": error != nil,
                    "hasResult": result != nil
                ], hypothesisId: "D")
                // #endregion
                continuation.resume(returning: totalCalories)
            }
            
            // #region agent log
            DebugLogger.log(location: "HealthKitManager.swift:fetchActiveCalories", message: "Executing query on healthStore", hypothesisId: "D")
            // #endregion
            
            // Execute query - HealthKit retains the query, so we don't need to store it
            healthStore.execute(query)
            
            // #region agent log
            DebugLogger.log(location: "HealthKitManager.swift:fetchActiveCalories", message: "Query executed successfully", hypothesisId: "D")
            // #endregion
        }
    }
    
    // MARK: - Bonus Feature: Incremental Updates
    
    func startObservingUpdates(completion: @escaping ([DailyHealthMetrics]) -> Void) {
        guard getAuthorizationStatus() == .authorized else {
            return
        }
        
        updateHandler = completion
        
        // Observer query for steps
        let stepsObserverQuery = HKObserverQuery(sampleType: stepCountType, predicate: nil) { [weak self] _, completionHandler, error in
            if error != nil {
                completionHandler()
                return
            }
            
            Task { @MainActor [weak self] in
                await self?.fetchIncrementalUpdates()
                completionHandler()
            }
        }
        
        // Observer query for active energy
        let energyObserverQuery = HKObserverQuery(sampleType: activeEnergyType, predicate: nil) { [weak self] _, completionHandler, error in
            if error != nil {
                completionHandler()
                return
            }
            
            Task { @MainActor [weak self] in
                await self?.fetchIncrementalUpdates()
                completionHandler()
            }
        }
        
        healthStore.execute(stepsObserverQuery)
        healthStore.execute(energyObserverQuery)
        
        observerQueries.append(stepsObserverQuery)
        observerQueries.append(energyObserverQuery)
        
        // Start anchored query for initial fetch
        Task {
            await fetchIncrementalUpdates()
        }
    }
    
    func stopObservingUpdates() {
        observerQueries.forEach { healthStore.stop($0) }
        anchoredQueries.forEach { healthStore.stop($0) }
        observerQueries.removeAll()
        anchoredQueries.removeAll()
        updateHandler = nil
    }
    
    private func fetchIncrementalUpdates() async {
        guard getAuthorizationStatus() == .authorized else {
            return
        }
        
        let today = Date()
        let sevenDaysAgo = today.daysAgo(7)
        
        // Fetch incremental updates for steps
        let stepsAnchoredQuery = HKAnchoredObjectQuery(
            type: stepCountType,
            predicate: HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: today, options: .strictStartDate),
            anchor: lastAnchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, deletedObjects, anchor, error in
            guard let self = self, error == nil else { return }
            
            Task { @MainActor in
                if let anchor = anchor {
                    self.lastAnchor = anchor
                    if let anchorData = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true) {
                        UserDefaults.standard.set(anchorData, forKey: "HealthKitAnchor")
                    }
                }
                
                self._updateCount += samples?.count ?? 0
            }
        }
        
        // Fetch incremental updates for active energy
        let energyAnchoredQuery = HKAnchoredObjectQuery(
            type: activeEnergyType,
            predicate: HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: today, options: .strictStartDate),
            anchor: lastAnchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, deletedObjects, anchor, error in
            guard let self = self, error == nil else { return }
            
            Task { @MainActor in
                if let anchor = anchor {
                    self.lastAnchor = anchor
                    if let anchorData = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true) {
                        UserDefaults.standard.set(anchorData, forKey: "HealthKitAnchor")
                    }
                }
                
                self._updateCount += samples?.count ?? 0
            }
        }
        
        // Execute queries
        healthStore.execute(stepsAnchoredQuery)
        healthStore.execute(energyAnchoredQuery)
        
        // Store queries to stop later if needed
        anchoredQueries.append(stepsAnchoredQuery)
        anchoredQueries.append(energyAnchoredQuery)
        
        // Throttle: Only fetch once per second
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        do {
            let dates = Date.datesForLast7Days()
            let metrics = try await fetchDailyMetrics(for: dates)
            
            // Throttle UI updates
            await MainActor.run {
                updateHandler?(metrics)
                UserDefaults.standard.set(Date(), forKey: "HealthKitLastSyncDate")
            }
        } catch {
            // Handle error silently for incremental updates
        }
    }
}

enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit authorization denied"
        case .fetchFailed:
            return "Failed to fetch health data"
        }
    }
}

