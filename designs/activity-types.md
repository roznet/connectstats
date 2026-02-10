# Activity Type Mapping

> How activity types from Garmin, Strava, and FIT files are mapped to internal ConnectStats types

## Overview

ConnectStats receives activity type identifiers from three external sources, each using a different naming convention. The type mapping system converts these into a unified internal hierarchy of ~90 types stored in `fields.db`.

```
External Sources                    Internal Types

Garmin:  "RESORT_SKIING"  ────┐
Strava:  "AlpineSki"      ────┼──→  "resort_skiing_snowboarding_ws"
FIT:     ALPINE_SKIING     ────┘
```

**Key files:**
- `GCActivityTypes.m` — Mapping tables and resolution logic
- `GCActivityType.{h,m}` — Type class, hierarchy, factory methods
- `GCActivity+Import.m` — Where types are resolved during activity parsing

---

## Type Hierarchy

Types form a tree rooted at `all`. Each type has a parent, and the first level below `all` defines the "primary" type used for field grouping and display preferences.

```
all (17)
├── running (1)
│   ├── trail_running (6)
│   ├── street_running (7)
│   ├── track_running (8)
│   ├── treadmill_running (18)
│   ├── indoor_running (156)
│   ├── virtual_run (153)
│   └── obstacle_run (154)
├── cycling (2)
│   ├── mountain_biking (5)
│   ├── road_biking (10)
│   ├── indoor_cycling (25)
│   ├── gravel_cycling (143)
│   ├── virtual_ride (152)
│   ├── cyclocross (19)
│   ├── downhill_biking (20)
│   ├── track_cycling (21)
│   ├── recumbent_cycling (22)
│   └── bmx (131)
├── swimming (26)
│   ├── lap_swimming
│   └── open_water_swimming
├── hiking (3)
├── walking (9)
│   ├── casual_walking
│   └── speed_walking
├── fitness_equipment (29)
│   ├── elliptical
│   ├── indoor_rowing
│   ├── stair_climbing
│   ├── strength_training
│   └── indoor_cardio
├── winter_sports (165)
│   ├── resort_skiing_snowboarding_ws (172)
│   ├── backcountry_skiing_snowboarding_ws (169)
│   ├── cross_country_skiing_ws (171)
│   ├── skate_skiing_ws (170)
│   ├── snow_shoe_ws (167)
│   ├── skating_ws (168)
│   └── snowmobiling_ws (166)
├── multi_sport (89)
├── transition (83)
│   ├── swimToBikeTransition (84)
│   ├── bikeToRunTransition (85)
│   └── runToBikeTransition (86)
├── other (4)
├── motorcycling (71)
└── diving (144)
    ├── single_gas_diving (145)
    ├── multi_gas_diving (146)
    ├── gauge_diving (147)
    └── apnea_diving (148)
```

Types are loaded from `fields.db` at startup (`loadPredefined` in `GCActivityTypes.m`). The log line `Registered 90 ActivityTypes` confirms successful loading.

---

## Mapping Tables

### ConnectStats Server Types (Garmin via server)

**Method:** `activityTypeForConnectStatsType:` in `GCActivityTypes.m:549`

Maps UPPERCASE Garmin strings from the ConnectStats server JSON to internal keys.

