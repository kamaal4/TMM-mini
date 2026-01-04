**iOS Mock App Brief**  
**TMM Mini: Premium Health Dashboard Prototype**

Deadline: 16 January 2026 (UK time)

# **Purpose**

This task is designed to evaluate both product quality and engineering quality for a premium health app prototype. The end result must have a premium feel: clean, modern, motivating, and not confusing.

We are assessing two areas:

* UI and UX quality (premium look, clarity, delight, and polish)  
* Engineering quality (HealthKit basics, offline cache, architecture, and performance)

# **Deliverables**

Please submit all of the following:

1. Source code (GitHub repository link preferred, or a zipped project)  
2. README.md including setup steps, architecture overview, key decisions and tradeoffs, and what you would improve in 1 week  
3. A short video where you show the mock app and walk us through what you built (recommended 2 to 5 minutes)  
4. Optional: a 1 to 2 minute screen recording focused only on the user experience and transitions

# **App Requirements**

Build a small app with three screens. SwiftUI is preferred, but UIKit is allowed if needed.

## **Screen 1: Onboarding and Health Permissions**

Goal: premium onboarding and a clear permission experience.

Must include:

* A minimal, high-quality onboarding screen with a short value statement and 2 to 3 benefit bullets  
* One primary call to action button labeled Connect Health  
* Request HealthKit permissions for Steps (Step Count) and Active Energy (Active Calories)  
* If permission is denied, show a premium Limited Mode state with explanation and a retry option (do not rely only on a basic alert)

UI expectations:

* Tasteful animation on the primary button and subtle haptics  
* Consistent spacing and typography

## **Screen 2: Dashboard (Main Screen)**

Goal: a premium home screen that is motivating and easy to understand.

Must include:

* Today summary: Steps, Active Calories, and a goal progress ring or bar  
* 7-day trend chart with a toggle for Steps and Calories (Swift Charts allowed)  
* Two insight cards with simple but meaningful calculations (examples: best day this week, ahead or behind last week percentage, 7-day average)  
* Delight moment: when the goal is reached, or via a Simulate Goal Reached button, show a subtle celebration animation with haptics and short microcopy

Offline and correctness requirements:

* Cache daily aggregates locally (CoreData, SwiftData, Realm, or SQLite)  
* On launch, show cached values immediately, then refresh and update  
* Use daily aggregation (statistics) rather than naive summing of raw samples for daily totals

States (must include):

* Loading state (skeleton, shimmer, or tasteful placeholders)  
* Empty state (no data yet)  
* Error state (HealthKit unavailable or denied)

## **Screen 3: Quick Nutrition Log (UI Craftsmanship Test)**

Goal: show strong UX design for data entry and tracking flows.

Must include:

* A Log Meal button that opens a modal or bottom sheet  
* Form fields: Food name, Calories, Protein, Carbs, Fat  
* Validation and clean UX (for example, disable Save until valid)  
* A list of logged meals with a polished empty state and well-designed rows  
* A Scan button (barcode scanning is optional; a placeholder camera-style screen is acceptable)

# **Style and UI Requirements**

The app must look premium and feel polished.

Must include:

* Dark Mode support  
* A consistent design system: spacing scale, typography hierarchy, and reusable components (cards, buttons, chips)  
* Smooth animations and transitions without jank  
* Basic accessibility: Dynamic Type should not break key layouts, and contrast should be reasonable

Design direction: premium, minimal, high-contrast, modern fitness and health app style.

# **Optional Bonus: High Sampling Pipeline Readiness (Up to 10 Extra Points)**

True high-frequency sampling often comes from vendor APIs or SDKs, but we want to see an architecture that can handle frequent updates without UI lag.

Implement one of the following options:

* Option A (HealthKit incremental updates): use HKObserverQuery and HKAnchoredObjectQuery for Steps or Active Energy, store the anchor, fetch incremental updates, show Last sync and Updates received count, and throttle UI updates  
* Option B (Simulated stream): simulate updates using AsyncStream every 1 to 5 seconds, batch persistence, throttle UI updates, and still compute daily aggregates from stored data

# **Allowed Tech**

* SwiftUI preferred; UIKit allowed  
* Swift Charts allowed  
* Any clean architecture is acceptable (MVVM recommended)

# **Scoring Rubric**

We will score submissions using the rubric below (100 points total, plus optional bonus):

* UI and UX polish: 40 points  
* Product thinking and clarity: 15 points  
* HealthKit correctness: 15 points  
* Engineering quality: 20 points  
* Performance and accessibility: 10 points

Instant fails:

* No usable UI polish (inconsistent spacing and typography)  
* No HealthKit integration and no clean abstraction with mocked provider  
* No README or no video walkthrough