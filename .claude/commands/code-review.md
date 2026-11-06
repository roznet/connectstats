Review target: $ARGUMENTS

If $ARGUMENTS is a GitHub PR URL or repo/pull/number:

- Use gh to fetch the PR diff and description
- Focus review on changed lines only
- Post the review as a PR comment using gh pr comment

Otherwise:

- Interpret $ARGUMENTS as a description of what to review
- Use git log, git diff, or file reads as appropriate to find the relevant changes

---

## Non-negotiable: post before you finish

This command usually runs headless in CI (`.github/workflows/claude-code-review.yml`),
where there is no follow-up turn. **A review that is not posted did not happen.** So:

- Never end your turn with review work outstanding. "I'll compile the findings once the
  agents report back" is a failed run — the session ends there and the subagents are killed.
- If you delegate to subagents, pass `run_in_background: false` so you block on their
  reports and can synthesise them in the same turn. Never fan out into background agents.
- Large diffs are not a reason to defer. Shard the work yourself: `git diff` a subset of
  paths at a time, use `/tmp` for scratch files, and keep the findings in your own context.
  `project.pbxproj` diffs are large and mostly mechanical: check what they add or remove
  (targets, packages, build settings, file memberships), not every line.
- Your final action is `gh pr comment` (or, for a non-PR target, printing the review).
  Do that before you say anything terminal.

The CI runner is Ubuntu: there is no Xcode, so you cannot build or run tests. Review by
reading.

---

## Context loading

Before starting the review, read:

- `CLAUDE.md` at the repo root for coding standards and the ARC/MRC rules
- `designs/INDEX.md`, then the design docs relevant to the files being changed — use these
  for module intent and architecture

---

## Single-pass completeness requirement

**Do one complete pass. Find every issue. Report them all.**

Do not hold issues back for a follow-up round. If there are 10 real issues, report all 10
now. The goal is one complete review that can be acted on in one go, not an iterative
dialogue.

Group output by severity:

- **Critical** - bugs, logic errors, data corruption, security issues: must fix before merge
- **Important** - architecture violations, design deviations, correctness problems: should fix
- **Minor** - best practices, missed optimisations, low-effort improvements: fix if low effort

Within each group, order by file/module for readability.

---

## Output format (machine-read — do not restyle)

`/process-review` watches for this comment by matching on its first line, so the
comment shape is a contract, not a stylistic choice. Emit exactly this skeleton
and do not substitute bold, plain text, or a different heading level for the
headings below:

```markdown
## Code Review

<one- or two-sentence summary of what was reviewed>

### Critical
- `path/to/File.m:123` — <finding>

### Important
- `path/to/File.swift:45` — <finding>

### Minor
- `path/to/File.h:67` — <finding>
```

Rules:

- The **first line is always exactly `## Code Review`** — including for a clean
  review, which follows it with a brief approval line and no severity sections.
- Severity headings are `### Critical` / `### Important` / `### Minor`.
- **Omit a severity section entirely when it has no findings** — do not emit an
  empty heading or a "none" placeholder.
- Findings are list items; lead each with the file path (and line where known).

---

## Review criteria

Apply all of the following in the single pass:

**General**
- Bugs and logic errors
- CLAUDE.md violations
- Deviations from documented architecture/design intent in `designs/`
- Code and logic duplication, opportunities for consolidation (check RZUtils / RZExternal
  before accepting a new helper)
- Simplicity, maintainability and extensibility

**Objective-C memory management (highest risk in this repo)**
The ConnectStats, HealthStats and ConnectStatsTestApp targets compile Objective-C **without
ARC** (manual retain/release), with per-file `-fobjc-arc` / `-fno-objc-arc` overrides in the
project, and the same `.m` file can be MRC in one target and ARC in another. FitFileExplorer
and the Swift code are ARC. For every changed `.m`:
- Is it MRC in at least one target? (Check its `COMPILER_FLAGS` in `project.pbxproj` and the
  target's `CLANG_ENABLE_OBJC_ARC`.) If so, `alloc`/`new`/`copy` results stored in
  autoreleased context or `retain` properties must be balanced — use the `RZReturnAutorelease`
  / `RZAutorelease` / `RZRelease` macros (they compile correctly under both modes); `dealloc`
  must release new retained properties.
- Raw `autorelease` / `release` / `retain` calls in a file that is ARC in any target are
  compile errors there — flag them.
- Blocks capturing `self` in long-lived handlers (web notification handlers, timers,
  NSNotificationCenter observers): retain cycles; observers removed.

**Swift**
- Concurrency: `@MainActor` for UI work, `Task {}` captures, Sendable across async boundaries
- Retain cycles in escaping closures; `weak self` where the closure outlives the owner
- `@objc` exposure stays compatible with the Objective-C headers that use it
  (`ConnectStats-Swift.h`)

**Persistence (FMDB / SQLite)** — see `designs/database-schema.md`
- Schema changes must come with a migration for existing databases (users have years of
  activities); never assume a fresh database
- SQL built with string formatting instead of bound parameters
- Writes on the right queue / worker; transactions for batch writes

**Activity types and service import** — see `designs/activity-types.md`,
`designs/service-integrations.md`
- Garmin/Strava type strings change over time (e.g. `RESORT_SKIING_SNOWBOARDING_WS` became
  `RESORT_SKIING`). A mapping that returns nil silently drops the activity on import — mapping
  changes must keep the old names and new names
- Multi-service duplicate handling must stay order-independent
- Parsing of server/Garmin JSON must tolerate missing or extra fields without crashing

**Release and project hygiene**
- Absolute local package paths (`/Users/...`) in `project.pbxproj`
- Version numbers (`MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`) changed outside an
  `/archive` run
- Secrets: `credentials.json`, `.env`, `*.p8` must never be committed; new keys go in
  `credentials.sample.json` / `.env.sample` with placeholder values
- New Info.plist usage descriptions / entitlements match what the code actually requests

---

## Operational & consistency

Apply to every PR, briefly:

- **Silent failure paths.** A failure that is logged and skipped, an activity dropped on
  import, a request error swallowed. Prefer loud, distinguishable failures (`RZLog` with
  enough context to find it in a bug report).
- **Same value, other surfaces.** If the PR changes how a field or unit is computed or
  displayed, check the other places showing it (list cells, detail view, graphs, stats,
  FitFileExplorer).
- **Comments and docs that assert facts.** New or touched comments and design-doc lines must
  match the code.

---

## Do NOT flag

- Style issues not covered by CLAUDE.md
- Nits or minor suggestions below the Minor threshold
- Pre-existing issues not touched by this PR

If no issues found, post a brief approval comment — still under the `## Code
Review` first line required by the output-format contract above.
