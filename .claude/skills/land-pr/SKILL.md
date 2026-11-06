---
name: land-pr
description: Land a PR the user has judged ready — check CI and every review-bot round, build and test the app locally (CI only builds ConnectStats), merge with rebase, finish remaining findings directly on master, tidy up, and end with a short landing summary. Invoke with the PR number. Never archives or releases.
disable-model-invocation: true
---

# Land PR

The user runs this once they have **decided** the PR lands. Everything still open — review
findings, follow-ups, polish — is finished with direct commits on `master` after the merge,
not another PR round. Adapted from flyfun-weather's `land-pr`.

`gh` must run with the sandbox disabled, otherwise it returns empty with exit 0. Run heavy
jobs (xcodebuild) one at a time.

**Only two things pause before the merge:**
1. App code that **doesn't build or whose tests fail** (Step 2).
2. Something that **can't be fixed after the merge**: a finding that would lose or corrupt
   users' activity databases, a security hole, or a close keyword that would wrongly close
   an outside reporter's issue.

When you pause, don't run `/process-review` yourself: report what you found, offer the
options (fix on the branch, land anyway and fix on master, send it back through
`/process-review`) with your recommendation, and let the user decide.

## Input

`<pr-number>` — required; if missing use the PR for the current branch, else ask and stop.

## Step 1 — Pre-merge checks

1. **State:** open, not draft (if draft, say so and offer `gh pr ready`), not conflicting:
   `gh pr view <n> --json state,isDraft,mergeStateStatus,headRefOid,body,commits,files`
2. **CI on the head commit:** `gh pr checks <n>`. Pending → wait (background poll, ~10 min
   max). A failing build of the PR's own code → pause.
3. **Review bot:** read **every** comment by `claude` whose first line contains
   "Code Review", not just the last. No review on the head commit → note it and carry on.
4. **Triage every open finding** into "fix on master", "propose an issue (needs design)" or
   "skip (why)". Pause only for the narrow cases above.
5. **Close keywords:** for each linked issue check the author
   (`gh issue view <N> --json author`). The user's own issues → `Closes #N` is fine. An
   **outside reporter's** issue must only be `Addresses #N` in the PR body and every commit
   body (`git log origin/master..<head> --format=%B | grep -inE "close[sd]?|fixe?s?|resolve[sd]?"`);
   a stray close keyword → pause.

## Step 2 — Local app verification (only if the PR touches app code or the project)

CI (`.github/workflows/main.yml`) only **builds** the ConnectStats scheme for the simulator.
It runs no tests and doesn't build FitFileExplorer.

1. Check the head out in a throwaway worktree (`git worktree add ../land-<n> <head-sha>`)
   and copy `ConnectStats/credentials.json` into it; never switch the main checkout.
2. Build every scheme the diff can affect (ConnectStats, FitFileExplorer, ConnectStatsTestApp)
   and run the tests of the affected ones on a concrete simulator / `platform=macOS`, signed
   (see CLAUDE.md "Build and test"). Read the counts from the `.xcresult` summary.
3. List the specific screens and states the user should look at in the simulator — only the
   ones this diff could affect.
4. A failing build or test → pause, with the error excerpt and which test.
5. Remove the throwaway worktree when done.

## Step 3 — Merge

`gh pr merge <n> --rebase --delete-branch` (fall back to `--merge` if the rebase doesn't
apply, and say so). Confirm linked issues closed, or deliberately didn't for `Addresses`.

## Step 4 — Finish it on master

- Work from a **clean** checkout of `master` synced to `origin/master`; if the main checkout
  has someone else's uncommitted changes, don't touch it — use a fresh worktree.
- Apply **all** "fix on master" findings. Anything that genuinely needs design is
  **proposed** as an issue (root cause, call sites, acceptance criteria) — never filed
  without the user's approval in this session.
- Build and test what you touched before pushing.
- One commit, `Follow-up to #<pr>: …`, specific paths only, attribution trailer. Push.

## Step 5 — Bookkeeping

- **Memory:** grep the memory dir for the PR/issue numbers; update notes that still call
  this work pending, or delete them if now only history.
- **Design docs:** if the PR or your follow-up changed documented behaviour and `designs/`
  wasn't updated, update the affected doc in the follow-up commit (`/sync-designs <doc>`,
  scoped — never a full sync).
- Remove the PR's local worktree if it's clean and merged; leave a dirty one and say so.

## Step 6 — Landing summary (≤ ~12 lines)

```
## Landed #<pr> — <title>   (closes #N)

**What it does:** <one line, user terms>
**For the user:** <visible change, or "nothing visible">
**Fixed on master after merge:** <sha — what; or "none">
**Verified:** CI <green on sha> · local <schemes built, tests N passed | no app change>
**Your simulator check:** <specific screens/states, or "none needed">
**Release:** <worth an /archive? what's user-facing for the What's New notes — or "nothing to ship">
**Left open / proposed issues (not filed):** <items, or "none">
```

Never archive, tag or upload — `/archive` is the user's separate step.
