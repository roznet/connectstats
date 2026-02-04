# Swift Modernization Strategy

> Strategy for migrating Objective-C to Swift

## Current State

**Language Distribution:**
- Objective-C: ~91% (395 files: 200 .h + 195 .m)
- Swift: ~9% (40 files)

**Already in Swift:**
- App lifecycle: `GCAppDelegate.swift`, `GCAppSceneDelegate.swift`
- Modern UI cells: `GCCellActivity.swift`, `GCCellFieldValue*.swift`
- New service requests: `GCStravaRequest*.swift`, `GCGarminLoginSSO.swift`
- Some utilities: `GCAppPasswordManager.swift`, `GCWebRequestCache.swift`

---

## Migration Principles

### 1. New Code in Swift

All new features should be written in Swift with `@objc` exposure as needed:

```swift
@objc class GCNewFeature: NSObject {
    @objc func methodForObjC() {
        // Callable from Objective-C
    }
}
```

### 2. Swift Extensions on Obj-C Classes

Extend existing Objective-C classes with Swift:

```swift
// GCActivity+Location.swift
extension GCActivity {
    @objc func locationDescription() -> String {
        // Swift implementation
    }
}
```

### 3. Preserve Interfaces

When migrating a class, keep the same method signatures for compatibility:

```swift
// Before (Objective-C)
- (GCNumberWithUnit*)numberWithUnitForField:(GCField*)field;

// After (Swift)
@objc func numberWithUnit(for field: GCField) -> GCNumberWithUnit?
```

### 4. Incremental Migration

Migrate one category/extension at a time rather than whole classes.

---

## Priority Migration Targets

### High Priority (Service Reliability)

| Component | Reason | Complexity |
|-----------|--------|------------|
| `GCGarminRequest*.m` | Service sync issues, SSO changes | Medium |
| `GCWebConnect.m` | Core networking, error handling | High |
| `GCConnectStatsRequest*.m` | Backend integration | Medium |

### Medium Priority (Code Quality)

| Component | Reason | Complexity |
|-----------|--------|------------|
| `GCActivity+Import.m` | Complex parsing, type safety | High |
| `GCActivitiesOrganizer.m` | Core data management | High |
| `GCField.m` | Type safety benefits | Medium |

### Lower Priority (UI)

| Component | Reason | Complexity |
|-----------|--------|------------|
| `GCActivityListViewController.m` | Already has Swift cells | Medium |
| `GCActivityDetailViewController.m` | Partial Swift extension exists | Medium |
| `GCCellGrid+Templates.m` | Being replaced by Swift cells | Low |

---

## Migration Patterns

### Pattern 1: Extension First

Add Swift functionality via extensions, then migrate core:

```swift
// Step 1: Add Swift extension
extension GCActivity {
    @objc func formattedDuration() -> String {
        // New Swift implementation
    }
}

// Step 2: Later, migrate more methods
// Step 3: Eventually migrate entire class
```

### Pattern 2: Protocol Extraction

Extract protocols to enable Swift implementations:

```swift
// Define protocol
@objc protocol ActivityImporting {
    func importFromGarmin(_ data: [String: Any]) -> Bool
    func importFromStrava(_ data: [String: Any]) -> Bool
}

// Swift implementation
class SwiftActivityImporter: NSObject, ActivityImporting {
    func importFromGarmin(_ data: [String: Any]) -> Bool {
        // Modern implementation
    }
}
```

### Pattern 3: Value Type Conversion

Convert Objective-C classes to Swift structs where appropriate:

```swift
// Instead of mutable ObjC class
struct ActivitySummary {
    let distance: Measurement<UnitLength>
    let duration: TimeInterval
    let averageHeartRate: Double?
}

// Bridge for Objective-C
@objc class ActivitySummaryBridge: NSObject {
    @objc let summary: ActivitySummary

    @objc var distanceMeters: Double {
        summary.distance.converted(to: .meters).value
    }
}
```

---

## Bridging Considerations

### Bridging Header

`ConnectStats-Bridging-Header.h` imports Objective-C for Swift:

```objc
// Add imports for Objective-C headers needed in Swift
#import "GCActivity.h"
#import "GCField.h"
#import "GCActivitiesOrganizer.h"
```

### Generated Header

`ConnectStats-Swift.h` exposes Swift to Objective-C (auto-generated).

### Nullability

Mark Objective-C interfaces with nullability:

```objc
NS_ASSUME_NONNULL_BEGIN

@interface GCActivity : NSObject
@property (nonatomic, nullable) NSString *location;
@property (nonatomic) NSDate *date;  // Implicitly nonnull
@end

NS_ASSUME_NONNULL_END
```

---

## Testing Strategy

### Unit Tests in Swift

Write new tests in Swift:

```swift
class GCActivityTests: XCTestCase {
    func testImportFromGarmin() {
        let activity = GCActivity(id: "test123")
        // Test implementation
    }
}
```

### Regression Testing

Before migrating a component:
1. Ensure test coverage for existing behavior
2. Migrate implementation
3. Verify tests still pass

---

## Specific Migration Notes

### GCWebConnect

Current state: Complex Objective-C with request queue.

Migration approach:
1. Create Swift protocol for requests
2. Migrate request classes one at a time (partially done)
3. Migrate coordinator last

### GCActivity

Current state: Large class with many categories.

Migration approach:
1. Keep core class in Objective-C for now
2. Add Swift extensions for new functionality
3. Migrate categories one at a time
4. Core class migration is a major undertaking - defer

### Service Requests

Current state: Mix of Objective-C and Swift.

Migration approach:
1. New requests in Swift (already happening)
2. Migrate problematic Garmin requests (SSO issues)
3. Use async/await for cleaner flow control

```swift
// Modern async approach
func fetchActivities() async throws -> [Activity] {
    let data = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([Activity].self, from: data)
}
```

---

## Tooling

### Swiftify

Consider using Swiftify for mechanical conversion of straightforward code.

### Xcode Refactoring

Use Xcode's "Convert to Swift" for simple cases.

### Manual Review

Complex logic requires manual conversion with:
- Null safety analysis
- Error handling modernization
- Protocol-oriented design

---

## Timeline Considerations

Migration is a long-term effort. Priorities:

1. **Immediate**: Fix service sync issues (may involve Swift migration)
2. **Short-term**: New features in Swift, extensions on existing classes
3. **Medium-term**: Migrate service request layer
4. **Long-term**: Core data model migration

---

## Avoiding Migration Pitfalls

### Don't Break Compatibility

- Preserve `@objc` for Objective-C callers
- Don't change method signatures without updating callers
- Test thoroughly on each migration

### Don't Over-Engineer

- Simple conversions are better than clever rewrites
- Preserve existing patterns unless they're actively problematic
- Avoid introducing new dependencies

### Don't Rush

- Migrate incrementally
- One component at a time
- Full test coverage before and after
