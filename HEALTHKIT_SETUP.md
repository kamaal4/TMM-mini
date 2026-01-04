# HealthKit Setup Instructions

The app requires HealthKit entitlements and Info.plist configuration. Follow these steps:

## Step 1: Add HealthKit Capability in Xcode

1. Open `TMM Mini.xcodeproj` in Xcode
2. Select the project in the navigator (top item)
3. Select the "TMM Mini" target
4. Go to the "Signing & Capabilities" tab
5. Click the "+ Capability" button
6. Search for and add "HealthKit"
7. Ensure your Apple Developer account is configured

## Step 2: Verify Info.plist Configuration

The `Info.plist` file has been created with the required HealthKit usage descriptions:
- `NSHealthShareUsageDescription`: "We need access to your health data to display your steps and active calories."
- `NSHealthUpdateUsageDescription`: "We need access to update your health data."

If you need to update these:
1. In Xcode, select the project
2. Select the "TMM Mini" target
3. Go to the "Info" tab
4. Add or verify these keys under "Custom iOS Target Properties"

Alternatively, you can add them via build settings:
- `INFOPLIST_KEY_NSHealthShareUsageDescription`
- `INFOPLIST_KEY_NSHealthUpdateUsageDescription`

## Step 3: Build and Run

1. Connect a physical iOS device (HealthKit doesn't work in simulator)
2. Select your device as the build target
3. Build and run (⌘R)

## Troubleshooting

If you still see entitlement errors:
1. Clean build folder (⌘⇧K)
2. Delete derived data
3. Rebuild the project
4. Ensure you're running on a physical device, not simulator

