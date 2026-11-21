---
name: release-ios
description: Build a signed Xcode archive of ConnectStats ready for App Store upload — runs the release pre-flight (real credentials, production server default, privacy files), the unit tests, picks the next build number from App Store Connect, bumps the version, archives, verifies, tags, writes the App Store notes and stages the version on App Store Connect. Invoke with an optional bump type (build / patch / minor / major).
disable-model-invocation: true
---

# Release ConnectStats to the App Store

Archive the **ConnectStats** iOS app (scheme `ConnectStats`, bundle id
`net.ro-z.connectstats`) and stage it on App Store Connect. Ported from
flyfun-weather's `/release-ios`; the ConnectStats-specific traps are called out
inline.

Helper scripts (all in `scripts/`):

| Script | Does |
|---|---|
| `check_credentials.py` | Blocks a build that would ship sample / placeholder API keys |
| `bump_version.py` | Reads / sets the version of the **ConnectStats target only** |
| `asc.py` | App Store Connect API: `status`, `latest-build`, `stage` (never submits) |

## Arguments

`/release-ios [build|patch|minor|major]` — default: ask.

- **build** — new build number only, same `MARKETING_VERSION` (a re-upload / TestFlight build)
- **patch** — 9.0 → 9.0.1, 9.0.1 → 9.0.2
- **minor** — 9.0 → 9.1, 9.0.1 → 9.1
- **major** — 9.0 → 10.0

ConnectStats has used both `X.Y` and `X.Y.Z` (tags `8.0.1`, `9.0`). Patch adds or
increments the third component; minor increments the second and drops the third.

If not specified, ask:
> Current version: X.Y (build N). Bump type? [build / patch / minor / major]

**`rehearsal`** (or "dry run"): run Steps 1, 2, 4 and 5 for real, but skip the
bump commit and archive to `$CLAUDE_JOB_DIR/tmp/ConnectStats-rehearsal.xcarchive`
instead of `~/Library/Developer/Xcode/Archives/`, so it never shows in
Organizer. Draft the Step 6 notes without saving them. Nothing is committed,
tagged, pushed or uploaded; run `asc.py` read-only (`status`, `latest-build`)
if it is set up. Use it a few days before a release to surface problems early.

## Where to run it

Prefer the **main checkout** (`~/Developer/public/connectstats`) on `master`.
`ConnectStats/credentials.json` and `.env` are gitignored. Without
`credentials.json` the build phase "Check Credentials" silently copies
`credentials.sample.json` in and the binary ships `***` keys. `.worktreeinclude`
makes Claude Code copy both into the worktrees it creates. For a manual
`git worktree add`, copy them yourself. Check 2a catches a missing or sample
file either way.

## Step 1 — Read current version

```bash
python3 scripts/bump_version.py
```

Show: "Current version: X.Y (build N)". Step 3 checks the build number against
App Store Connect.

## Step 2 — Pre-flight checks

Report all of these as a checklist before going on. **Stop** on any marked blocking.

### 2-0 — Sync with origin and pin the commit (blocking)

```bash
git fetch -q origin
git status -sb | head -1          # must not say [behind N]
git rev-parse HEAD origin/master  # should match
PINNED_SHA=$(git rev-parse HEAD); echo "$PINNED_SHA"
```

- **Behind** `origin/master`: stop; offer `git pull --ff-only`.
- **Ahead**: unpushed commits will ship. Say so and ask whether to push first.
- Not on `master`: warn, ask whether this is intended.

Tell the user not to pull or switch branches in this checkout until Step 7.

### 2a — Credentials (blocking)

```bash
python3 -I scripts/check_credentials.py
```

