//
//  OnboardingViewModel.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var authorizationStatus: HealthKitAuthorizationStatus = .notDetermined
    @Published var isRequesting = false
    @Published var showLimitedMode = false
    @Published var shouldCompleteOnboarding = false
    
    private let healthKitService: HealthKitServiceProtocol
    
    init(healthKitService: HealthKitServiceProtocol? = nil) {
        self.healthKitService = healthKitService ?? HealthKitManager.shared
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        let status = healthKitService.getAuthorizationStatus()
        authorizationStatus = status
        showLimitedMode = authorizationStatus == .denied
    }
    
    func requestHealthPermissions() async {
        // Give HealthKit a moment to update status if permissions were just granted
        // This is important because HealthKit's status might not update immediately
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Check current status first - if already authorized, we're done
        let currentStatus = healthKitService.getAuthorizationStatus()
        
        if currentStatus == .authorized {
            authorizationStatus = .authorized
            showLimitedMode = false
            shouldCompleteOnboarding = true
            return
        }
        
        isRequesting = true
        HapticManager.impact(style: .light)
        
        do {
            let status = try await healthKitService.requestAuthorization()
            authorizationStatus = status
            showLimitedMode = status == .denied
            
            if status == .authorized {
                HapticManager.notification(type: .success)
                shouldCompleteOnboarding = true
            } else if status == .denied {
                HapticManager.notification(type: .error)
            }
        } catch {
            // If error occurs, check status again - user might have granted permissions
            let updatedStatus = healthKitService.getAuthorizationStatus()
            authorizationStatus = updatedStatus
            showLimitedMode = updatedStatus == .denied
            
            if updatedStatus == .authorized {
                shouldCompleteOnboarding = true
            } else {
                HapticManager.notification(type: .error)
            }
        }
        
        isRequesting = false
        
        // Final check: regardless of what happened above, check status one more time
        // This ensures we catch authorization even if the status check was unreliable
        let finalStatusCheck = healthKitService.getAuthorizationStatus()
        
        if finalStatusCheck == .authorized {
            authorizationStatus = .authorized
            showLimitedMode = false
            shouldCompleteOnboarding = true
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func retryAuthorization() {
        Task {
            await requestHealthPermissions()
        }
    }
}

