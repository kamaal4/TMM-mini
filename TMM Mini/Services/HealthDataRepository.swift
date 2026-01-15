//
//  HealthDataRepository.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import Foundation
import CoreData

class HealthDataRepository {
    private let context: NSManagedObjectContext
    private let healthKitService: HealthKitServiceProtocol
    
    init(context: NSManagedObjectContext, healthKitService: HealthKitServiceProtocol) {
        self.context = context
        self.healthKitService = healthKitService
    }
    
    func getTodayMetrics() async -> DailyHealthMetrics? {
        let today = Date()
        // #region agent log
        DebugLogger.log(location: "HealthDataRepository.swift:getTodayMetrics", message: "Function called", data: ["date": today.description], hypothesisId: "F")
        // #endregion
        
        // First, try to get from cache
        if let cached = getCachedMetrics(for: Date()) {
            // #region agent log
            DebugLogger.log(location: "HealthDataRepository.swift:getTodayMetrics", message: "Found cached data", data: [
                "steps": cached.steps,
                "calories": cached.activeCalories
            ], hypothesisId: "F")
            // #endregion
            // Refresh in background
            Task {
                do {
                    _ = try await refreshMetrics(for: Date())
                } catch {
                    // #region agent log
                    DebugLogger.log(location: "HealthDataRepository.swift:getTodayMetrics", message: "Background refresh failed", data: ["error": error.localizedDescription], hypothesisId: "F")
                    // #endregion
                }
            }
            return cached
        }
        
        // #region agent log
        DebugLogger.log(location: "HealthDataRepository.swift:getTodayMetrics", message: "No cache, fetching from HealthKit", hypothesisId: "F")
        // #endregion
        // If no cache, fetch from HealthKit
        let result: DailyHealthMetrics?
        do {
            result = try await refreshMetrics(for: Date())
        } catch {
            // #region agent log
            DebugLogger.log(location: "HealthDataRepository.swift:getTodayMetrics", message: "Error fetching", data: ["error": error.localizedDescription], hypothesisId: "F")
            // #endregion
            result = nil
        }
        // #region agent log
        DebugLogger.log(location: "HealthDataRepository.swift:getTodayMetrics", message: "Fetch result", data: [
            "steps": result?.steps ?? -1,
            "calories": result?.activeCalories ?? -1
        ], hypothesisId: "F")
        // #endregion
        return result
    }
    
    func getLast7DaysMetrics() async -> [DailyHealthMetrics] {
        let dates = Date.datesForLast7Days()
        
        // Get cached data first
        var cachedMetrics: [DailyHealthMetrics] = []
        for date in dates {
            if let cached = getCachedMetrics(for: date) {
                cachedMetrics.append(cached)
            }
        }
        
        // Refresh in background
        Task {
            do {
                try await refreshMetrics(for: dates)
            } catch {
                // #region agent log
                print("DEBUG [HealthDataRepository]: Background refresh error: \(error)")
                // #endregion
            }
        }
        
        return cachedMetrics
    }
    
    func getPreviousWeekMetrics() async -> [DailyHealthMetrics] {
        let dates = Date.datesForPreviousWeek()
        
        // Get cached data first
        var cachedMetrics: [DailyHealthMetrics] = []
        for date in dates {
            if let cached = getCachedMetrics(for: date) {
                cachedMetrics.append(cached)
            }
        }
        
        // Refresh in background (optional - previous week data is less critical)
        Task {
            do {
                try await refreshMetrics(for: dates)
            } catch {
                // Silently fail for previous week data
            }
        }
        
        return cachedMetrics
    }
    
    func refreshMetrics(for date: Date) async throws -> DailyHealthMetrics? {
        // #region agent log
        DebugLogger.log(location: "HealthDataRepository.swift:refreshMetrics", message: "Function called", data: ["date": date.description], hypothesisId: "G")
        // #endregion
        
        do {
            let metrics = try await healthKitService.fetchDailyMetrics(for: date)
            // #region agent log
            DebugLogger.log(location: "HealthDataRepository.swift:refreshMetrics", message: "Fetched from HealthKit", data: [
                "steps": metrics?.steps ?? -1,
                "calories": metrics?.activeCalories ?? -1
            ], hypothesisId: "G")
            // #endregion
            
            // Always save to cache, even if metrics are 0 (indicates we tried to fetch)
            if let metrics = metrics {
                // #region agent log
                DebugLogger.log(location: "HealthDataRepository.swift:refreshMetrics", message: "Saving to cache", data: [
                    "steps": metrics.steps,
                    "calories": metrics.activeCalories
                ], hypothesisId: "G")
                // #endregion
                await saveToCache(metrics)
                // #region agent log
                DebugLogger.log(location: "HealthDataRepository.swift:refreshMetrics", message: "Saved to cache", hypothesisId: "G")
                // #endregion
            } else {
                // #region agent log
                DebugLogger.log(location: "HealthDataRepository.swift:refreshMetrics", message: "Metrics is nil, not saving", hypothesisId: "G")
                // #endregion
            }
            return metrics
        } catch {
            // #region agent log
            DebugLogger.log(location: "HealthDataRepository.swift:refreshMetrics", message: "Error", data: ["error": error.localizedDescription], hypothesisId: "G")
            // #endregion
            throw error
        }
    }
    
