# ConnectStats

iOS app (ConnectStats) and macOS app (FitFileExplorer) for analysing fitness activities
from Garmin, Strava, HealthKit and the ConnectStats server. Mixed Objective-C and Swift.

Start with `designs/INDEX.md`. It maps the modules to their design docs.

## Layout

| Path | What |
|---|---|
| `ConnectStats/src/` | App code (Obj-C + Swift), shared by the iOS targets |
| `FitFileExplorer/` | macOS FIT file explorer |
| `ConnectStatsTests/`, `FitFileExplorerTests/` | Unit tests |
| `HealthStats/`, `connectstatstestapp/` | Legacy / test-harness targets, not shipped |
| `designs/` | Design docs (architecture, data model, services, DB schema, types) |
| `scripts/` | Release tooling: `asc.py`, `bump_version.py`, `check_credentials.py` |

Dependencies are Swift packages only (RZUtils, RZExternal, FitFileParser, FMDB, GoogleMaps, …).
Resolved versions are committed in
`ConnectStats.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`. Keep
it committed: a fresh resolve can pick up a breaking package release (ZIPFoundation 0.9.21
did, 2026-11).

## Build and test

Pick a simulator that exists (`xcrun simctl list devices available`).

```bash
xcodebuild -project ConnectStats.xcodeproj -scheme ConnectStats \
  -destination 'generic/platform=iOS Simulator' build
xcodebuild -project ConnectStats.xcodeproj -scheme ConnectStats \
  -destination 'platform=iOS Simulator,name=iPhone 17' test     # ~109 tests
xcodebuild -project ConnectStats.xcodeproj -scheme FitFileExplorer \
  -destination 'platform=macOS' test
```

- Tests must run **signed**: the profile tests use the keychain and fail with
  `OSStatus -34018` when built with `CODE_SIGNING_ALLOWED=NO`.
- `ConnectStats/credentials.json` (gitignored; template `credentials.sample.json`) is needed
  to build. If it is missing, a build phase silently copies the sample in, so the
  app builds but can't sign in anywhere. `.worktreeinclude` copies it into
  Claude-created worktrees. For a manual `git worktree add`, copy it yourself.
- CI (`.github/workflows/main.yml`) only builds the ConnectStats scheme; it runs no tests.

## Objective-C memory management

The ConnectStats, HealthStats and ConnectStatsTestApp targets compile Obj-C **without ARC**
(manual retain/release); a few files override per target with `-fobjc-arc` /
`-fno-objc-arc` (e.g. `GCMapGoogleViewController.m` is ARC in ConnectStats, MRC elsewhere).
FitFileExplorer and all Swift are ARC.

- In Obj-C use the RZUtils macros (`RZReturnAutorelease`, `RZAutorelease`, `RZRetain`,
  `RZRelease`), which are correct under both modes. Don't write raw `autorelease`/`release`.
- New retained properties in MRC classes need a release in `dealloc`.
- New code goes in Swift where practical (`designs/swift-modernization.md`), usually as an
  extension of the Obj-C class exposed with `@objc`.

## Things that bite

- **Activity type strings change over time** (Garmin dropped `_SNOWBOARDING_WS` suffixes,
  etc.). If a mapping in `GCActivityTypes.m` returns nil, the activity is silently dropped on
  import, so keep both old and new names. See `designs/activity-types.md`.
- **Database changes need migrations** for existing users' databases
  (`designs/database-schema.md`); never assume a fresh DB.
- **Duplicate handling across services must stay order-independent**
  (`designs/service-integrations.md`).
- **Privacy manifest**: new required-reason APIs or new data sent off the device must be
  added to `ConnectStats/PrivacyInfo.xcprivacy` and to the App Store privacy label.

## Git

- Default branch is `master`.
- Never commit `credentials.json`, `.env` or `*.p8`.
- Skills live in `.claude/skills/` with a copy in `.agents/skills/`. Keep the two in sync.

## Releasing

`/release-ios [build|patch|minor|major]` runs the pre-flight checks and tests, takes the
next build number for the new version from App Store Connect, bumps the version,
archives, tags and stages the version on App Store Connect. It never submits for review;
that stays a manual press in App Store Connect. Needs `venv/` (`scripts/requirements.txt`)
and `.env` (`scripts/env.sample`).