`FAIL` blocks (missing file, identical to the sample, a value still `***`, empty
values). `WARN` lists keys present in the sample but not in the real file —
decide per key whether the app has a fallback. Known OK: `garmin*.oauth2_client_id`
(the server's status check supplies `garmin_client_id` first) and
`garmin*.oauth2_authenticate_url` (defaults to Garmin's URL in
`GCGarminOAuth2Login.swift`). Anything else new: read the code that uses it.

### 2b — Production server default (blocking)

The server is chosen at runtime, not by `#if DEBUG`. The fallback for users who
never changed it must be production:

```bash
grep -n 'CONFIG_CONNECTSTATS_CONFIG defaultValue' ConnectStats/src/GCAppGlobal.m
```

Must read `defaultValue:gcWebConnectStatsConfigProductionConnectStatsApp`. Also:

- `GCConnectStatsStatus.m`: the active `statusURL` must be
  `https://connectstats.app/prod/api/status/app`. A `localhost.ro-z.me` line may
  exist only commented out:
  `grep -n 'statusURL = ' ConnectStats/src/GCConnectStatsStatus.m`.
- `GCWebUrl.m`: in `GCWebUseSimulator`, the `https://localhost` default must stay
  inside `#if TARGET_IPHONE_SIMULATOR`, with `connectstats.app` in the `#else`.
- `GCWebUseSimulator(true, …)` is switched on in a release build, deliberately.
  It is the **App Review demo login** in `GCWebConnect+Requests.m`
  (`isGarminSimulatorAccount`: a username starting `simulator`/`testaccount`
  with one of the hard-coded tester passwords). What must hold: the calls stay
  behind `isGarminSimulatorAccount`, and `+[GCAppGlobal simulatorUrl]` returns
  `nil`, so a device falls back to `https://connectstats.app`:
  ```bash
  grep -rn 'GCWebUseSimulator(true' ConnectStats/src
  grep -n -A2 '+(NSString\*)simulatorUrl' ConnectStats/src/GCAppGlobal.m   # must be: return nil;
  ```
  A localhost URL in `simulatorUrl` would send App Review to your Mac. Block.

### 2c — Info.plist and privacy manifest

`ConnectStats/ConnectStats-Info.plist` must have (blocking):
`ITSAppUsesNonExemptEncryption = false`, and a usage string for each permission
the app asks for — `NSLocationWhenInUseUsageDescription`,
`NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`,
`NSPhotoLibraryUsageDescription`. Without the encryption key, every build
stops at "Missing Compliance" in App Store Connect and `asc.py` cannot attach it.

```bash
plutil -p ConnectStats/ConnectStats-Info.plist | grep -E 'ITSApp|Usage'
find ConnectStats -name PrivacyInfo.xcprivacy
```

`ConnectStats/PrivacyInfo.xcprivacy` must exist and be in the ConnectStats
target's Resources (blocking):

```bash
plutil -lint ConnectStats/PrivacyInfo.xcprivacy
grep -c 'PrivacyInfo.xcprivacy in Resources' ConnectStats.xcodeproj/project.pbxproj   # expect 2 (build file + phase)
```

Then check it is still true (warn, and propose an edit):

- **New required-reason APIs** since the last tag — UserDefaults, file
  timestamps (`modificationDate`, `creationDate`, `NSFileModificationDate`),
  boot time (`systemUptime`, `mach_absolute_time`), disk space
  (`volumeAvailableCapacity`, `NSFileSystemFreeSize`), `activeInputModes`:
  `git diff {last_tag}..HEAD -- ConnectStats/src | grep -E '^\+.*(UserDefaults|modificationDate|creationDate|systemUptime|mach_absolute_time|volumeAvailableCapacity|NSFileSystemFreeSize|activeInputModes)'`.
  Each category must be in the manifest with a reason code.
- **New data leaving the device** (new server endpoint payloads, new SDK):
  add it to the manifest's `NSPrivacyCollectedDataTypes`.
- **New SPM package**: does it ship its own `PrivacyInfo.xcprivacy`? If not,
  its API use is the app's to declare.

**The App Store Connect App Privacy label must cover the manifest plus every
SDK's manifest** (Google Maps adds Usage Data, Device ID, Crash/Performance
Data, Other Data). Expected label (2026-11-21): Usage Data, Location (precise),
Health & Fitness (Fitness only — HealthKit data never leaves the device),
Diagnostics, Identifiers (User ID, Device ID), Contact Info (Email — optional
bug-report contact), Other Data. If the manifest changed, remind the user to
update the label in App Store Connect → App Privacy before submitting.

