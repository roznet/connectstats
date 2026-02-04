# ConnectStats Database Schema

> SQLite persistence layer and data organization

## Database Architecture

ConnectStats uses two SQLite databases:

1. **Main Database** (`activities.db`) - Activity metadata, summaries, settings
2. **Track Database** (per-activity) - GPS trackpoints and laps

```
┌─────────────────────────────────────┐
│         Main Database               │
│  ┌───────────────────────────────┐  │
│  │     gc_activities             │  │
│  │     gc_activities_values      │  │
│  │     gc_activities_meta        │  │
│  │     gc_activities_calculated  │  │
│  │     gc_activities_data        │  │
│  │     gc_activities_weather     │  │
│  │     gc_activities_sync        │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│    Track Database (per activity)    │
│  ┌───────────────────────────────┐  │
│  │     gc_track                  │  │
│  │     gc_laps                   │  │
│  │     gc_laps_info              │  │
│  │     gc_track_extra_idx        │  │
│  │     gc_track_extra            │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## Main Database Tables

### gc_activities

Core activity metadata and summary values.

```sql
CREATE TABLE gc_activities (
    activityId TEXT PRIMARY KEY,
    activityName TEXT,
    activityType TEXT,              -- Deprecated, kept for compatibility
    activityTypeDetail TEXT,        -- Current type key (e.g., "running")
    BeginTimestamp REAL,            -- NSDate as Unix timestamp
    SumDistance REAL,               -- Total distance in meters
    SumDuration REAL,               -- Total duration in seconds
    WeightedMeanHeartRate REAL,
    WeightedMeanSpeed REAL,
    BeginLatitude REAL,
    BeginLongitude REAL,
    Location TEXT,                  -- Reverse geocoded location
    Flags INT,                      -- gcFieldFlag bitfield
    trackFlags INT,                 -- Available trackpoint fields
    garminSwimAlgorithm INT,
    downloadMethod INT,             -- gcDownloadMethod enum
    serviceStatus INT               -- Download completion status
);
```

### gc_activities_values

Custom summary field values beyond standard columns.

```sql
CREATE TABLE gc_activities_values (
    activityId TEXT,
    field TEXT,         -- Field key (e.g., "SumElapsedDuration")
    value REAL,
    uom TEXT,           -- Unit of measure
    FOREIGN KEY (activityId) REFERENCES gc_activities(activityId)
);

CREATE INDEX idx_activities_values_id ON gc_activities_values(activityId);
```

### gc_activities_meta

Arbitrary metadata (type, service info, etc.).

```sql
CREATE TABLE gc_activities_meta (
    activityId TEXT,
    field TEXT,         -- Metadata key (e.g., "activityType")
    display TEXT,       -- Human-readable value
    key TEXT,           -- Machine-readable value
    FOREIGN KEY (activityId) REFERENCES gc_activities(activityId)
);

CREATE INDEX idx_activities_meta_id ON gc_activities_meta(activityId);
```

### gc_activities_calculated

Computed/derived field values.

```sql
CREATE TABLE gc_activities_calculated (
    activityId TEXT,
    field TEXT,
    value REAL,
    uom TEXT,
    FOREIGN KEY (activityId) REFERENCES gc_activities(activityId)
);

CREATE INDEX idx_activities_calculated_id ON gc_activities_calculated(activityId);
```

### gc_activities_data

Serialized data blobs for complex structures.

```sql
CREATE TABLE gc_activities_data (
    activityId TEXT PRIMARY KEY,
    summaryData BLOB,   -- NSKeyedArchiver serialized summaryData dict
    metaData BLOB       -- NSKeyedArchiver serialized metaData dict
);
```

### gc_activities_weather

Weather data per activity.

```sql
CREATE TABLE gc_activities_weather (
    activityId TEXT PRIMARY KEY,
    temperature REAL,
    humidity REAL,
    windSpeed REAL,
    windDirection REAL,
    weatherDescription TEXT,
    icon TEXT,
    weatherData BLOB    -- Full serialized GCWeather
);
```

### gc_activities_sync

Service sync tracking to prevent duplicate downloads.

```sql
CREATE TABLE gc_activities_sync (
    activityId TEXT,
    date REAL,          -- Last sync timestamp
    service INTEGER,    -- gcService enum value
    PRIMARY KEY (activityId, service)
);
```

---

## Track Database Tables

Each activity has its own track database file for GPS/sensor data.

### gc_track

Individual trackpoint data.

```sql
CREATE TABLE gc_track (
    Time REAL,              -- Unix timestamp
    LatitudeDegrees REAL,
    LongitudeDegrees REAL,
    DistanceMeters REAL,    -- Cumulative distance
    HeartRateBpm REAL,
    Speed REAL,
    Cadence REAL,
    Altitude REAL,
    Power REAL,
    VerticalOscillation REAL,
    GroundContactTime REAL,
    lap INTEGER,            -- Lap index
    elapsed REAL,           -- Seconds from activity start
    trackflags INTEGER      -- Available data bitfield
);