```
UPPERCASE input              →  internal key
─────────────────────────────────────────────
RUNNING                      →  running
STREET_RUNNING               →  street_running
TRAIL_RUNNING                →  trail_running
TREADMILL_RUNNING            →  treadmill_running
TRACK_RUNNING                →  track_running
INDOOR_RUNNING               →  running
OBSTACLE_RUN                 →  running
ULTRA_RUN                    →  running
CYCLING                      →  cycling
ROAD_BIKING                  →  road_biking
MOUNTAIN_BIKING              →  mountain_biking
INDOOR_CYCLING               →  indoor_cycling
GRAVEL_CYCLING               →  cycling
DOWNHILL_BIKING              →  downhill_biking
TRACK_CYCLING                →  track_cycling
RECUMBENT_CYCLING            →  recumbent_cycling
CYCLOCROSS                   →  cyclocross
BMX                          →  cycling
E_BIKE_FITNESS               →  cycling
E_BIKE_MOUNTAIN              →  mountain_biking
E_ENDURO_MTB                 →  mountain_biking
ENDURO_MTB                   →  mountain_biking
HANDCYCLING                  →  cycling
INDOOR_HANDCYCLING           →  indoor_cycling
SWIMMING                     →  swimming
LAP_SWIMMING                 →  lap_swimming
OPEN_WATER_SWIMMING          →  open_water_swimming
HIKING                       →  hiking
RUCKING                      →  hiking
WALKING                      →  walking
CASUAL_WALKING               →  casual_walking
SPEED_WALKING                →  speed_walking
FITNESS_EQUIPMENT            →  fitness_equipment
ELLIPTICAL                   →  elliptical
INDOOR_CARDIO                →  indoor_cardio
INDOOR_ROWING                →  indoor_rowing
STAIR_CLIMBING               →  stair_climbing
STRENGTH_TRAINING            →  strength_training
RESORT_SKIING_SNOWBOARDING_WS→  resort_skiing_snowboarding_ws
RESORT_SKIING                →  resort_skiing_snowboarding_ws  (new)
SNOWBOARDING_WS              →  resort_skiing_snowboarding_ws
BACKCOUNTRY_SKIING_SNOWBOARDING_WS → backcountry_skiing_snowboarding_ws
BACKCOUNTRY_SKIING           →  backcountry_skiing_snowboarding_ws  (new)
BACKCOUNTRY_SNOWBOARDING     →  backcountry_skiing_snowboarding_ws
CROSS_COUNTRY_SKIING_WS      →  cross_country_skiing_ws
CROSS_COUNTRY_SKIING         →  cross_country_skiing_ws  (new)
SKATE_SKIING_WS              →  skate_skiing_ws
SKATE_SKIING                 →  skate_skiing_ws  (new)
SNOW_SHOE_WS                 →  snow_shoe_ws
SNOW_SHOE                    →  snow_shoe_ws  (new)
SKATING_WS                   →  skating_ws
SNOWMOBILING_WS              →  snowmobiling_ws
SNOWMOBILING                 →  snowmobiling_ws  (new)
TRANSITION                   →  transition
TRANSITION_V2                →  transition
SWIM_TO_BIKE_TRANSITION      →  swimToBikeTransition
SWIM_TO_BIKE_TRANSITION_V2   →  swimToBikeTransition
BIKE_TO_RUN_TRANSITION       →  bikeToRunTransition
BIKE_TO_RUN_TRANSITION_V2    →  bikeToRunTransition
RUN_TO_BIKE_TRANSITION       →  runToBikeTransition
RUN_TO_BIKE_TRANSITION_V2    →  runToBikeTransition
SWIMTOBIKETRANSITION         →  swimToBikeTransition
BIKETORUNTRANSITION          →  bikeToRunTransition
RUNTOBIKETRANSITION          →  runToBikeTransition
MULTI_SPORT                  →  multi_sport
VIRTUAL_RIDE                 →  virtual_ride
VIRTUAL_RUN                  →  virtual_run
MOTORCYCLING                 →  motorcycling
OTHER                        →  other
GOLF                         →  golf
ROWING                       →  rowing
PADDLING                     →  paddling
BOATING                      →  boating
SAILING                      →  sailing
FLYING                       →  flying
MOUNTAINEERING               →  mountaineering
HORSEBACK_RIDING             →  horseback_riding
INLINE_SKATING               →  inline_skating
STAND_UP_PADDLEBOARDING      →  stand_up_paddleboarding
WHITEWATER_RAFTING_KAYAKING   →  whitewater_rafting_kayaking
WIND_KITE_SURFING            →  wind_kite_surfing
DRIVING_GENERAL              →  driving_general
```

**Fallback:** If no match, tries `[input lowercaseString]` against known type keys via `isExistingActivityType:`.

### Strava Types

**Method:** `activityTypeForStravaType:` in `GCActivityTypes.m:491`

Maps PascalCase Strava type strings. Has a safer fallback than ConnectStats mapping.

```
PascalCase input     →  internal key
──────────────────────────────────────
Run                  →  running
Ride                 →  cycling
Swim                 →  swimming
Hike                 →  hiking
Walk                 →  walking
Workout              →  fitness_equipment
AlpineSki            →  resort_skiing_snowboarding_ws
BackcountrySki       →  backcountry_skiing_snowboarding_ws
NordicSki            →  cross_country_skiing_ws
Snowboard            →  resort_skiing_snowboarding_ws
Snowshoe             →  snow_shoe_ws
EBikeRide            →  cycling
VirtualRide          →  cycling
VirtualRun           →  running
Elliptical           →  elliptical
WeightTraining       →  strength_training
StairStepper         →  stair_climbing
Rowing               →  rowing
Canoeing             →  boating
Kayaking             →  whitewater_rafting_kayaking
Kitesurf             →  wind_kite_surfing
Windsurf             →  wind_kite_surfing
StandUpPaddling      →  stand_up_paddleboarding
Surfing              →  surfing
RockClimbing         →  rock_climbing
RollerSki            →  skate_skiing
IceSkate             →  skating
InlineSkate          →  inline_skating_ws
Crossfit             →  fitness_equipment
Yoga                 →  other
(unknown)            →  other  (with log message)
```

**Fallback:** Unknown Strava types default to `other` and log `"Registering missing Strava Type X as Other"`.

### FIT Sport / SubSport

**Method:** `activityTypeForFitSport:andSubSport:` in `GCActivityTypes.m:337`

Maps FIT file sport and subsport enum names. **SubSport takes precedence** when both are present.

**Resolution order:**
1. SubSport explicit mapping (if present and mapped)
2. SubSport lowercase as type key (fallback)
3. Sport explicit mapping
4. Sport lowercase as type key (fallback)

