# ConnectStats Architecture

> High-level system architecture and component overview

## Overview

ConnectStats is a mature iOS fitness tracking app (since 2012) that imports and analyzes activity data from multiple sources: Garmin Connect, Strava, HealthKit, and the ConnectStats Server backend.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              iOS App Layer                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐  │
│  │ GCTabBarController│  │GCSplitViewController│  │    View Controllers      │  │
│  │   (iPhone)       │  │     (iPad)         │  │ List, Detail, Stats, Map │  │
│  └────────┬─────────┘  └─────────┬──────────┘  └────────────┬────────────┘  │
│           │                      │                          │               │
│           └──────────────────────┴──────────────────────────┘               │
│                                  │                                          │
│                                  ▼                                          │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                         GCAppGlobal                                   │   │
│  │                  (Singleton - Central Access Point)                   │   │
│  │                                                                       │   │
│  │  +organizer  +health  +derived  +web  +db  +worker  +profile         │   │
│  └──────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────────┘   │
│         │         │         │         │         │         │                 │
│         ▼         ▼         ▼         ▼         ▼         ▼                 │
│  ┌──────────┐┌─────────┐┌────────┐┌────────┐┌──────┐┌───────────┐          │
│  │Activities││ Health  ││Derived ││  Web   ││  DB  ││  Profile  │          │
│  │Organizer ││Organizer││Organizer│Connect ││(FMDB)││           │          │
│  └────┬─────┘└────┬────┘└────┬───┘└───┬────┘└──┬───┘└───────────┘          │
│       │           │          │        │        │                            │
└───────┼───────────┼──────────┼────────┼────────┼────────────────────────────┘
        │           │          │        │        │
        ▼           ▼          ▼        │        ▼
┌──────────────────────────────────┐    │   ┌────────────────────┐
│          Data Models             │    │   │   SQLite Database   │
│  ┌─────────┐ ┌───────────────┐   │    │   │  ┌──────────────┐  │
│  │GCActivity│ │  GCField     │   │    │   │  │gc_activities │  │
│  │ +Fields  │ │  GCLap       │   │    │   │  │gc_track      │  │
│  │ +Series  │ │  GCTrackPoint│   │    │   │  │gc_laps       │  │
│  │ +Laps    │ │  GCWeather   │   │    │   │  └──────────────┘  │
│  └─────────┘ └───────────────┘   │    │   └────────────────────┘
└──────────────────────────────────┘    │
                                        │
                                        ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                          Network Layer                                      │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                         GCWebConnect                                  │  │
│  │              Request Queue + Service Status Tracking                  │  │
│  └──────┬────────────────┬─────────────────┬───────────────┬────────────┘  │
│         │                │                 │               │               │
│         ▼                ▼                 ▼               ▼               │
│  ┌────────────┐  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐       │
│  │  Garmin    │  │   Strava    │  │ ConnectStats │  │  HealthKit  │       │
│  │  SSO Auth  │  │  OAuth 2.0  │  │  OAuth 1.0a  │  │  Native API │       │
│  │  Requests  │  │  Requests   │  │  Requests    │  │  Requests   │       │
│  └────────────┘  └─────────────┘  └──────────────┘  └─────────────┘       │
└────────────────────────────────────────────────────────────────────────────┘
                    │                │                 │
                    ▼                ▼                 ▼
            ┌───────────┐    ┌────────────┐    ┌───────────────────┐
            │  Garmin   │    │   Strava   │    │  ConnectStats     │
            │  Connect  │    │    API     │    │  Server           │
            │           │    │            │    │  (FIT files,      │
            │           │    │            │    │   Weather, etc.)  │
            └───────────┘    └────────────┘    └───────────────────┘
```

## Core Components

### GCAppGlobal (Singleton)

Central access point for all shared services. Provides class methods to access:

| Property | Type | Purpose |
|----------|------|---------|
| `organizer` | GCActivitiesOrganizer | Activity list management |
| `health` | GCHealthOrganizer | HealthKit integration |
| `derived` | GCDerivedOrganizer | Calculated statistics |
| `web` | GCWebConnect | Network request coordination |
| `db` | FMDatabase | Main SQLite database |
| `worker` | dispatch_queue_t | Background processing |
| `profile` | GCAppProfiles | User profiles & settings |

**Location:** `ConnectStats/src/GCAppGlobal.h`

### GCActivitiesOrganizer

Manages the activity list with support for:
- Lazy loading of activity summaries and details
- Filtering by activity type
- Search functionality
- Current activity tracking
- Notifications on data changes

**Key Notifications:**
- `kNotifyOrganizerLoadComplete` - Initial load finished
- `kNotifyOrganizerListChanged` - Activity list modified
- `kNotifyOrganizerReset` - Data cleared/reset

**Location:** `ConnectStats/src/GCActivitiesOrganizer.h`

### GCWebConnect

Network coordinator using a queue-based request system:
- Sequential request processing
- Per-service status tracking (Garmin, Strava, ConnectStats, HealthKit)
- Automatic retry with remediation requests
- Background sync support

**Location:** `ConnectStats/src/GCWebConnect.h`

## Design Patterns

### 1. Singleton Pattern
`GCAppGlobal` provides centralized access to all services via class methods.

### 2. Organizer Pattern
Manager classes (`GCActivitiesOrganizer`, `GCHealthOrganizer`, `GCDerivedOrganizer`) own and manage collections of domain objects.

### 3. Category/Extension Pattern
Core classes use extensive Objective-C categories for modularity:
- `GCActivity+Database` - Persistence
- `GCActivity+Fields` - Field access
- `GCActivity+Series` - Time/distance series
- `GCActivity+Import` - Data import

### 4. Observer Pattern (RZChildObject)
View controllers attach to organizers to receive update notifications:
```objc
[self.organizer attach:self];  // Register
[self.organizer detach:self];  // Unregister
```

### 5. Request Chain Pattern
Network requests can chain via `nextReq` for pagination and multi-stage operations.

## External Dependencies

| Dependency | Purpose |
|------------|---------|
| [RZUtils](https://github.com/roznet/rzutils) | Units, statistics, graphs |
| [FitFileParser](https://github.com/roznet/FitFileParser) | Garmin FIT parsing |
| GoogleMaps | Map visualization |
| OAuthSwift | Strava OAuth 2.0 |
| FMDB | SQLite wrapper |

## Language Mix

- **Objective-C (91%)**: Core models, data layer, older ViewControllers
- **Swift (9%)**: Modern UI components, new service requests, extensions

New code is written in Swift when possible, with `@objc` interop for Objective-C integration.

## File Organization

```
ConnectStats/src/
├── GCActivity*.{h,m,swift}     # Activity data model + categories
├── GCActivitiesOrganizer.{h,m} # Activity list management
├── GCAppGlobal.{h,m,swift}     # Singleton access point
├── GCAppDelegate.{h,m,swift}   # App lifecycle
├── GCWebConnect.{h,m}          # Network coordinator
├── GC{Service}Request*.{h,m,swift} # Service-specific requests
├── GC*ViewController.{h,m,swift}   # View controllers
├── GCCell*.{h,m,swift}         # Table view cells
├── GCField*.{h,m}              # Field metadata
├── GCTrackPoint.{h,m}          # GPS data points
├── GCLap.{h,m}                 # Lap data
└── GCViewConfig.{h,m}          # UI configuration
```