CREATE INDEX idx_track_time ON gc_track(Time);
CREATE INDEX idx_track_lap ON gc_track(lap);
```

### gc_laps

Lap summary data.

```sql
CREATE TABLE gc_laps (
    lap INTEGER PRIMARY KEY,
    Time REAL,
    LatitudeDegrees REAL,
    LongitudeDegrees REAL,
    DistanceMeters REAL,
    HeartRateBpm REAL,
    Speed REAL,
    Altitude REAL,
    Cadence REAL,
    Power REAL,
    VerticalOscillation REAL,
    GroundContactTime REAL,
    elapsed REAL,
    trackflags INTEGER
);
```

### gc_laps_info

Extra lap metadata.

```sql
CREATE TABLE gc_laps_info (
    lap INTEGER,
    field TEXT,
    value REAL,
    uom TEXT,
    PRIMARY KEY (lap, field)
);
```

### gc_track_extra_idx

Index for non-standard trackpoint fields.

```sql
CREATE TABLE gc_track_extra_idx (
    field TEXT PRIMARY KEY,
    idx INTEGER,        -- Column index in gc_track_extra
    uom TEXT
);
```

### gc_track_extra

Dynamic columns for extra trackpoint fields.

```sql
-- Table structure varies based on what fields are present
-- Columns added dynamically as col_0, col_1, col_2, etc.
CREATE TABLE gc_track_extra (
    Time REAL PRIMARY KEY,
    col_0 REAL,
    col_1 REAL,
    ...
);
```

---

## Field Reference Database

**Location:** `ConnectStats/sqlite/`

Pre-built database with field definitions and translations.

### fields.db Tables

```sql
-- Field definitions
CREATE TABLE gc_fields (
    field TEXT PRIMARY KEY,
    activityType TEXT,
    fieldDisplayName TEXT,
    uom TEXT,
    fieldOrder INTEGER
);

-- Activity type definitions
CREATE TABLE gc_activity_types (
    key TEXT PRIMARY KEY,
    typeId INTEGER,
    parentKey TEXT,
    displayName TEXT
);

-- Translations (multiple tables per language)
CREATE TABLE gc_fields_en (...);
CREATE TABLE gc_fields_fr (...);
```

---

## Data Access Patterns

### Loading an Activity

```objc
// 1. Load from main table
GCActivity *activity = [GCActivity activityWithId:activityId andDb:db];

// 2. Load summary data (lazy)
[activity loadSummaryData];

// 3. Load trackpoints (on demand)
if ([activity trackpointsReadyOrLoad]) {
    // Trackpoints available
}
```

### Saving an Activity

```objc
// 1. Save to main database
[activity saveToDb:db];

// 2. Save trackpoints to track database
[activity saveTrackpointsAndLapsToDb:trackdb];
```

### Query Patterns

```objc
// All activities sorted by date
FMResultSet *rs = [db executeQuery:
    @"SELECT * FROM gc_activities ORDER BY BeginTimestamp DESC"];

// Activities with filter
FMResultSet *rs = [db executeQuery:
    @"SELECT * FROM gc_activities WHERE activityTypeDetail = ? ORDER BY BeginTimestamp DESC",
    @"running"];

// Summary value lookup
FMResultSet *rs = [db executeQuery:
    @"SELECT value, uom FROM gc_activities_values WHERE activityId = ? AND field = ?",
    activityId, fieldKey];
```

---

## Migration Strategy

### Schema Versioning

Check for column existence before adding:

```objc
+ (BOOL)ensureDbStructure:(FMDatabase*)db {
    if (![db columnExists:@"activityTypeDetail" inTableWithName:@"gc_activities"]) {
        RZEXECUTEUPDATE(db, @"ALTER TABLE gc_activities ADD COLUMN activityTypeDetail TEXT");
    }
    // ... more migrations
    return YES;
}
```

### Data Migration

When loading old records, convert deprecated fields:

```objc
// Convert activityType string to activityTypeDetail
if (self.activityTypeDetail == nil && self.activityType != nil) {
    self.activityTypeDetail = [GCActivityType activityTypeForKey:self.activityType];
}
```

---

## File Organization

```
App Documents/
├── activities.db           # Main database
├── activities/
│   ├── {activityId}.db    # Track database per activity
│   └── ...
├── derived.db             # Derived statistics cache
└── health.db              # HealthKit data cache
```

---

## Performance Considerations

### Lazy Loading

- Summary data loaded on first access
- Trackpoints loaded only when needed
- Calculated tracks cached after first computation

### Indexes

Critical indexes for common queries:
- `activityId` - Primary key lookups
- `BeginTimestamp` - Date-sorted lists
- `activityTypeDetail` - Type filtering

### Batch Operations

For bulk imports:
```objc
[db beginTransaction];
// Multiple inserts/updates
[db commit];
```
