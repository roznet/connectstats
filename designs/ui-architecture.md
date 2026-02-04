# ConnectStats UI Architecture

> ViewControllers, navigation, and adaptive layout

## Navigation Structure

### iPhone: Tab Bar Navigation

**File:** `ConnectStats/src/GCTabBarController.{h,m}`

```
┌─────────────────────────────────────────────────────────────┐
│                    GCTabBarController                        │
├──────────┬──────────┬──────────┬──────────┬────────────────┤
│Activities│  Detail  │  Stats   │ Calendar │   Settings     │
│   Tab    │   Tab    │   Tab    │   Tab    │     Tab        │
└────┬─────┴────┬─────┴────┬─────┴────┬─────┴───────┬────────┘
     │          │          │          │             │
     ▼          ▼          ▼          ▼             ▼
┌─────────┐┌─────────┐┌─────────┐┌─────────┐┌──────────────┐
│Activity ││Activity ││ Stats   ││   Kal   ││  Settings    │
│  List   ││ Detail  ││ Multi   ││ View    ││  View        │
│   VC    ││   VC    ││ Field   ││Controller││ Controller  │
└─────────┘└─────────┘└─────────┘└─────────┘└──────────────┘
```

Each tab wraps its view controller in a UINavigationController.

### iPad: Split View Navigation

**File:** `ConnectStats/src/GCSplitViewController.{h,m}`

```
┌────────────────────────────────────────────────────────────┐
│                   GCSplitViewController                     │
├─────────────────────┬──────────────────────────────────────┤
│      Master         │              Detail                   │
│                     │                                       │
│  GCActivityList     │     GCActivityDetail                  │
│  ViewController     │     ViewController                    │
│                     │                                       │
│  ┌───────────────┐  │  ┌────────────────────────────────┐  │
│  │ Activity Row  │──┼──│  Activity Details, Map, Stats   │  │
│  │ Activity Row  │  │  │                                 │  │
│  │ Activity Row  │  │  │                                 │  │
│  └───────────────┘  │  └────────────────────────────────┘  │
└─────────────────────┴──────────────────────────────────────┘
```

Uses iOS 14+ display modes:
- `UISplitViewControllerDisplayModeOneBesideSecondary`
- `UISplitViewControllerDisplayModeAutomatic`

---

## Core View Controllers

### GCActivityListViewController

**File:** `ConnectStats/src/GCActivityListViewController.{h,m}`

**Type:** UITableViewController
**Protocols:** RZChildObject, UISearchBarDelegate, GCCellGridDelegate

**Purpose:** Scrollable list of activities with search and filtering.

**Key Properties:**
```objc
@property GCActivitiesOrganizer *organizer;  // Data source
@property GCActivityDetailViewController *detailController;
@property UISearchBar *search;
@property BOOL extendedDisplay;  // Cell height configuration
```

**Data Binding:**
```objc
// Attach to organizer
[self.organizer attach:self];

// Receive updates
- (void)notifyCallBack:(id)theParent info:(RZDependencyInfo*)theInfo {
    [self.tableView reloadData];
}
```

**Cell Configuration:**
```objc
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GCActivity *activity = [self activityForIndex:indexPath.row];

    if ([GCViewConfig is2021Style]) {
        // Swift cell (GCCellActivity)
        GCCellActivity *cell = [tableView dequeueReusableCellWithIdentifier:@"GCCellActivity"];
        [cell setupFor:activity];
        return cell;
    } else {
        // Legacy cell (GCCellGrid)
        GCCellGrid *cell = [GCCellGrid cellGrid:tableView];
        [cell setupSummaryFromActivity:activity rows:3 width:width status:status];
        return cell;
    }
}
```

### GCActivityDetailViewController

**File:** `ConnectStats/src/GCActivityDetailViewController.{h,m,swift}`

**Type:** UITableViewController
**Protocols:** RZChildObject, GCEntryFieldDelegate, GCCellSimpleGraphDelegate

**Purpose:** Detailed view of selected activity with multiple sections.

**Key Properties:**
```objc
@property GCActivity *activity;
@property GCActivitiesOrganizer *organizer;
@property GCActivityOrganizedFields *organizedFields;  // Lazy-loaded
@property GCTrackStats *trackStats;
```

