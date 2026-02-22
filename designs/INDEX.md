# ConnectStats

> iOS fitness activity tracking app - analyzing data from Garmin, Strava, HealthKit, and ConnectStats Server

## Modules

### architecture
High-level system architecture and component overview. Start here to understand how the app is structured.
→ Full doc: architecture.md

### data-model
Core data structures: GCActivity, fields, laps, track points. How activities and their measurements are represented.
Key exports: `GCActivity`, `GCField`, `GCTrackPoint`, `GCLap`, `GCActivitySummaryValue`
→ Full doc: data-model.md

### service-integrations
Garmin, Strava, HealthKit, and ConnectStats Server sync. Auth flows, request handling, multi-service duplicate merging, and error recovery.
Key exports: `GCWebConnect`, `GCGarminReqBase`, `GCConnectStatsRequest`
→ Full doc: service-integrations.md

### database-schema
SQLite persistence layer and migrations. How activities, tracks, and health data are stored.
Key exports: `GCDerivedOrganizer`, `FMDatabase`
→ Full doc: database-schema.md

### ui-architecture
ViewControllers, navigation, and adaptive layout. Patterns for table-based UI and cell data sources.
Key exports: `GCCellGrid`, `GCSimpleGraphCachedDataSource`, `GCStatsMultiFieldViewController`
→ Full doc: ui-architecture.md

### activity-types
Activity type mapping from Garmin, Strava, and FIT files to internal types. Mapping tables, hierarchy, import flow, and how to add/maintain type mappings.
Key exports: `GCActivityType`, `GCActivityTypes`
→ Full doc: activity-types.md

### swift-modernization
Strategy for Obj-C to Swift migration. Guidelines for incremental modernization of the codebase.
→ Full doc: swift-modernization.md

## Key External Dependencies

| Dependency | Purpose |
|------------|---------|
| [RZUtils](https://github.com/roznet/rzutils) | Units, statistics, graphs, DataFrame |
| [FitFileParser](https://github.com/roznet/FitFileParser) | Garmin FIT file parsing |
| [connectstats_server](https://github.com/roznet/connectstats_server) | Backend for FIT files, weather |

## Getting Started

1. **Understand the architecture**: Start with architecture.md
2. **Data model**: Review data-model.md for GCActivity and related classes
3. **Service sync issues**: See service-integrations.md for auth flows and error handling
4. **UI changes**: Refer to ui-architecture.md for view controller patterns