### 2d — Package pinning and local overrides (blocking)

```bash
grep -n '/Users/\|XCLocalSwiftPackageReference' ConnectStats.xcodeproj/project.pbxproj || echo "no local package overrides"
git ls-files --error-unmatch ConnectStats.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
test -e Podfile && echo "Podfile present — CocoaPods is back, stop"
```

Local package paths (a sibling `rzutils` checkout, say) must be reverted to the
remote SPM reference. `Package.resolved` must be committed so the archive (and
Xcode Cloud) uses the package versions that were tested; if it is untracked or
modified, stop and commit it. Why: until 2026-11 it was untracked, the main
checkout stayed on ZIPFoundation 0.9.20, and any fresh checkout resolved 0.9.21 —
which removed the failable `Archive(...)` init and broke the build.

### 2e — Uncommitted changes (blocking unless explained)

`git status --porcelain` must be empty (untracked tooling dirs like `.agents/`
are fine). Uncommitted source changes would be built into the archive without
being in any commit.

### 2f — Debug leftovers (warn only)

New `print(` / `NSLog(` and `TODO`/`FIXME` since the last tag:
```bash
git diff {last_tag}..HEAD -- ConnectStats/src | grep -E '^\+.*(print\(|NSLog\(|TODO|FIXME)' | head -20
```

### 2g — Unit tests (blocking)

The `ConnectStats` scheme's test action runs `ConnectStatsXCTests` (there is no
UI test suite): 109 tests, ~55 s on the MacBook with warm DerivedData
(2026-11-21); a cold build takes several minutes, so run it with
`run_in_background: true`:

```bash
R="$CLAUDE_JOB_DIR/tmp/release-tests.xcresult"; rm -rf "$R"
xcodebuild test -project ConnectStats.xcodeproj -scheme ConnectStats \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -resultBundlePath "$R" \
  > "$CLAUDE_JOB_DIR/tmp/release-tests.log" 2>&1; echo rc=$?
grep -E 'error:|failed \(' "$CLAUDE_JOB_DIR/tmp/release-tests.log" | tail -25
xcrun xcresulttool get test-results summary --path "$R"
```

Read `totalTestCount` / `failedTests` from the summary rather than trusting
`** TEST SUCCEEDED **`: a run that executes zero tests also "succeeds". Expect
about 109. Run the tests **signed**, without `CODE_SIGNING_ALLOWED=NO`: the
profile tests use the keychain and fail with `OSStatus -34018` in an unsigned
build.

(Pick another device from `xcrun simctl list devices available` if that name is
gone; use a job/scratch dir if `$CLAUDE_JOB_DIR` is unset.) On failure, stop and
show the failing tests. Retry once on a simulator-boot flake before calling it real.

### 2h — App Store Connect state (if `asc.py` is set up)

```bash
source venv/bin/activate && python3 scripts/asc.py status
```

Warn now if a version is already `WAITING_FOR_REVIEW` / `IN_REVIEW`: Step 8
will refuse to touch it, and cancelling a submission is the user's call. Better
to know before spending ten minutes on an archive.

## Step 3 — Pick the build number and bump

Compute the marketing version from the bump type first. Build numbers only have
to be unique **within a marketing version**, and ConnectStats restarts them for
each version (9.0 shipped as build 1; 8.0.2 as 1–3). Ask App Store Connect for
the next free one for the new version:

```bash
source venv/bin/activate && python3 scripts/asc.py latest-build --version {X.Y}
```

