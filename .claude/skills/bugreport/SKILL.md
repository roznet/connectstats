---
name: bugreport
description: Download and analyze a ConnectStats bug report. Use when user provides a bugreport ID or says "bugreport", "bug report", "look at bug", etc.
allowed-tools: Read, Grep, Glob, Edit, Write, Task, Bash, WebFetch
---

# ConnectStats Bug Report Analyzer

Download a bug report from the ConnectStats server, extract it, parse the logs and user description, and start investigating the issue.

## Prerequisites

- `CS_PASSWORD` environment variable must be set (or will be prompted)
- `jq` and `unzip` must be available
- The connectstats project should be the current working directory

## When Invoked

### Arguments

- **bugreport ID** (required): numeric ID of the bug report (e.g., `/bugreport 142`)

### Workflow

#### Step 1: Load context from design docs

Before diving in, load the relevant design docs to understand schemas and architecture:

```
# App-side database schema (activities_bugreport.db, track_*.db)
get_design_doc(library="connectstats", topic="database-schema")

# Server-side bugreport system and data model
get_design_doc(library="connectstats_server", topic="bugreport")

# If investigating data issues, also load:
get_design_doc(library="connectstats", topic="data-model")
get_design_doc(library="connectstats", topic="activity-types")

# If investigating server-side storage or FIT files:
get_design_doc(library="connectstats_server", topic="storage")
get_design_doc(library="connectstats_server", topic="api-endpoints")
```

#### Step 2: Create working directory and download

```bash
# Create a working directory for this bug report
mkdir -p /tmp/bugreport_{id}
cd /tmp/bugreport_{id}

# Download the JSON metadata
curl -s -u brice:${CS_PASSWORD} "https://connectstats.app/prod/bugreport/export?id={id}" | jq . > bugreport_meta.json

# Download the zip
curl -s -o bugreport_{id}.zip -u brice:${CS_PASSWORD} "https://connectstats.app/prod/bugreport/export?id={id}&zip"

# Extract it
unzip -o bugreport_{id}.zip
```

#### Step 3: Read and summarize the bug report metadata

Read `bugreport_meta.json` and present a summary:
- **User description** (the `description` field - this is what the user reported)
- **App version** (`version`)
- **Device** (`platformString`)
- **OS** (`systemName` / `systemVersion`)
- **Date** (`updatetime`)
- **Email** (`email` - if provided)
- **Common ID** (`commonid` - links related reports)

#### Step 4: Parse the log file

Read `bugreport.log`. The log format is:
```
YYYY-MM-DD HH:MM:SS.sss pid LEVEL:filename:line:method; message
```

Where LEVEL is one of: `INFO`, `ERR `, `WARN`

Focus on:
1. **ERR lines** - these are errors, show them prominently
2. **WARN lines** - warnings that may be relevant
3. **Patterns** - repeated errors, error sequences, timing of errors relative to user actions
4. Look for common issues: type mapping failures, network errors, database errors, parsing failures

#### Step 5: Check other files in the zip

The zip may contain:
- `bugreport.log` - app logs (always present)
- `activities_bugreport.db` - SQLite database of user's activities (same schema as main db — see `connectstats:database-schema` design doc)
- `track_*.db` - track database for the current activity (GPS points, HR, power, etc.)
- `settings_bugreport.json` / `settings_bugreport.plist` - app settings
- `missing_fields.json` - fields the app couldn't parse
- `error_last_search_cs_*.json` - cached error responses from server

List what files were extracted and note which ones are available for deeper investigation.

#### Step 6: Query the app databases

Use the schema from the `connectstats:database-schema` design doc to write queries. Start with these diagnostics:

**activities_bugreport.db** (app-side SQLite):
```bash
# Activity count and types
sqlite3 activities_bugreport.db "SELECT activityType, COUNT(*) FROM gc_activities GROUP BY activityType ORDER BY COUNT(*) DESC;"

# Recent activities
sqlite3 activities_bugreport.db "SELECT activityId, activityType, datetime(BeginTimestamp, 'unixepoch') as date, SumDistance, SumDuration FROM gc_activities ORDER BY BeginTimestamp DESC LIMIT 20;"

# Check for NULL values (NaN persisted as NULL — a known bug pattern)
sqlite3 activities_bugreport.db "SELECT a.activityId, a.activityType, v.field, v.value, v.uom FROM gc_activities a JOIN gc_activities_values v ON a.activityId = v.activityId WHERE v.value IS NULL LIMIT 20;"

# Check summary values for a specific activity
sqlite3 activities_bugreport.db "SELECT field, value, uom FROM gc_activities_values WHERE activityId = '{activityId}' ORDER BY field;"
```

**track_*.db** (per-activity trackpoint data):
```bash
# Count trackpoints
sqlite3 track_{activityId}.db "SELECT COUNT(*) FROM gc_track;"

# Sample trackpoints
sqlite3 track_{activityId}.db "SELECT * FROM gc_track LIMIT 5;"

# Check laps
sqlite3 track_{activityId}.db "SELECT * FROM gc_laps;"

# Check extra fields
sqlite3 track_{activityId}.db "SELECT DISTINCT field FROM gc_track_extra;" 2>/dev/null
```

#### Step 7: Initial analysis

