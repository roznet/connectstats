---
description: Watch a PR for the code-review bot's comment, then triage and act on it (fix blockers & push, or recommend merge + fix-on-master)
argument-hint: "[PR number] (default: PR for current branch)"
allowed-tools: Bash(gh:*), Bash(git:*), Bash(xcodebuild:*), Bash(xcrun:*), Read, Edit, Write, Grep, Glob
---

# Process bot review

Watch the target PR for the code-review bot's review, then triage and act on it.

This command is the **only** entry point that watches a PR or acts on its review and CI
events. Running it is the user's explicit opt-in to the review loop.

## Target PR

- If `$ARGUMENTS` is a number, that is the PR.
- Otherwise resolve the PR for the current branch:
  `gh pr view --json number,headRefName,headRefOid,url`
- If there is no PR for the current branch, stop and say so.

`gh` must run with the sandbox disabled, otherwise it returns empty with exit 0.

## The review bot

The reviewer is the GitHub user **`claude`**, driven by `.github/workflows/claude-code-review.yml`,
which **fires automatically on every push** to the PR. It posts a single **top-level PR
comment** (not inline threads) whose **first line is `## Code Review`**, grouping findings
under `### Critical` / `### Important` / `### Minor`. A clean review posts a brief approval
comment with no findings. The shape is pinned in `.claude/commands/code-review.md` ("Output
format"), but **match on the first line *containing* "Code Review"**, not on the exact `##`
decoration, so a drift degrades into a cosmetic mismatch rather than a watch that never fires.

Because it is a top-level comment, it is **not** a GitHub "Review": `gh pr view --json reviews`
and the inline `pulls/<n>/comments` endpoint are always empty for this bot. The login is
`claude` via `gh pr view --json comments` but `claude[bot]` via REST `issues/<n>/comments`.

**Cost model — every push = one full review round.** Two rules follow:
1. **Only push when there's a real blocker to fix.** If the findings are cosmetic-only, do
   *not* push — merge and fix on master.
2. **If you're pushing anyway, batch in everything worth doing**, cosmetic fixes included.

Never manually re-trigger the bot; pushing is what triggers it.

## Step 0 — Can the review run at all? (before waiting)

GitHub creates no `pull_request` run while the PR has a merge conflict, so waiting would
wait for nothing. Check first:
`gh pr view <num> --json mergeable,mergeStateStatus`

- `CONFLICTING` / `DIRTY` → **do not watch.** Name the conflicting files
  (`git fetch origin master && git merge-tree --write-tree --name-only origin/master HEAD`),
  say the review cannot run until the conflict is resolved, and offer a rebase (wait for the
  go-ahead).
- `UNKNOWN` → GitHub computes mergeability lazily; query again after ~30 s.
- `MERGEABLE` → go on to Step 1.

If a few minutes into Step 1 there is still no workflow run for the head commit
(`gh run list --branch <head>`), re-check mergeability before waiting longer. If the run
failed immediately, check the `CLAUDE_CODE_OAUTH_TOKEN` secret exists (`gh secret list`).

## Step 1 — Wait for the review

"Ready" = a comment by `claude` whose first line contains "Code Review", created **after the
latest commit on the PR branch**.

Reference time: `gh pr view <num> --json commits --jq '.commits[-1].committedDate'`

Poll about every 60 s with a background Bash loop (never a foreground `sleep`) that exits 0
once the comment is found, or with ScheduleWakeup. Query (`gh --jq` does not accept `--arg`,
so pipe to `jq`):
```
gh pr view <num> --json comments | jq -r --arg t "<head-date>" \
  '[.comments[] | select(.author.login=="claude" and .createdAt > $t
    and ((.body | split("\n")[0]) | test("Code Review"; "i")))] | last | (.body // "NO_REVIEW_YET")'
```
Give up after ~20 min and report that no review appeared, saying whether it was a conflict
or no run for the head commit.

## Step 2 — Check for master divergence (before fixing)

`git fetch origin master && git rev-list --left-right --count origin/master...HEAD`. If
master has moved ahead, warn and **offer** to rebase the PR branch first. Do not auto-rebase.

## Step 3 — Triage

Classify every finding. **Be strict about what counts as a blocker**: only
correctness/logic/security/data-loss issues and clear design-intent violations block a merge.

- **Blocker** — bug, memory-management error (MRC leak/over-release, retain cycle), crash,
  data corruption or a migration gap, broken behaviour, real design-doc violation. Anything
  under **Critical**, and **Important** findings that are genuinely about correctness.
- **Cosmetic / non-blocking** — naming, comments, style, "consider…" suggestions. Most
  **Minor** findings.
- **Unsure** — can't tell whether it changes behaviour.

Post a short triage summary first: one line per finding with bucket + reasoning.

## Step 4 — Act

**Blockers → fix and push to the PR branch.**
- Make the fixes. Reuse existing helpers; check sibling code if the bot flagged a pattern
  that repeats.
- Sanity-check before pushing: build the affected scheme(s) and run the relevant tests on a
  concrete simulator (see CLAUDE.md "Build and test"), and re-read the finding to confirm
  the fix addresses it.
- Stage **specific paths** (never `git add -A`). Commit referencing the finding, ending with
  the standard `Co-Authored-By` trailer. Push.
- Post a reply comment on the PR summarising what was fixed and what was deferred.

**Cosmetic only → recommend merge + fix-on-master.** Don't push. Recommend merging
(`--rebase`), list the deferred items concretely, and offer to apply them as a direct commit
on master after merge or to draft a tracking issue.

**Unsure → ask.** Present the finding: fix on the PR, or merge and fix on master?

**Mixed** → you're pushing for the blockers anyway, so batch in every cosmetic fix worth doing.

**Clean review** → confirm CI is green (`gh pr checks <num>`), then say it's ready and
recommend merge (`--rebase`). Don't auto-merge.

## Guardrails

- **Never merge automatically** — merging is the user's call (or `/land-pr`).
- After pushing fixes the bot posts a fresh round on its own. Loop back to Step 1, but
  **cap it at 2 rounds**, then summarise what remains and hand back.
- Keep narration concise: what the bot found, the triage, what was pushed, what was deferred.
