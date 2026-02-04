# ConnectStats Data Model

> Core data structures: GCActivity, fields, laps, track points

## Activity Model (GCActivity)

The central data model representing a single fitness activity.

### Core Properties

```objc
@interface GCActivity : RZParentObject<RZChildObject, GCTrackPointDelegate>

// Identification
@property NSString *activityId;          // Unique ID (service-prefixed)
@property GCActivityType *activityTypeDetail;  // Activity type
@property NSString *activityName;        // User-assigned name
@property NSDate *date;                  // Start timestamp
@property NSString *location;            // Location description

// Summary Metrics
@property double sumDistance;            // Total distance (meters)
@property double sumDuration;            // Total time (seconds)
@property double weightedMeanSpeed;      // Average speed
@property double weightedMeanHeartRate;  // Average HR

// GPS
@property CLLocationCoordinate2D beginCoordinate;

// Data Collections
@property NSDictionary<GCField*, GCActivitySummaryValue*> *summaryData;
@property NSDictionary<NSString*, GCActivityMetaValue*> *metaData;
@property NSDictionary<GCField*, GCActivityCalculatedValue*> *calculatedFields;
@property NSArray<GCTrackPoint*> *trackpoints;  // Lazy-loaded
@property NSArray<GCLap*> *lapsCache;

// Database
@property FMDatabase *db;       // Main activity DB
@property FMDatabase *trackdb;  // Separate trackpoint DB

@end
```

### Category Extensions

GCActivity uses Objective-C categories for modular organization:

| Category | Purpose | Key Methods |
|----------|---------|-------------|
| `+Database` | Persistence | `loadFromDb:`, `saveToDb:`, `loadSummaryData` |
| `+Fields` | Field access | `numberWithUnitForField:`, `groupedFields` |
| `+Series` | Time/distance series | `timeSerieForField:`, `distanceSerieForField:` |
| `+CalculatedLaps` | Dynamic laps | `calculatedRollingLapFor:`, `calculateSkiLaps` |
| `+CalculatedTracks` | Computed series | `calculatedSerieForField:thread:` |
| `+BestRolling` | Best efforts | `calculatedRollingBest:` |
| `+Import` | Data import | `initWithId:andGarminData:`, `initWithId:andStravaData:` |
| `+Assets` | Photos/maps | `assetsPhotosLocalIdentifiers`, `assetsMapSnapshot` |
| `+UI` | UI helpers | `icon`, `activityTypeKey:` |
| `+TrackTransform` | GPS processing | `resample:`, `removedStoppedTimer:` |
| `+CSSearch` | Spotlight | `spotLightUserActivity` |
| `+Location` (Swift) | Location | Swift location extensions |

### Activity ID Prefixes

Activities from different services have prefixed IDs:

| Service | Prefix | Example |
|---------|--------|---------|
| Garmin | (none) | `12345678` |
| Strava | `__strava__` | `__strava__9876543` |
| ConnectStats | `__connectstats__` | `__connectstats__abc123` |
| HealthKit | `__healthkit__` | `__healthkit__uuid` |

## Field System (GCField)

Represents a data field with type-aware behavior.

```objc
@interface GCField : NSObject

@property NSString *key;              // Unique identifier (e.g., "SumDistance")
@property gcFieldFlag fieldFlag;      // Bitfield for standard fields
@property GCActivityType *activityType;  // Type specificity

// Factory
+ (GCField*)fieldForKey:(NSString*)key andActivityType:(GCActivityType*)type;

// Conversion
- (GCField*)correspondingFieldForActivityType:(GCActivityType*)type;
- (GCField*)correspondingPaceOrSpeedField;

// Display
- (NSString*)displayName;
- (GCUnit*)unit;

@end
```

### Standard Field Flags

```objc
typedef NS_OPTIONS(NSUInteger, gcFieldFlag) {
    gcFieldFlagSumDistance          = 1 << 0,
    gcFieldFlagSumDuration          = 1 << 1,
    gcFieldFlagWeightedMeanSpeed    = 1 << 2,
    gcFieldFlagWeightedMeanHeartRate = 1 << 3,
    // ... more flags for cadence, power, altitude, etc.
};
```

### Field Value Classes

**GCActivitySummaryValue** - Stores field value with unit:
```objc
@interface GCActivitySummaryValue : NSObject
@property GCField *field;
@property GCNumberWithUnit *numberWithUnit;
@end
```

**GCActivityCalculatedValue** - For computed fields (subclass of summary value).

**GCActivityMetaValue** - Arbitrary metadata:
```objc
@interface GCActivityMetaValue : NSObject
@property NSString *field;   // Key
@property NSString *display; // Human-readable
@property NSString *key;     // Machine-readable
@end
```

## Track Points (GCTrackPoint)

Individual time-series data points for GPS and sensor data.