**Section Layout (10 sections):**

| Section | Content | Cell Type |
|---------|---------|-----------|
| 0 | Title/Summary | GCCellGrid |
| 1 | Loading Status | Status indicator |
| 2 | Map | GCCellMap |
| 3 | Graph | Graph cell |
| 4 | Avg/Min/Max | GCCellGrid |
| 5 | Extra Fields | GCCellGrid |
| 6 | Weather | GCCellGrid |
| 7 | Health | GCCellGrid |
| 8 | Laps Header | Header cell |
| 9 | Laps Detail | GCCellGrid per lap |

**Data Binding:**
```objc
// Attach to both organizer and web service
[self.organizer attach:self];
[[GCAppGlobal web] attach:self];

// Lazy load organized fields
- (GCActivityOrganizedFields*)organizedFields {
    if (!_cachedOrganizedFields) {
        _cachedOrganizedFields = [self.activity groupedFields];
    }
    return _cachedOrganizedFields;
}
```

### GCStatsMultiFieldViewController

**File:** `ConnectStats/src/GCStatsMultiFieldViewController.{h,m}`

**Purpose:** Statistics views with multiple graph types.

### GCSettingsViewController

**File:** `ConnectStats/src/GCSettingsViewController.{h,m}`

**Purpose:** App configuration and service settings.

---

## Cell Classes

### Swift Modern Cells

**GCCellActivity** (`GCCellActivity.swift`)

XIB-based cell for activity list:

```swift
@objc class GCCellActivity: UITableViewCell {
    @IBOutlet var borderView: GCCellRoundedPatternView!
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var leftFieldValues: GCCellFieldValueColumnView!
    @IBOutlet var rightFieldValues: GCCellFieldValueColumnView!
    @IBOutlet var todayLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var bottomLabel: UILabel!

    @objc func setup(for activity: GCActivity) {
        // Configure all outlets from activity data
        self.iconView.image = activity.icon()
        self.leftFieldValues.add(field: durationField, numberWithUnit: duration)
        // ...
    }
}
```

**GCCellFieldValueView** (`GCCellFieldValueView.swift`)

Renders single field value with number/unit/icon:

```swift
@objc class GCCellFieldValueView: UIView {
    var numberWithUnit: GCNumberWithUnit?
    var geometry: RZNumberWithUnitGeometry
    var field: GCField?

    // Layout modes
    enum DisplayIcon { case hide, left, right }
    enum DisplayField { case hide, left, right }
    enum DisplayNumber { case left, right }
}
```

**GCCellFieldValueColumnView** (`GCCellFieldValueColumnView.swift`)

Vertical stack of field values:

```swift
@objc class GCCellFieldValueColumnView: UIView {
    var fields: [GCField] = []
    var numberWithUnits: [GCNumberWithUnit] = []

    func add(field: GCField, numberWithUnit: GCNumberWithUnit)
    func clear()
}
```

**GCCellRoundedPatternView** (`GCCellRoundedPatternView.swift`)

Custom rounded rectangle border drawing for visual styling.

### Objective-C Legacy Cells

**GCCellGrid** (`GCCellGrid+Templates.{h,m}`)

Flexible grid-based layout with template methods:

```objc
// Activity list cell
- (void)setupSummaryFromActivity:(GCActivity*)activity
                            rows:(NSUInteger)rows
                           width:(CGFloat)width
                          status:(gcViewActivityStatus)status;

// Detail header
- (void)setupDetailHeader:(GCActivity*)activity;

// Single field
- (void)setupForField:(GCField*)field
          andActivity:(GCActivity*)activity
                width:(CGFloat)width;

// Lap info
- (void)setupForLap:(GCLap*)lap
        andActivity:(GCActivity*)activity
              width:(CGFloat)width;

// Weather
- (void)setupForWeather:(GCWeather*)weather width:(CGFloat)width;
```

**GCCellMap** (`GCCellMap.{h,m}`)

Embedded map view for activity routes:
- Contains `GCMapViewController`
- Supports Apple Maps or Google Maps
- Shows activity route overlay

**GCCellHealthDayActivity** (`GCCellHealthDayActivity.{h,m}`)

Specialized cell for daily activity summaries when `activity.activityType == GC_TYPE_DAY`.

