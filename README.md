# TMM Mini: Premium Health Dashboard

A premium iOS health dashboard app prototype built with SwiftUI, featuring HealthKit integration, offline caching, and a world-class user experience.

## Overview

TMM Mini is a health tracking app that syncs with Apple HealthKit to display step counts, active calories, and nutrition logging. The app emphasizes premium UX with smooth animations, dark mode support, and polished interactions.

## Features

- **Onboarding & Health Permissions**: Premium onboarding flow with HealthKit permission requests
- **Dashboard**: Today's activity summary with circular progress ring, 7-day trend charts, and insight cards
- **Nutrition Logging**: Quick meal entry with macro tracking and barcode scanner placeholder
- **Offline First**: CoreData caching for instant data display with background refresh
- **High-Frequency Sampling**: Incremental HealthKit updates with throttled UI refresh (bonus feature)

## Requirements

- iOS 26.0+
- Xcode 26.2+
- Swift 6.0+
- Physical iOS device (HealthKit requires a real device, not simulator)

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd "TMM Mini"
   ```

2. **Open the project**
   - Open `TMM Mini.xcodeproj` in Xcode

3. **Configure HealthKit Capabilities**
   - Select the project in Xcode
   - Go to "Signing & Capabilities"
   - Add "HealthKit" capability
   - Ensure your Apple Developer account is configured

4. **Update Info.plist**
   - Add HealthKit usage descriptions:
     - `NSHealthShareUsageDescription`: "We need access to your health data to display your steps and active calories."
     - `NSHealthUpdateUsageDescription`: "We need access to update your health data."

5. **Build and Run**
   - Connect a physical iOS device
   - Select your device as the build target
   - Build and run (⌘R)

## Architecture

### MVVM Pattern

The app follows the Model-View-ViewModel architecture pattern:

- **Models**: CoreData entities (`DailyHealthData`, `Meal`), domain models (`DailyHealthMetrics`, `MealModel`)
- **Views**: SwiftUI views organized by feature (`OnboardingView`, `DashboardView`, `NutritionLogView`)
- **ViewModels**: Business logic and state management (`OnboardingViewModel`, `DashboardViewModel`, `NutritionLogViewModel`)
- **Services**: Data layer abstraction (`HealthKitManager`, `HealthDataRepository`, `MealRepository`)

### Key Components

```
TMM Mini/
├── Models/              # Domain models and CoreData entities
├── ViewModels/          # MVVM view models
├── Views/               # SwiftUI views organized by feature
│   ├── Onboarding/
│   ├── Dashboard/
│   └── Nutrition/
├── Services/            # Data services and repositories
├── Components/          # Reusable UI components
└── Utilities/          # Helper utilities
```

### Data Flow

1. **HealthKit Integration**
   - `HealthKitManager` abstracts HealthKit behind a protocol
   - Uses `HKStatisticsCollectionQuery` for accurate daily aggregation
   - Implements incremental updates with `HKObserverQuery` and `HKAnchoredObjectQuery`

2. **Offline Caching**
   - CoreData stores daily aggregates locally
   - App shows cached data immediately on launch
   - Background refresh updates cache asynchronously

3. **State Management**
   - ViewModels manage app state using `@Published` properties
   - SwiftUI views reactively update based on state changes
   - Error states handled gracefully with user-friendly messages

## Key Decisions & Tradeoffs

### 1. Daily Aggregation vs. Raw Samples

**Decision**: Use HealthKit's `HKStatisticsCollectionQuery` for daily totals instead of summing raw samples.

**Rationale**: 
- More accurate (handles overlapping samples correctly)
- Better performance (HealthKit handles aggregation)
- Aligns with Apple's best practices

**Tradeoff**: Slightly more complex implementation, but worth it for correctness.

### 2. Offline-First Architecture

**Decision**: Show cached data immediately, refresh in background.

**Rationale**:
- Instant perceived performance
- Works offline
- Better user experience

**Tradeoff**: May show stale data briefly, but acceptable for this use case.

### 3. Protocol-Based HealthKit Abstraction

**Decision**: Abstract HealthKit behind `HealthKitServiceProtocol`.

**Rationale**:
- Testability (can mock for unit tests)
- Flexibility (can swap implementations)
- Clean separation of concerns

**Tradeoff**: Slight overhead, but improves code quality significantly.

### 4. MVVM Architecture

**Decision**: Use MVVM instead of simpler patterns.

**Rationale**:
- Separation of concerns
- Testable business logic
- Scalable for future features

**Tradeoff**: More boilerplate, but better long-term maintainability.

### 5. Throttled UI Updates

**Decision**: Throttle UI updates to max 1 per second for high-frequency sampling.

**Rationale**:
- Prevents UI jank
- Better performance
- Smoother animations

**Tradeoff**: Slight delay in updates, but imperceptible to users.

## Design System

The app uses a consistent design system based on the provided Stitch designs:

- **Primary Color**: `#13eca4` (mint green)
- **Typography**: SF Pro (iOS equivalent to Manrope)
- **Spacing**: 4px/8px scale
- **Corner Radius**: 12px (md), 16px (lg), 24px (xl)
- **Dark Mode**: Fully supported throughout