Based on the user's description and the log errors:
1. Summarize what the user is experiencing
2. Identify the most likely area of code involved (use source file:line references from the log)
3. If there are ERR lines, map them to source code in the connectstats project
4. Cross-reference database findings with log errors
5. If `missing_fields.json` exists, check for field mapping issues
6. If error JSON files exist, check for server-side issues

#### Step 8: Start investigating

Using the connectstats project source code:
- Look up the source files referenced in error log lines
- Cross-reference with design docs (use `list_libraries` / `get_design_doc`)
- Propose hypotheses for the root cause
- Suggest next steps for debugging

### Output Format

Present findings as:

```
## Bug Report #{id}

### User Report
> {description from the user}

### Environment
- Device: {platformString}
- OS: {systemName} {systemVersion}
- App: {applicationName} {version}
- Date: {updatetime}

### Log Analysis
**Errors found: {count}**
{list of ERR lines with source references}

**Warnings: {count}**
{summary of WARN lines if relevant}

### Files Available
{list of extracted files}

### Database Summary
{activity counts, types, any anomalies found}

### Initial Assessment
{analysis connecting user description to log evidence}

### Hypotheses
1. {most likely cause}
2. {alternative cause}

### Next Steps
- {suggested investigation steps}
```

## Fetching Server-Side Data

The bugreport only contains the app-side snapshot. When you need server-side data, ask the user to fetch it. The server project is at `~/Developer/public/connectstats_server` — see the `connectstats_server` design docs for full details.

### Get raw activity JSON from server
Ask the user to run on the server:
```bash
php setup/debugdata.php {activity_id}
```
This dumps the raw Garmin JSON the server stored for the activity — shows original field names and values before any app-side mapping. Useful when the app-side type mapping or field parsing is suspect.

### Fetch a FIT file from S3
FIT files are stored in S3 (see `connectstats_server:storage` design doc). The S3 path follows the pattern:
```
assets/users/{cs_user_id}/{fileType}/{file_id}.{fileType}
```
Ask the user to retrieve the FIT file from S3 for the activity in question. The `file_id` can be found in the server's `activities` or `fitfiles` table. Once downloaded, you can parse it with the FitFileParser library (see `FitFileParser` design docs).

FIT files downloaded by the app are saved locally as:
- `track_cs_{serviceActivityId}.fit` (from ConnectStats server)
- `track_csalt_{externalActivityId}.fit` (from Garmin fallback)

### Check the admin web interface
The server has a bugreport viewer at `bugreport/list.php?id={id}` which shows:
- Color-coded log output with links to GitHub source lines
- Links to open `.db` files in phpliteadmin
- Related reports by commonid

### Server API endpoints
See `connectstats_server:api-endpoints` design doc for the full API. Key endpoints for debugging:
- `api/connectstats/search` — activity search (paginated, returns Garmin JSON as-is)
- `api/connectstats/file` — FIT file download (by activity_id)
- `api/connectstats/json` — activity detail/weather data

## Common Bug Patterns

### Silent activity drops (no data for certain activity types)
- **Symptom:** User reports missing activities, log shows no errors
- **Cause:** Activity type mapping returns nil in `GCActivityTypes.m:activityTypeForConnectStatsType:`
- **Check:** Look at `error_last_search_cs_*.json` for the raw `activityType` strings from Garmin
- **Investigation:** The Garmin API periodically changes type strings (e.g., dropped `_SNOWBOARDING_WS` suffix). When `changeActivityType:nil` is called, the activity import is silently skipped (`GCActivity+Import.m` guard clause). See `connectstats:activity-types` design doc.

### NaN/missing summary values
- **Symptom:** User sees "nan" for power, HR, speed, or other metrics
- **Cause:** Incomplete FIT SESSION messages create GCActivitySummaryValue with NaN, which overwrites valid server data and persists as NULL in SQLite
- **Check:** `SELECT field, value FROM gc_activities_values WHERE activityId = 'X' AND value IS NULL;`
- **Investigation:** Track database may have valid data in `gc_track` records even when summary is NaN. Fetch the FIT file from S3 to inspect SESSION vs RECORD messages.

### FIT file re-download loop
- **Symptom:** High bandwidth usage, repeated download attempts in log
- **Cause:** Unparseable FIT file with no empty track DB created to mark completion
- **Check:** Look for repeated `FIT data could not be parsed` warnings for the same activity

### Database errors
- **Symptom:** ERR lines with "DB error" or "DB Error" in log
- **Check:** Schema migrations in `GCActivity+Database.m:ensureDbStructure:`. See `connectstats:database-schema` design doc for the full schema and migration history.

## Tips

- The `commonid` field links related bug reports from the same user — if non-empty and not "-1", there may be earlier reports worth checking
- Log source references like `GCActivity.m:425` map to `ConnectStats/src/GCActivity.m` line 425
- Settings JSON can reveal user configuration that might trigger edge cases (e.g., which services are enabled, metric vs imperial)
- Error JSON files contain raw server responses that failed to parse — check the `activityType` field values
- When the bugreport db doesn't have enough info, ask the user to run server-side debug scripts or fetch data from S3
- The server is type-agnostic — it stores raw Garmin JSON and returns it as-is. All type mapping happens app-side.
- `downloadMethod` in gc_activities tells you how far the download got: 0=search list only, 1=activity details fetched, 2=FIT file downloaded and parsed
