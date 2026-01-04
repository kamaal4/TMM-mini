# Quick Fix: HealthKit Entitlement Error

## The Error
```
Missing com.apple.developer.healthkit entitlement
```

## Solution (Choose ONE method)

### Method 1: Add HealthKit Capability in Xcode (Recommended)

1. **Open Xcode** and open `TMM Mini.xcodeproj`

2. **Select the Project** in the navigator (top item)

3. **Select the "TMM Mini" target**

4. **Go to "Signing & Capabilities" tab**

5. **Click the "+ Capability" button** (top left)

6. **Search for "HealthKit"** and double-click it to add

7. **Verify** that you see "HealthKit" in the capabilities list

8. **Clean Build Folder** (⌘⇧K)

9. **Rebuild** the project (⌘B)

### Method 2: Manual Entitlements File (If Method 1 doesn't work)

The entitlements file `TMM_Mini.entitlements` has been created. You need to:

1. **In Xcode**, right-click on the "TMM Mini" folder in the navigator
2. **Select "Add Files to 'TMM Mini'..."**
3. **Navigate to and select** `TMM Mini/TMM_Mini.entitlements`
4. **Make sure** "Copy items if needed" is checked
5. **Click "Add"**
6. **Verify** in Build Settings that `CODE_SIGN_ENTITLEMENTS` points to `TMM Mini/TMM_Mini.entitlements`

## Important Notes

- **You MUST have an Apple Developer account** configured in Xcode
- **HealthKit only works on physical devices**, not the simulator
- After adding the capability, **clean and rebuild** the project
- The Info.plist usage descriptions are already configured in build settings

## Verification

After adding the capability, you should see:
- "HealthKit" listed in the Capabilities section
- No more entitlement errors when running
- The app can request HealthKit permissions