Key sport mappings: `RUNNING→running`, `CYCLING→cycling`, `SWIMMING→swimming`, `HIKING→hiking`, `WALKING→walking`, `FITNESS_EQUIPMENT→fitness_equipment`, `TRANSITION→transition`, `MULTISPORT→multi_sport`, `ROWING→rowing`, `ALPINE_SKIING→resort_skiing_snowboarding_ws`, `CROSS_COUNTRY_SKIING→cross_country_skiing_ws`, `SNOWBOARDING→resort_skiing_snowboarding_ws`, `TENNIS→tennis`

Key subsport overrides: `TREADMILL→treadmill_running`, `TRAIL→trail_running`, `STREET→street_running`, `ROAD→road_biking`, `MOUNTAIN→mountain_biking`, `INDOOR_CYCLING→indoor_cycling`, `INDOOR_ROWING→indoor_rowing`, `LAP_SWIMMING→lap_swimming`, `OPEN_WATER→open_water_swimming`, `GRAVEL_CYCLING→gravel_cycling`, `BACKCOUNTRY→backcountry_skiing_snowboarding_ws`, `SKATE_SKIING→skate_skiing_ws`

---

## Import Flow and Failure Modes

### ConnectStats JSON (most common path)

```
Server JSON { "activityType": "RUNNING" }
    │
    ▼
activityTypeForConnectStatsType:  →  GCActivityType or nil
    │
    ▼
changeActivityType:  →  no-op if nil passed
    │
    ▼
Guard: if (self.activityId && self.activityType)
    │                              │
    ▼                              ▼
  Parse summary data         SKIP SILENTLY ← danger
```

**Critical:** If the mapping returns nil, `changeActivityType:nil` is a no-op, `self.activityType` stays nil, and the guard at `GCActivity+Import.m:425` silently skips all data parsing. The activity exists but has no summary data. **No error is logged.**

### Strava JSON (safer)

Same flow but with explicit fallback:
```objc
GCActivityType * atype = [GCActivityType activityTypeForStravaType:data[@"type"]];
[self changeActivityType:atype];
if (self.activityType == nil) {
    [self changeActivityType:[GCActivityType other]];  // ← fallback
}
```

### FIT File (via FitFileParser)

FIT sport/subsport are resolved at FIT parse time. The FIT parser creates a `GCActivity` with the resolved type. If resolution fails, the activity type comes from the search JSON instead (which was already set before the FIT file was downloaded).

---

## How to Add a New Activity Type

### When Garmin adds a new type string

1. **Identify the new string** — Check the server's raw JSON or app logs for unrecognized types. Activities with unmapped types will be silently dropped (ConnectStats path) or logged (Strava path).

2. **Find or create the internal type key:**
   - Check if a matching key exists in `fields.db` (`gc_activity_types` table)
   - If not, either map to an existing parent type (e.g., new cycling variant → `cycling`) or add a new row to `gc_activity_types`

3. **Add the mapping** in `GCActivityTypes.m`:
   - For ConnectStats/Garmin: add to the dictionary in `activityTypeForConnectStatsType:` (~line 560)
   - For Strava: add to the dictionary in `activityTypeForStravaType:` (~line 500)
   - For FIT: add to sport or subsport dictionary in `activityTypeForFitSport:andSubSport:` (~line 340)

4. **Handle both old and new names** if Garmin is renaming a type (they've done this with skiing types). Map both names to the same internal key.

### When Garmin renames an existing type

This has happened with skiing types (2024: dropped `_WS` suffixes). The fix is to add the new name alongside the old one:

```objc
@"RESORT_SKIING_SNOWBOARDING_WS": @"resort_skiing_snowboarding_ws",  // old
@"RESORT_SKIING":                 @"resort_skiing_snowboarding_ws",  // new
```

Both names must be kept because:
- Old activities on the server still use the old name
- New activities use the new name
- The server stores raw Garmin JSON and returns it as-is

### Legacy type remapping

If an internal key is renamed, add a mapping in `remappedLegacy:` (`GCActivityTypes.m:312`). This is used during database upgrades to rename types in existing activities.

---

## Debugging Type Issues

### Symptoms of unmapped types
- Activities appear in the list but with no summary data (distance, time, pace all missing)
- Activity count in search response doesn't match activities displayed
- No error in logs (the failure is silent for ConnectStats types)

### How to diagnose
- Check the server's raw JSON for the activity's `activityType` field
- Search for the uppercase string in `activityTypeForConnectStatsType:` dictionary
- If missing, that's the problem — add the mapping

### Fallback behavior
- The lowercase fallback (`isExistingActivityType:[input lowercaseString]`) only works if the lowercased Garmin string happens to match an existing internal key exactly
- Example: `ROWING` → `rowing` works (key exists), but `RESORT_SKIING` → `resort_skiing` fails (key is `resort_skiing_snowboarding_ws`)

---

## Type-Specific Display Behavior

Types influence display through these properties on `GCActivityType`:

| Property | Effect | Types |
|----------|--------|-------|
| `isPacePreferred` | Show min/km instead of km/h | running, hiking, walking |
| `isSki` | Enable ski-specific lap detection | ski_down, ski_back, ski_xc |
| `isElevationLossPreferred` | Show elevation loss prominently | ski_down |
| `preferredSpeedDisplayUnit` | Unit for speed field | swimming→min/100m, running→min/km, cycling→km/h |
