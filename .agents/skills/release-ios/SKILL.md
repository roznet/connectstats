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

## Where to run it

Run from the **main checkout** (`~/Developer/public/connectstats`), not a worktree.
`ConnectStats/credentials.json` and `ConnectStats.xcodeproj/.../Package.resolved`
are only in the main checkout: in a fresh worktree the build phase "Check
Credentials" silently copies `credentials.sample.json` in (the binary ships `***`
keys) and SPM resolves whatever package versions are newest. If you must use a
worktree, copy `credentials.json` over first and let the 2a check confirm it.

## Step 1 — Read current version

```bash
python3 scripts/bump_version.py
```

Show: "Current version: X.Y (build N)". The local build number is not meaningful
on its own (it sat at `1` while Xcode Cloud numbered the builds) — Step 3 takes
the real one from App Store Connect.

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

Must read `defaultValue:gcWebConnectStatsConfigProductionConnectStatsApp`. Also
check `GCWebUseSimulator` is only enabled from test / debug code paths:
`grep -rn 'GCWebUseSimulator(' ConnectStats/src | grep -v 'void GCWebUseSimulator'`.

### 2c — Info.plist and privacy manifest

`ConnectStats/ConnectStats-Info.plist` must have (blocking):
`ITSAppUsesNonExemptEncryption = false`, and a usage string for each permission
the app asks for — `NSLocationWhenInUseUsageDescription`,
`NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`,
`NSPhotoLibraryUsageDescription`.

```bash
plutil -p ConnectStats/ConnectStats-Info.plist | grep -E 'ITSApp|Usage'
find ConnectStats -name PrivacyInfo.xcprivacy
```

A `PrivacyInfo.xcprivacy` in the app target is expected by App Review (required-
reason APIs: UserDefaults, file timestamps, disk space, system boot time). If it
is missing, **warn** and offer to add one before archiving; Apple currently
emails ITMS-91053 warnings rather than rejecting, but that can change.

### 2d — Package pinning and local overrides (blocking)

```bash
grep -n '/Users/\|XCLocalSwiftPackageReference' ConnectStats.xcodeproj/project.pbxproj || echo "no local package overrides"
git ls-files --error-unmatch ConnectStats.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
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
UI test suite): 109 tests, ~1 min incremental on the MacBook (2026-11-21); a
cold build is several minutes, so run it with `run_in_background: true`:

```bash
xcodebuild test -project ConnectStats.xcodeproj -scheme ConnectStats \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -resultBundlePath "$CLAUDE_JOB_DIR/tmp/release-tests.xcresult" \
  > "$CLAUDE_JOB_DIR/tmp/release-tests.log" 2>&1; echo rc=$?
grep -E 'Executed|TEST (SUCCEEDED|FAILED)|error:|failed \(' "$CLAUDE_JOB_DIR/tmp/release-tests.log" | tail -25
```

(Pick another device from `xcrun simctl list devices available` if that name is
gone; use a job/scratch dir if `$CLAUDE_JOB_DIR` is unset.) On failure, stop and
show the failing tests. Retry once on a simulator-boot flake before calling it real.

## Step 3 — Pick the build number and bump

Build numbers must be higher than anything already uploaded for this app —
including Xcode Cloud builds, which never touched the local project file. Ask
App Store Connect:

```bash
source venv/bin/activate && python3 scripts/asc.py latest-build
```

It prints recent uploads and `NEXT_BUILD=<max+1>`. If `asc.py` is unavailable
(no venv or no `.env`, see "One-time setup"), ask the user for the last build
number shown in App Store Connect → TestFlight.

Compute the marketing version from the bump type, then:

```bash
[ "$(git rev-parse HEAD)" = "$PINNED_SHA" ] || echo "HEAD MOVED since pre-flight — stop"
python3 scripts/bump_version.py --build {NEXT_BUILD} [--marketing {X.Y}]
git add ConnectStats.xcodeproj/project.pbxproj
git commit -m "Bump version to {X.Y} (build {N}) for App Store release"
```

Commit **before** archiving so the archive corresponds to a real commit. If HEAD
moved, stop, show `git log --oneline $PINNED_SHA..HEAD`, and re-run the pre-flight.

**Xcode Cloud note:** if an Xcode Cloud workflow also archives ConnectStats, its
own build counter does not see local uploads. After a local upload, set Xcode
Cloud's "next build number" above `{N}` (App Store Connect → Xcode Cloud →
Settings → Build Number) or its next upload will be rejected as a duplicate.

## Step 4 — Clean and archive

```bash
xcodebuild clean -project ConnectStats.xcodeproj -scheme ConnectStats -configuration Release

ARCHIVE_PATH=~/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)/"ConnectStats $(date +%d-%m-%Y,\ %H.%M).xcarchive"
xcodebuild archive \
  -project ConnectStats.xcodeproj \
  -scheme ConnectStats \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  | tail -20
echo "$ARCHIVE_PATH"
```

Signing is automatic (team `M7QSSF3624`); `-allowProvisioningUpdates` lets Xcode
fetch profiles on a new Mac. The path under `Archives/` makes it show up in
Organizer. Timeout 600000 ms.

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
reviewer demo-account text is maintained in App Store Connect.

## Step 9 — Report

- Pre-flight checklist (with any WARNs the user accepted)
- Test result (count, duration)
- Archive path, version, build
- Tag created / moved, and whether commits and tag were pushed
- The approved release notes
- If staged: final `asc.py status`; remind them to press **Submit for Review**
- If not staged: Xcode → Window → Organizer → Distribute App → App Store Connect,
  then paste the notes in by hand
- Xcode Cloud build-number reminder if a workflow is active

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
