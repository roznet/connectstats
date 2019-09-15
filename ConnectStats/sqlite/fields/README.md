## Add a new Field

### Add default unit/Description

1. search for `NEWTRACKFIELD`
2. `-[GCTrackPoint parseDictionary:]`: add field if necessary
3. add to `fields_en_manual.db`
4. rerun `build.py`, this rebuilds the fields.db that the app will use 
5. if new unit, add to `GCUnit.m`

### Connect IQ Field

1. Same steps as above
2. Edit `GCField+Convert.m`
3. Edit developer.json

## Update Activity Types

1. copy new `activity_types.json` into `sqlite/fields/activity_types_en.json`
2. Download modern activity TYpes from `https://connect.garmin.com/modern/proxy/activity-service/activity/activityTypes?_=1521579380211` (identify exact url with charles) and copy into `sqlite/fields/activity_types_modern.json`
3. rebuild fields.db

## Summary Graphs

|                  |1 Field|2 Fields|Field 1 Requirement|Data Filter|Period|YTD  |
| ---------------- | ----- | ------ | ----------------- | --------- | ---- | --- |
|Bar Average       |o|x|x|o|o|x|
|Bar Sum           |o|x|canSum|o|o|x|
|Line Average      |o|x|x|o|o|x|
|Cumulative Plot   |o|x|canSum|x|o|o|
|Scatter Plot      |o|o|x|o|x|x|
|Performance Plot  |o|?|canSum|x|x|x|
|Best Rolling      |o|x|hasDerived|x|x|x|
|Histogram         |o|x|x|o|x|x|

## Options

|Data Filter| all, last 3m, last 6m, last year |
| --------- | -------------------------------  |
| Period    | weekly,monthly,yearly            |
| YTD       | yes,no                           |

## Flags

| gcViewChoice     |What to display |  all, monthly, weekly, yearly, summary |
| ------------     | -------------  | -------------------------------------- |
| gcHistoryStats   | Data Filter    | all, monthly, weekly | 
| gcStatsCalChoice | Period         | All, 3m, 6m, 1y, to date, |
| useFilter        | Use full list or filtered list | BOOL |


