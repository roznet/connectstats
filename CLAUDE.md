# ConnectStats

iOS app (ConnectStats) and macOS app (FitFileExplorer) for analysing fitness activities
from Garmin, Strava, HealthKit and the ConnectStats server. Mixed Objective-C and Swift.

Start with `designs/INDEX.md` — it maps the modules to their design docs.

## Layout

| Path | What |
|---|---|
| `ConnectStats/src/` | App code (Obj-C + Swift), shared by the iOS targets |
| `FitFileExplorer/src/` | macOS FIT file explorer |
| `ConnectStatsTests/`, `FitFileExplorerTests/` | Unit tests |
| `HealthStats/`, `connectstatstestapp/` | Legacy / test-harness targets, not shipped |
| `designs/` | Design docs (architecture, data model, services, DB schema, types) |
| `scripts/` | `asc.py` (App Store Connect), `set_version.py` (per-app version bump) |

Dependencies are Swift packages (RZUtils, RZExternal, FitFileParser, FMDB, GoogleMaps, …);
resolved versions live in `ConnectStats.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
CocoaPods is gone once #114 lands — until then a `Podfile` means `pod install` first.

## Build and test

Always use the workspace. Pick a simulator that exists (`xcrun simctl list devices available`).

```bash
xcodebuild -workspace ConnectStats.xcworkspace -scheme ConnectStats \
  -destination 'generic/platform=iOS Simulator' build
xcodebuild -workspace ConnectStats.xcworkspace -scheme ConnectStats \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
xcodebuild -workspace ConnectStats.xcworkspace -scheme FitFileExplorer \
  -destination 'platform=macOS' test
```

- Tests must run **signed**: the profile tests use the keychain and fail with
  `OSStatus -34018` when built with `CODE_SIGNING_ALLOWED=NO`.
- `ConnectStats/credentials.json` (gitignored; template `credentials.sample.json`) is needed
  to build. `.worktreeinclude` copies it into Claude-created worktrees; for a manual
  `git worktree add`, copy it yourself.
- CI (`.github/workflows/main.yml`) only builds the ConnectStats scheme; it runs no tests.

## Objective-C memory management

The ConnectStats, HealthStats and ConnectStatsTestApp targets compile Obj-C **without ARC**
(manual retain/release); a few files override per target with `-fobjc-arc` /
`-fno-objc-arc` (e.g. `GCMapGoogleViewController.m` is ARC in ConnectStats, MRC elsewhere).
FitFileExplorer and all Swift are ARC.

- In Obj-C use the RZUtils macros — `RZReturnAutorelease`, `RZAutorelease`, `RZRetain`,
  `RZRelease` — which are correct under both modes. Don't write raw `autorelease`/`release`.
- New retained properties in MRC classes need a release in `dealloc`.
- New code goes in Swift where practical (`designs/swift-modernization.md`), usually as an
  extension of the Obj-C class exposed with `@objc`.

## Things that bite

- **Activity type strings change over time** (Garmin dropped `_SNOWBOARDING_WS` suffixes,
  etc.). If a mapping in `GCActivityTypes.m` returns nil the activity is silently dropped on
  import — keep old and new names. See `designs/activity-types.md`.
- **Database changes need migrations** for existing users' databases
  (`designs/database-schema.md`); never assume a fresh DB.
- **Duplicate handling across services must stay order-independent**
  (`designs/service-integrations.md`).

## Git and review workflow

- Default branch is `master`; merge PRs with `--rebase`.
- Every push to a PR is reviewed by the Claude bot (`.github/workflows/claude-code-review.yml`
  running `.claude/commands/code-review.md`). `/process-review` triages its comment;
  `/land-pr <n>` merges and finishes the remaining findings on master.
- `@claude` in an issue or PR comment runs Claude on GitHub (`claude.yml`; Ubuntu, so it can't
  build).
- Never commit `credentials.json`, `.env` or `*.p8`.

## Releasing

`/archive [connectstats|fitfileexplorer] [build|patch|minor|major]` runs the pre-flight
checks and tests, bumps the version above App Store Connect's latest build (Xcode Cloud
has its own numbering), archives, tags and stages the version on App Store Connect. It never
submits for review — that stays a manual press in App Store Connect. Needs `venv/`
(`scripts/requirements-release.txt`) and `.env` (`.env.sample`).
