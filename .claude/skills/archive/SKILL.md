---
name: archive
description: Archive ConnectStats (iOS) or FitFileExplorer (macOS) for the App Store — pre-flight checks, version bump above App Store Connect's latest build, tests, archive, tag and release notes, then stage it on App Store Connect (version, What's New, upload, build attached) with scripts/asc.py. Never submits for review. Invoke with an optional app (connectstats / fitfileexplorer) and bump type (build / patch / minor / major).
disable-model-invocation: true
---

# Archive for App Store

Build an Xcode archive and stage it on App Store Connect, ready for the user to press
**Submit for Review**. Adapted from the flyfun-weather / flyfun-forms `archive` skills.

## Arguments

The user may give **app** and **version bump** in any order (`/archive build`,
`/archive fitfileexplorer patch`):

**App** (default `connectstats`):
- **connectstats** — the iOS app
- **fitfileexplorer** — the macOS app (a separate App Store app, its own versions)

HealthStats and ConnectStatsTestApp are not shipped — refuse them.

**Version bump** (default: ask):
- **build** — only the build number; marketing version unchanged (resubmission / fix)
- **patch** — last component (9.0 → 9.1, 9.0.1 → 9.0.2) + build
- **minor** — middle component, reset last (9.0 → 10.0 for two-part, 9.1.2 → 9.2.0) + build
- **major** — first component, reset rest (9.0 → 10.0, 3.5.1 → 4.0.0) + build

If the bump is not given, ask:
> Current {app} version: X.Y (build N). Bump type? [build / patch / minor / major]

## Per-app settings

| Setting | connectstats | fitfileexplorer |
|---|---|---|
| Scheme | `ConnectStats` | `FitFileExplorer` |
| Archive destination | `generic/platform=iOS` | `generic/platform=macOS` |
| Test destination | a concrete iPhone simulator, e.g. `platform=iOS Simulator,name=iPhone 17 Pro` | `platform=macOS` |
| Info.plist | `ConnectStats/ConnectStats-Info.plist` | `FitFileExplorer/FitFileExplorer-Info.plist` |
| Tag | `{version}` (continues `9.0`, `8.0.1`, …) | `FitFileExplorer_{version}` (continues `FitFileExplorer_3.3.0`) |
| Release notes file | `release-notes/connectstats-{version}.txt` | `release-notes/fitfileexplorer-{version}.txt` |
| `asc.py --app` | `connectstats` | `fitfileexplorer` |

Pick a simulator the machine actually has (`xcrun simctl list devices available`) if
`iPhone 17 Pro` isn't present. Always `-workspace ConnectStats.xcworkspace`.

## Step 0 — Tooling

- **Python venv** for `scripts/asc.py`. If `venv/` is missing, **ask the user** before
  creating it (their standing rule), then:
  `python3 -m venv venv && venv/bin/pip install -r scripts/requirements-release.txt`.
  If they decline, the App Store Connect steps (2i, the build-number lookup, Step 9) are
  skipped and the report ends with the manual Organizer route.
- **`.env`** with `ASC_KEY_ID` / `ASC_ISSUER_ID` (see `.env.sample`; the team-wide key from
  flyfun-weather works). Missing → same fallback. Never print `.env` values.
- `gh` and anything talking to Apple must run with the sandbox disabled.

## Step 1 — Read current version

```bash
python3 scripts/set_version.py --app {app}     # prints "<marketing> <build>"
```

It reads only the app's own Debug + Release configurations (ConnectStats and
ConnectStatsTestApp both sit at build 1, so a plain find-and-replace would be wrong).

Then the build number App Store Connect has already seen — Xcode Cloud uploads builds with
its own numbering, and the project's `CURRENT_PROJECT_VERSION` is often behind it:

```bash
venv/bin/python3 scripts/asc.py latest-build --app {app}    # "<build> (version X.Y)" or "none"
```

Show: "Current {app} version: X.Y (build N in project, latest on App Store Connect M)".

## Step 2 — Pre-flight checks

Run all of them, then report a checklist. **Stop** on any marked *stop*.

### 2a — Credentials (connectstats; *stop*)

`ConnectStats/credentials.json` must exist and must not be the sample (no value equal to
`"***"`): the app embeds it, and an archive built from the sample cannot sign in to Garmin,
Strava or the ConnectStats server.