---

## Data Flow Patterns

### Observer Pattern (RZChildObject)

```objc
// 1. Attach to data source
[self.organizer attach:self];

// 2. Implement callback
- (void)notifyCallBack:(id)theParent info:(RZDependencyInfo*)theInfo {
    // Refresh UI
    [self.tableView reloadData];
}

// 3. Detach on cleanup
- (void)dealloc {
    [self.organizer detach:self];
}
```

### NSNotificationCenter

```objc
// Register for settings changes
[[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(notifyCallBack:)
    name:kNotifySettingsChange
    object:nil];
```

### Data Access Pattern

```objc
// From GCActivitiesOrganizer
NSInteger count = [self.organizer countOfActivities];
GCActivity *activity = [self.organizer activityAtIndex:indexPath.row];
GCActivity *current = [self.organizer currentActivity];
```

---

## Navigation Methods

**GCAppGlobal Navigation:**

```objc
// Focus on specific activity
+ (void)focusOnActivityAtIndex:(NSUInteger)idx;
+ (void)focusOnActivityId:(NSString*)aId;

// Navigate to tabs
+ (void)focusOnStatsSummary;
+ (void)focusOnActivityList;

// Apply filter
+ (void)focusOnListWithFilter:(NSString*)aFilter;
```

**Implementation flow:**

```objc
+ (void)focusOnActivityAtIndex:(NSUInteger)idx {
    [self.organizer setCurrentActivityIndex:idx];
    // Tab bar controller shows detail tab
    // Detail VC receives notification and updates
}
```

---

## View Configuration

### GCViewConfig

**File:** `ConnectStats/src/GCViewConfig.{h,m}`

Centralized styling and configuration:

```objc
// Apply theme to VC
+ (void)setupViewController:(UIViewController*)vc;

// Activity-specific colors
+ (UIColor*)cellBackgroundDarkerForActivity:(GCActivity*)activity;
+ (UIColor*)textColorForActivity:(GCActivity*)activity;

// Text attributes
+ (NSDictionary*)attributeForRZAttribute:(rzTextAttribute)attr;

// Feature flags
+ (BOOL)is2021Style;  // New vs legacy UI

// Layout calculations
+ (CGFloat)sizeForNumberOfRows:(NSUInteger)rows;
```

### GCViewIcons

**File:** `ConnectStats/src/GCViewIcons.{h,m}`

Icon management for activity types and UI elements:

```objc
+ (UIImage*)iconForActivityType:(GCActivityType*)type;
+ (UIImage*)tabBarIconFor:(gcTabBarItem)item;
+ (UIImage*)navigationIconFor:(gcNavItem)item;
```

---

## Swift-Objective-C Integration

### Bridging Header

`ConnectStats-Bridging-Header.h` imports Objective-C headers for Swift access.

### Swift Extensions on Obj-C Classes

```swift
// GCActivityDetailViewController.swift
extension GCActivityDetailViewController {
    @objc func tableView(_ tableView: UITableView,
        fieldCellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        // Swift implementation for Obj-C VC
    }
}
```

### @objc Exposure

```swift
// Make Swift class available to Obj-C
@objc class GCCellActivity: UITableViewCell {
    @objc func setup(for activity: GCActivity) {
        // ...
    }
}
```

---

## Layout Geometry

### RZNumberWithUnitGeometry

From RZUtils - calculates dimensions for number/unit display:

```swift
// Adjust for value
geometry.adjust(for: numberWithUnit,
    numberAttribute: valueAttribute,
    unitAttribute: unitAttribute)

// Get total size
let size = geometry.totalSize

// Draw at location
geometry.drawInRect(rect, numberWithUnit: value, ...)
```

Used consistently across all numeric field rendering.

---

## Sequence: Activity Selection

```
User taps activity in list
        │
        ▼
didSelectRowAtIndexPath
        │
        ▼
[GCAppGlobal focusOnActivityAtIndex:idx]
        │
        ▼
[organizer setCurrentActivityIndex:idx]
        │
        ▼
Organizer notifies attached observers
        │
        ▼
Detail VC receives notifyCallBack
        │
        ▼
Detail VC updates self.activity
        │
        ▼
[tableView reloadData]
        │
        ▼
Tab bar shows detail tab
```
