//
//  HealthKitServiceProtocol.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import Foundation
import HealthKit

enum HealthKitAuthorizationStatus {
    case notDetermined
    case denied
    case authorized
}

struct DailyHealthMetrics {
    let date: Date
    let steps: Int
    let activeCalories: Double
}

protocol HealthKitServiceProtocol {
    func requestAuthorization() async throws -> HealthKitAuthorizationStatus
    func getAuthorizationStatus() -> HealthKitAuthorizationStatus
    func fetchDailyMetrics(for date: Date) async throws -> DailyHealthMetrics?
    func fetchDailyMetrics(for dates: [Date]) async throws -> [DailyHealthMetrics]
    func startObservingUpdates(completion: @escaping ([DailyHealthMetrics]) -> Void)
    func stopObservingUpdates()
    var lastSyncDate: Date? { get }
    var updateCount: Int { get }
}