## Bonus Feature: High-Frequency Sampling Pipeline

Implemented Option A (HealthKit incremental updates):

- `HKObserverQuery` for Steps and Active Energy
- `HKAnchoredObjectQuery` with anchor persistence
- Batch persistence to CoreData
- Throttled UI updates (max 1 update per second)
- Display "Last sync" timestamp and "Updates received" count

The architecture can handle frequent updates without UI lag, demonstrating readiness for high-frequency data streams.

## Testing

### Manual Testing Checklist

- [ ] Onboarding flow completes successfully
- [ ] HealthKit permissions requested correctly
- [ ] Limited Mode state shown when permissions denied
- [ ] Dashboard displays cached data immediately
- [ ] Dashboard refreshes from HealthKit
- [ ] Goal celebration animation triggers
- [ ] 7-day trend chart displays correctly
- [ ] Meal form validation works
- [ ] Meals save and display correctly
- [ ] Empty states display appropriately
- [ ] Error states handle gracefully
- [ ] Dark mode works throughout
- [ ] Accessibility (VoiceOver) works

## Video / Interview Cheat Sheet

Use this section as a quick script when recording the walkthrough or answering questions:

- **Story in 20s**: “TMM Mini is a premium SwiftUI dashboard that syncs steps and active energy from Apple Health, caches offline, and adds a fast nutrition log.”
- **Key flows to show**: Onboarding with value statement and benefits, Connect Health permission, Limited Mode retry, Dashboard (ring + 7-day chart + insights + goal celebration), Nutrition Log (validation + list + scan placeholder).
- **Architecture highlights**: MVVM, `HealthKitServiceProtocol` abstraction, `HealthDataRepository` for caching, CoreData for offline, stitched design system components.
- **Performance & bonus**: Incremental HealthKit updates with anchor storage, throttled UI updates, cached-first loading.
- **Privacy**: Reads HealthKit only; data stays on-device.
- **Files to reference**: `OnboardingView.swift`, `DashboardView.swift`, `NutritionLogView.swift`, `HealthKitManager.swift`, `HealthDataRepository.swift`, `DesignSystem.swift`.

### Known Limitations

- Requires physical device (HealthKit doesn't work in simulator)
- Barcode scanner is a placeholder (not functional)
- Profile screen is a placeholder
- No user authentication (single-user app)

## Future Improvements (1 Week)

If given one more week, I would:

1. **Unit Tests**
   - Add comprehensive unit tests for ViewModels
   - Mock HealthKit service for testing
   - Test edge cases and error scenarios

2. **Enhanced Nutrition Features**
   - Implement actual barcode scanning
   - Add food database integration
   - Meal history and analytics

3. **Performance Optimizations**
   - Optimize CoreData queries
   - Add pagination for meal lists
   - Cache chart data

4. **Additional Features**
   - User profile and settings
   - Customizable goals
   - Export data functionality
   - Widget support

5. **Polish**
   - More micro-interactions
   - Additional haptic feedback
   - Loading state improvements
   - Error recovery flows

6. **Accessibility**
   - Enhanced VoiceOver support
   - Dynamic Type testing
   - High contrast mode support

## Performance Considerations

- CoreData queries optimized with fetch limits and predicates
- UI updates throttled to prevent jank
- Background processing for HealthKit sync
- Efficient SwiftUI view updates with proper state management

## Accessibility

- VoiceOver labels on all interactive elements
- Dynamic Type support (tested with larger text sizes)
- Proper contrast ratios throughout
- Semantic labels for screen readers

## Credits

Built as a prototype for evaluating product and engineering quality. Design inspiration from premium health and fitness apps.

## License

[Add your license here]