- **New marketing version** (patch/minor/major): normally `NEXT_BUILD=1`.
- **Build-only bump**: the version's highest uploaded build + 1. If the project's
  build is already higher (archived but never uploaded), use project + 1.

If `asc.py` is unavailable (no venv or no `.env`, see "One-time setup"): use 1
for a new version; for a build-only bump ask the user for the last build of that
version shown in App Store Connect → TestFlight. A duplicate is rejected at
upload, so the fix is to re-run with a higher number.

Then:

```bash
[ "$(git rev-parse HEAD)" = "$PINNED_SHA" ] || echo "HEAD MOVED since pre-flight — stop"
python3 scripts/bump_version.py --build {NEXT_BUILD} [--marketing {X.Y}]
git add ConnectStats.xcodeproj/project.pbxproj
git commit -m "Bump version to {X.Y} (build {N}) for App Store release"
```

Commit **before** archiving so the archive corresponds to a real commit. If HEAD
moved, stop, show `git log --oneline $PINNED_SHA..HEAD`, and re-run the pre-flight.

**Xcode Cloud:** an Xcode Cloud setup exists (`xcshareddata/xcodecloud/`), but
up to 9.0 every App Store build was archived locally with the project's own
build number (9.0 build 1, uploaded 2026-02-21). If an Xcode Cloud workflow ever
starts uploading builds, its counter won't see local uploads, so set its "next
build number" above `{N}`.

## Step 4 — Clean and archive

Don't run this while a test run is still building: both use the same
DerivedData and fight over its build database.

```bash
LOG="$CLAUDE_JOB_DIR/tmp/archive.log"
xcodebuild clean -project ConnectStats.xcodeproj -scheme ConnectStats -configuration Release > /dev/null

ARCHIVE_PATH=~/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)/"ConnectStats $(date +%d-%m-%Y,\ %H.%M).xcarchive"
xcodebuild archive \
  -project ConnectStats.xcodeproj \
  -scheme ConnectStats \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  > "$LOG" 2>&1; echo rc=$?
tail -3 "$LOG"; grep -E 'error:' "$LOG" | sort -u | head -20
echo "$ARCHIVE_PATH"
```

Keep the full log in a file: `| tail -20` loses the first error when a build
fails. Signing is automatic (team `M7QSSF3624`); `-allowProvisioningUpdates`
lets Xcode fetch profiles on a new Mac. The path under `Archives/` makes it show
up in Organizer. With a warm compilation cache this takes under a minute even
after `clean` (37 s, 2026-11-21); a cold one takes several. Timeout 600000 ms,
run in the background.

## Step 5 — Verify the archive

```bash
/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleShortVersionString" "$ARCHIVE_PATH/Info.plist"
/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleVersion" "$ARCHIVE_PATH/Info.plist"
/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleIdentifier" "$ARCHIVE_PATH/Info.plist"
git status --porcelain -- ConnectStats ConnectStats.xcodeproj
[ "$(git rev-parse HEAD~1)" = "$PINNED_SHA" ] && echo "parent is pinned commit"
```

Version, build and `net.ro-z.connectstats` must match Step 3; the tree must be
clean and HEAD's parent the pinned commit. Otherwise delete the archive and
start over from the pre-flight — the binary may mix sources from two commits.

Then check what actually went into the app (blocking):

```bash
APP="$ARCHIVE_PATH/Products/Applications/ConnectStats.app"
cmp -s "$APP/credentials.json" ConnectStats/credentials.json && echo "credentials: real" || echo "credentials: NOT the real file — stop"
ls "$APP/PrivacyInfo.xcprivacy" && ls "$ARCHIVE_PATH/dSYMs/ConnectStats.app.dSYM" > /dev/null && echo "privacy manifest + dSYM present"
codesign -dv "$APP" 2>&1 | grep -E 'Identifier=|TeamIdentifier'
```