```bash
test -f ConnectStats/credentials.json && ! grep -q '"\*\*\*"' ConnectStats/credentials.json && echo ok
```

Never print the file.

### 2b — Production server defaults (connectstats; *stop*)

- `GCAppGlobal.m`: the `CONFIG_CONNECTSTATS_CONFIG` default must be
  `gcWebConnectStatsConfigProductionConnectStatsApp`.
- `GCConnectStatsStatus.m`: the active `statusURL` must be `https://connectstats.app/prod/...`
  (a `localhost.ro-z.me` line may exist only commented out).
- `GCWebUrl.m`: `GCWebUseSimulator`'s localhost default must stay inside
  `#if TARGET_IPHONE_SIMULATOR`.

### 2c — Tests (*stop* on failure)

```bash
rm -rf /tmp/archive-tests.xcresult
xcodebuild test \
  -workspace ConnectStats.xcworkspace \
  -scheme {scheme} \
  -destination "{test_destination}" \
  -resultBundlePath /tmp/archive-tests.xcresult \
  -quiet 2>&1 | tail -30
xcrun xcresulttool get test-results summary --path /tmp/archive-tests.xcresult
```

Run signed (don't pass `CODE_SIGNING_ALLOWED=NO`): the profile tests read the keychain and
fail with `OSStatus -34018` in an unsigned build. Use `run_in_background: true` with a long
timeout. Read `totalTestCount` / `failedTests` from the summary rather than trusting
`** TEST SUCCEEDED **` (a filter that matches nothing "succeeds" with zero tests). On a
simulator-boot flake retry once before calling it a real failure.

### 2d — Uncommitted changes and branch

`git status` — warn on anything beyond what this run will change (Xcode builds the working
tree, so uncommitted edits ship). Warn (don't block) if not on `master`.

### 2e — Leftover CocoaPods (*stop*)

If a `Podfile` exists the dependencies are not all Swift packages: stop and say `pod install`
is needed (or that the CocoaPods removal hasn't been merged).

### 2f — Local package overrides (*stop*)

```bash
grep -n '/Users/' ConnectStats.xcodeproj/project.pbxproj || echo "no local package overrides"
```

Absolute paths to a sibling checkout (a local `rzutils`, `FitFileParser`, …) must be reverted
to the remote package before archiving.

### 2g — Info.plist and privacy (*stop* on the plist items)

- `ITSAppUsesNonExemptEncryption` = `false` (`/usr/libexec/PlistBuddy -c 'Print
  :ITSAppUsesNonExemptEncryption' {plist}`) — without it every build stops at "Missing
  Compliance" and `asc.py` can't attach it.
- connectstats: `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`,
  `NSLocationWhenInUseUsageDescription`, `NSPhotoLibraryUsageDescription` present.
- `PrivacyInfo.xcprivacy`: if the app target has none, **warn** (don't block). Apple asks
  apps using "required reason" APIs (UserDefaults, file timestamps, disk space) to declare
  them and emails an ITMS-91053 notice after upload when missing.

### 2h — Debug-only code (warn only)

New `NSLog(` / `print(` in UI code, `TODO` / `FIXME` added since the previous tag.

### 2i — App Store Connect state

```bash
venv/bin/python3 scripts/asc.py status --app {app}
```

Warn if a version is already `WAITING_FOR_REVIEW` / `IN_REVIEW`: staging will refuse to touch
it, and cancelling a submission is the user's call.

## Step 3 — Bump version

- **Build number** = max(project build, App Store Connect latest build) + 1. Build numbers
  here are plain integers; if App Store Connect was unreachable, use project + 1 and warn
  that Xcode Cloud may already have used it (the upload would then be rejected as a
  duplicate — re-run with a higher number).
- **Marketing version** per the bump type.

```bash
python3 scripts/set_version.py --app {app} --marketing {new_marketing} --build {new_build}
```

(Omit `--marketing` for a build-only bump.) Show: "Bumped to X.Y (build N)".

## Step 4 — Clean

```bash
xcodebuild clean -workspace ConnectStats.xcworkspace -scheme {scheme} -configuration Release
```

## Step 5 — Archive

```bash
ARCHIVE_PATH=~/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)/"{scheme} $(date +%d-%m-%Y,\ %H.%M).xcarchive"
xcodebuild archive \
  -workspace ConnectStats.xcworkspace \
  -scheme {scheme} \
  -configuration Release \
  -destination "{archive_destination}" \
  -archivePath "$ARCHIVE_PATH" \
  CODE_SIGN_STYLE=Automatic \
  | tail -20
```

Keep the path for later steps; under `~/Library/Developer/Xcode/Archives/` it also shows in
Organizer. Allow a generous timeout (600000 ms).

## Step 6 — Verify archive

```bash
/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleShortVersionString" "$ARCHIVE_PATH/Info.plist"
/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleVersion" "$ARCHIVE_PATH/Info.plist"
```

Both must match Step 3.

## Step 7 — Commit the version bump

Stage `ConnectStats.xcodeproj/project.pbxproj` only:
```
Bump {app} to X.Y (build N) for App Store release
```
Do NOT push unless the user asks.

## Step 8 — Tag and release notes

### Tags

Tags track the **marketing version** only (see the table for the pattern). A build-only bump
**moves** the existing tag (`git tag -f`, then `git push --force` for that one tag); a new
marketing version creates a new tag. The two apps have independent tag histories — never
mix them up when looking for the previous version.

### Release notes

Previous tag for this app:
```bash
git tag -l --sort=-version:refname | grep -E '^[0-9]'                 # connectstats
git tag -l 'FitFileExplorer_*' --sort=-version:refname                # fitfileexplorer
```
Then `git log {previous_tag}..HEAD --oneline`. For fitfileexplorer keep only commits that
touched what it ships (`FitFileExplorer/` or shared packages).

Write user-facing notes for the "What's New in This Version" box:
- group related changes; plain language, no hashes or jargon
- what a user notices: features, fixes, supported devices/services
- skip tests, CI, refactoring, version bumps, docs, dependency swaps with no visible effect
- 5–8 bullets max, British English

Show them and **wait for approval**; apply edits. Then write the approved text exactly as
it should appear to the release-notes file from the table (one `- ` bullet per line; it may
already exist for a build-only bump — overwrite if the notes changed) and commit it on its
own: `Release notes for {app} {version}`.

Push the tag only after the user confirms.

## Step 9 — Stage on App Store Connect

`scripts/asc.py` creates or reuses the App Store version, writes What's New, uploads the
archive, waits for Apple to process it, and attaches the build. **It cannot submit for
review, by design** — there is no such subcommand; the user presses Submit in App Store
Connect.

The version is set to **release automatically once Apple approves** (`AFTER_APPROVAL`):
pressing Submit is the release gate. Pass `--release-type MANUAL` only if the user asks to
hold the release.

Offer `--dry-run` first. Then:

```bash
venv/bin/python3 scripts/asc.py stage \
  --app {app} \
  --version {marketing_version} \
  --build {build_number} \
  --archive "$ARCHIVE_PATH" \
  --notes-file release-notes/{app}-{version}.txt
```

Pass `--review-notes "…"` only with text the user gives you for App Review (e.g. how to try
the app without a Garmin account).

Normal behaviour, not errors:
- **Re-running is safe.** It reuses the editable version (renaming it if the marketing
  version changed) and overwrites What's New. Re-run to correct a mistake or swap a binary.
- **It waits for Apple.** Processing takes ~5–30 min. Use a 600000 ms timeout; if still
  going, re-run `venv/bin/python3 scripts/asc.py wait-build --app {app} --version X.Y
  --build N` then `attach-build` with the same arguments — **do not re-upload**.
- **It stops at in-review versions** and refuses to edit them.

## Step 10 — Report

- Pre-flight checklist results (including the privacy-manifest warning if it applies)
- App, archive path, version and build in the archive
- Tag created or moved; release notes and the file they were saved to
- **If Step 9 ran:** staged on App Store Connect with What's New and the build attached —
  review it in the web UI and press **Submit for Review**; it goes live automatically on
  approval (show the final `asc.py status`, with `release type: AFTER_APPROVAL`).
- **If Step 9 was skipped:** Xcode → Window → Organizer → Distribute App → App Store Connect,
  then paste What's New by hand.
- Remind them to push the version-bump and release-notes commits.
