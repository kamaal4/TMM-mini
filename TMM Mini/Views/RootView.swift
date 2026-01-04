//
//  RootView.swift
//  TMM Mini
//
//  Created by Mustafa on 04/01/26.
//

import SwiftUI
import CoreData

struct RootView: View {
    @State private var showOnboarding = false
    @State private var onboardingComplete = false
    
    var body: some View {
        Group {
            if showOnboarding && !onboardingComplete {
                OnboardingView(isComplete: $onboardingComplete)
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
        .onChange(of: onboardingComplete) { _, complete in
            if complete {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                withAnimation {
                    showOnboarding = false
                }
            }
        }
    }
    
    private func checkOnboardingStatus() {
        let hasCompleted = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let healthKitStatus = HealthKitManager.shared.getAuthorizationStatus()
        
        // Show onboarding if not completed or if HealthKit is not authorized
        showOnboarding = !hasCompleted || healthKitStatus != .authorized
        
        if !showOnboarding {
            onboardingComplete = true
        }
    }
}

#Preview {
    RootView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