The credentials comparison is the real proof for 2a: it checks the file the
binary will ship, not just the one in the checkout. The signing identity in the
archive is **Apple Development**, which is expected. The upload in Step 8
re-signs it for distribution with the App Store Connect key.

## Step 6 — Release notes

Find the previous version tag. Tags are the plain marketing version (`9.0`,
`8.0.1`, `7.3` — no prefix):

```bash
git tag -l '[0-9]*' --sort=-version:refname | head -5
git log {previous_tag}..HEAD --oneline --no-merges
```

For a build-only bump the previous tag is the one *before* the current marketing
version, so the notes cover the whole version.

Write user-facing "What's New": 4–8 plain-language bullets grouped by theme
(Garmin, Strava, sync, stats/graphs, fixes); leave out refactors, CI, docs and
dependency moves unless users notice them (e.g. "removed analytics SDK" is worth
a line for privacy). Show the notes and **wait for approval**, then save them
verbatim to `release-notes/ios-{X.Y}.txt` (plain text, `- ` bullets) and commit:
`Release notes for iOS {X.Y}`.

## Step 7 — Tag (ask before pushing)

Confirm HEAD is still bump commit + notes commit (`git log --oneline -3`).

- New marketing version: `git tag {X.Y}`
- Build-only bump (tag exists): `git tag -f {X.Y}` — moves it to the build actually shipped

Ask before `git push origin master` and `git push origin {X.Y}` (add `--force`
for a moved tag). Pushing the bump commit may trigger Xcode Cloud if a workflow
is set to start on `master`.

## Step 8 — Stage on App Store Connect

Skip to the manual route in Step 9 if `asc.py` isn't set up.

```bash
source venv/bin/activate
python3 scripts/asc.py status
python3 scripts/asc.py stage \
  --version {X.Y} --build {N} \
  --archive "$ARCHIVE_PATH" \
  --notes-file release-notes/ios-{X.Y}.txt
```

Offer `--dry-run` first. Behaviour (all normal):

- **No submit, by design.** The user presses Submit for Review in the web UI.
- **Re-runnable.** Reuses / renames the editable version, overwrites What's New.
- **Auto-release on approval** (`AFTER_APPROVAL`); pass `--release-type MANUAL` only if asked.
- **Processing wait** 5–30 min after upload; if it times out run
  `python3 scripts/asc.py wait-build --version X.Y --build N` — do not re-upload.
- **Refuses** a version already `WAITING_FOR_REVIEW` / `IN_REVIEW`; cancelling is the user's call.

Leave App Review notes alone unless the user asks (`--review-notes "…"`): the
reviewer demo-account text is maintained in App Store Connect. That demo account
is the simulator login checked in 2b. If the reviewer can't sign in, check that
the notes still give a username starting `simulator`/`testaccount` and a password
that `isGarminSimulatorAccount` accepts.

## Step 9 — Report

- Pre-flight checklist (with any WARNs the user accepted)
- Test result (count, duration)
- Archive path, version, build
- Tag created / moved, and whether commits and tag were pushed
- The approved release notes
- If staged: final `asc.py status`; remind them to press **Submit for Review**
- If not staged: Xcode → Window → Organizer → Distribute App → App Store Connect,
  then paste the notes in by hand
- Next step for the privacy label if the manifest changed

## One-time setup (asc.py)

Only needed for Steps 3 and 8. Per the owner's rule, **ask before creating a venv**.

```bash
python3 -m venv venv && source venv/bin/activate && pip install -r scripts/requirements.txt
cp scripts/env.sample .env   # then fill in ASC_KEY_ID / ASC_ISSUER_ID
```

The App Store Connect API key is team-wide; the values in flyfun-weather's `.env`
work here unchanged, and the `.p8` is read from
`~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8`. The key needs the App
Manager role. `.env`, `venv/` and `*.p8` are gitignored.
