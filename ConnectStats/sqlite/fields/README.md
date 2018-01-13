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