    func refreshMetrics(for dates: [Date]) async throws {
        // #region agent log
        print("DEBUG [HealthDataRepository]: refreshMetrics called for \(dates.count) dates: \(dates.map { $0.startOfDay })")
        // #endregion
        
        do {
            let metrics = try await healthKitService.fetchDailyMetrics(for: dates)
            // #region agent log
            print("DEBUG [HealthDataRepository]: Fetched \(metrics.count) metrics from HealthKit")
            // #endregion
            
            if metrics.isEmpty {
                // #region agent log
                print("DEBUG [HealthDataRepository]: WARNING - No metrics returned from HealthKit for \(dates.count) dates")
                // #endregion
            }
            
            for metric in metrics {
                // #region agent log
                print("DEBUG [HealthDataRepository]: Saving metric for date: \(metric.date.startOfDay), steps: \(metric.steps), calories: \(metric.activeCalories)")
                // #endregion
                await saveToCache(metric)
            }
        } catch {
            // #region agent log
            print("DEBUG [HealthDataRepository]: ERROR fetching metrics for dates: \(error)")
            print("DEBUG [HealthDataRepository]: Error details: \(error.localizedDescription)")
            // #endregion
            // Re-throw error so caller can handle it
            throw error
        }
    }
    
    private func getCachedMetrics(for date: Date) -> DailyHealthMetrics? {
        let request: NSFetchRequest<DailyHealthData> = DailyHealthData.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date.startOfDay as NSDate)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            // #region agent log
            print("DEBUG [HealthDataRepository]: Cache lookup for \(date.startOfDay) - found \(results.count) results")
            // #endregion
            
            guard let result = results.first else {
                // #region agent log
                print("DEBUG [HealthDataRepository]: No cached data found for \(date.startOfDay)")
                // #endregion
                return nil
            }
            
            // #region agent log
            print("DEBUG [HealthDataRepository]: Cached data found - steps: \(result.steps), calories: \(result.activeCalories), lastSync: \(result.lastSyncDate?.description ?? "nil")")
            // #endregion
            
            return DailyHealthMetrics(
                date: result.date ?? date,
                steps: Int(result.steps),
                activeCalories: result.activeCalories
            )
        } catch {
            // #region agent log
            print("DEBUG [HealthDataRepository]: Error fetching from cache: \(error)")
            // #endregion
            return nil
        }
    }
    
    private func saveToCache(_ metrics: DailyHealthMetrics) async {
        await context.perform {
            let request: NSFetchRequest<DailyHealthData> = DailyHealthData.fetchRequest()
            request.predicate = NSPredicate(format: "date == %@", metrics.date.startOfDay as NSDate)
            request.fetchLimit = 1
            
            let entity: DailyHealthData
            do {
                let results = try self.context.fetch(request)
                // #region agent log
                print("DEBUG [HealthDataRepository]: Save cache lookup - found \(results.count) existing records")
                // #endregion
                
                if let existing = results.first {
                    entity = existing
                    // #region agent log
                    print("DEBUG [HealthDataRepository]: Updating existing cache entry")
                    // #endregion
                } else {
                    entity = DailyHealthData(context: self.context)
                    entity.date = metrics.date.startOfDay
                    // #region agent log
                    print("DEBUG [HealthDataRepository]: Creating new cache entry")
                    // #endregion
                }
            } catch {
                // #region agent log
                print("DEBUG [HealthDataRepository]: Error fetching existing cache: \(error), creating new entry")
                // #endregion
                entity = DailyHealthData(context: self.context)
                entity.date = metrics.date.startOfDay
            }
            
            entity.steps = Int64(metrics.steps)
            entity.activeCalories = metrics.activeCalories
            entity.lastSyncDate = Date()
            
            // #region agent log
            print("DEBUG [HealthDataRepository]: Saving cache - steps: \(entity.steps), calories: \(entity.activeCalories), date: \(entity.date?.description ?? "nil")")
            // #endregion
            
            do {
                try self.context.save()
                // #region agent log
                print("DEBUG [HealthDataRepository]: Cache saved successfully")
                // #endregion
            } catch {
                // #region agent log
                print("DEBUG [HealthDataRepository]: Error saving cache: \(error)")
                // #endregion
            }
        }
    }
}