```objc
@interface GCTrackPoint : NSObject

// Time & Position
@property NSDate *time;
@property double latitudeDegrees;
@property double longitudeDegrees;
@property double elapsed;        // Seconds from start
@property double distanceMeters; // Distance from start

// Standard Measurements (read-only computed)
@property (readonly) double heartRateBpm;
@property (readonly) double speed;
@property (readonly) double cadence;
@property (readonly) double altitude;
@property (readonly) double power;
@property (readonly) double verticalOscillation;
@property (readonly) double groundContactTime;
@property (readonly) double steps;

// Extensions
@property NSDictionary *calculated;  // Computed fields
@property NSDictionary *extra;       // Non-standard fields
@property NSInteger lapIndex;        // Lap association
@property NSUInteger trackFlags;     // Available data bitfield

@end
```

### Track Point Loading

Trackpoints are lazy-loaded from a separate database file:

```objc
// Check if loaded or trigger load
- (BOOL)trackpointsReadyOrLoad;

// Load from database
- (void)loadTrackPointsFromDb:(FMDatabase*)db;

// Save to database
- (void)saveTrackpointsAndLapsToDb:(FMDatabase*)db;
```

## Laps (GCLap)

Extends GCTrackPoint with lap-specific data.

```objc
@interface GCLap : GCTrackPoint
@property NSString *label;  // Custom lap name
@end
```

### Lap Management

Activities can have multiple lap sets:

```objc
// Built-in lap set names
#define GC_LAPS_RECORDED @"recorded"
#define GC_LAPS_SPLIT_DISTHALF @"split_disthalf"
#define GC_LAPS_ACCUMULATED @"accumulated"

// Register custom lap set
- (void)registerLaps:(NSArray<GCLap*>*)laps forName:(NSString*)name;

// Switch active lap set
- (void)useLaps:(NSString*)name;

// Access
- (GCLap*)lapNumber:(NSUInteger)idx;
- (NSUInteger)lapCount;
```

## Activity Types (GCActivityType)

Immutable value object with type hierarchy.

```objc
@interface GCActivityType : NSObject

@property (readonly) NSString *key;        // "running", "cycling", etc.
@property (readonly) NSInteger typeId;     // Numeric ID
@property (readonly) GCActivityType *parentType;  // Hierarchy

// Type Hierarchy
- (GCActivityType*)rootType;       // Top-level (all, day)
- (GCActivityType*)primaryActivityType;  // Main type
- (BOOL)isSameRootType:(GCActivityType*)other;

// Factory Methods
+ (GCActivityType*)activityTypeForKey:(NSString*)key;
+ (GCActivityType*)activityTypeForGarminId:(NSInteger)garminId;
+ (GCActivityType*)activityTypeForStravaType:(NSString*)stravaType;
+ (GCActivityType*)activityTypeForFitSport:(UInt8)sport andSubSport:(UInt8)subSport;

// Convenience
+ (GCActivityType*)running;
+ (GCActivityType*)cycling;
+ (GCActivityType*)swimming;
+ (GCActivityType*)all;

// Display Preferences
- (BOOL)isPacePreferred;  // Show pace instead of speed
- (BOOL)isSki;            // Special ski handling

@end
```

### Type Hierarchy

```
all
├── running
│   ├── trail_running
│   └── treadmill_running
├── cycling
│   ├── road_biking
│   └── indoor_cycling
├── swimming
│   ├── open_water
│   └── pool_swimming
└── day (daily summaries)
```

## Data Flow

### Activity Creation

```
Service Response (JSON/FIT)
        │
        ▼
┌─────────────────────────────┐
│  Parser (Garmin/Strava/etc) │
│  GCActivity+Import          │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│  GCActivitiesOrganizer      │
│  registerActivity:          │
└─────────────┬───────────────┘
              │
              ▼
┌─────────────────────────────┐
│  GCActivity+Database        │
│  saveToDb:                  │
└─────────────────────────────┘
```

### Field Access Pattern

```objc
// Primary getter - handles all cases
GCNumberWithUnit *value = [activity numberWithUnitForField:field];

// Lookup order:
// 1. Check built-in flags (duration, distance, speed, HR)
// 2. Check summaryData dictionary
// 3. Check calculatedFields dictionary
// 4. Try type conversion for "all" type fields
```

### Series Generation

```objc
// Time-indexed series for graphing
GCStatsDataSerieWithUnit *series = [activity timeSerieForField:speedField];

// Distance-indexed series
GCStatsDataSerieWithUnit *series = [activity distanceSerieForField:hrField];

// With caching for expensive calculations
[activity addStandardCalculatedTracks:thread];
```

## Multi-Sport Support

Activities can be parent (multi-sport) or child (segment):

```objc
// Parent activity
@property NSArray<NSString*> *childIds;

// Child activity
@property NSString *parentId;

// Check relationship
if (activity.parentId != nil) {
    // This is a child segment
}
```

## Weather (GCWeather)

Optional weather data attached to activities:

```objc
@interface GCWeather : NSObject
@property double temperature;
@property double humidity;
@property double windSpeed;
@property double windDirection;
@property NSString *weatherDescription;
@end
```

Weather is stored in `gc_activities_weather` table and loaded on demand.
