---
name: issues
description: Read and edit issues from the local issue mirror instead of calling the tracker CLI. Use whenever you need to list open issues, look up a specific issue, find next steps, or update an existing issue body (decisions, file paths, questions). Avoids token-expensive API calls. Fall back to the tracker CLI only when the folder is absent or the specific issue file is missing.
---

## Project config

Read optional per-project overrides from `.lz-playbook.json` at the repo root. Keys (defaults): `issueDir` (`.issues`), `issueSyncCmd` (`gh-issue-sync`), `issueTracker` (`github`), `rulesDir` (`.ai/rules`). If the file is absent, use the defaults. Below, `{issueDir}` / `{issueSyncCmd}` / `{issueTracker}` / `{rulesDir}` mean these resolved values.

# Issues Skill

**Tracker-neutral.** This skill operates through the configured sync CLI `{issueSyncCmd}` — `gh-issue-sync` when `{issueTracker}` is `github`, `tea-issue-sync` when it's `gitea` (both expose the same `pull`/`push`/`new`/`close`/`status`/`diff` interface). The `gh …` commands shown below are illustrative — use your tracker's equivalent (`tea …` for Gitea).

Issues are mirrored locally in `{issueDir}/` and synced before each session. Always read from — and write to — this folder rather than calling the tracker CLI's list/view/edit commands (e.g. `gh issue list`, `gh issue view`, `gh issue edit`). Issues are **living documents**: record decisions and answers in the issue **body** in place — the durable single source of truth. Comments are worth *reading* for context (maintainer replies, discussion) where the sync tool mirrors them locally; see [Read an issue's comments](#read-an-issues-comments-read-only).

## Folder layout

```
{issueDir}/
  open/     ← one .md file per open issue
  closed/   ← one .md file per closed issue
```

Each file is named `<number>-<slug>.md` and contains YAML frontmatter followed by the issue body:

```yaml
---
title: '[Alpha] Some Issue Title'
labels:
    - alpha-blocker
    - p0
state: open
synced_at: 2026-04-29T12:18:32Z
info:
    author: octocat
    created_at: 2026-04-28T10:43:47Z
    updated_at: 2026-04-28T11:20:08Z
---

## Summary
...
```

## How to use

### List all open issues
```bash
ls {issueDir}/open/
```
Each filename encodes the issue number and a slug — no need to open files to get the list.

### Read a specific issue
Find the file by number prefix, then read it:
```bash
ls {issueDir}/open/ | grep "^8-"          # find issue #8
# → 8-add-extension-filter-inside-collections-view.md
```
Then `Read {issueDir}/open/8-add-extension-filter-inside-collections-view.md`.

### Read an issue's comments (read-only)

When the sync tool mirrors comments, each issue has a sidecar `<number>-<slug>.comments.md` next to its file (one `## @author — timestamp` block per comment). Read it for maintainer replies and discussion the body doesn't capture:

```bash
ls {issueDir}/open/ | grep "^8-.*\.comments\.md$"   # → 8-<slug>.comments.md
```

- The sidecar is **read-only** — never edit it; it's overwritten on the next pull. Record durable decisions in the issue **body** instead (see [Edit an existing issue](#edit-an-existing-issue-decisions-answered-questions-new-file-paths)).
- Comment mirroring is tracker-dependent: `tea-issue-sync` writes these sidecars when its `.tea-issue-sync.json` has `output.comments: true`. Not every `{issueSyncCmd}` produces them — if there's no sidecar, the tool simply isn't mirroring comments.
- To *post* a comment, see the `create-issue` skill's `.comment.md` flow (singular) — but prefer a body edit for anything durable.

### Filter by label
Label filtering requires reading the frontmatter. For alpha-blockers specifically:
```bash
grep -l "alpha-blocker" {issueDir}/open/*.md
```

### Priority order for next steps
Sort by: alpha-blocker label first → p0 → p1 → p2 → issue number ascending.

### Edit an existing issue (decisions, answered questions, new file paths)

Issues are living documents — edit the local file in place, then push.

```bash
# 1. find the file
ls {issueDir}/open/ | grep "^209-"

# 2. Edit {issueDir}/open/209-<slug>.md directly. Append decisions to the bottom as
#    `**Edit N (YYYY-MM-DD):** <decision>`. Answer Questions inline as
#    `**Q:** ... → **A (YYYY-MM-DD):** ...`. Don't rewrite or delete earlier text.

# 3. push the updated body to the tracker
{issueSyncCmd} push
```

See `{rulesDir}/workflow-rules.md` § Issue body conventions for the complete pattern (Edit N numbering, Questions section, file-path placement).

## Rules

- **Never call the tracker CLI's list/view commands** (e.g. `gh issue list` / `gh issue view`) when `{issueDir}/open/` exists — use the local files.
- **Never call the tracker CLI's create/edit/comment commands** (e.g. `gh issue create` / `gh issue edit` / `gh issue comment`) — issue mutations go through `{issueSyncCmd} push` (the configured sync tool must support the `push` subcommand). (Reading-only tracker CLI calls are fine: `gh pr ...`, `gh repo ...`, `gh run ...`, `gh label list` etc.)
- **Fall back to the tracker CLI** only if the file for a specific issue is missing from `{issueDir}/`.
- **Editing `{issueDir}/open/<file>.md` is encouraged.** Issues are living documents — append decisions, answer questions, add file paths in place. Run `{issueSyncCmd} push` after any edit. Do NOT edit files under `{issueDir}/.sync/` (managed by the sync tool) or the read-only `*.comments.md` sidecars (overwritten on the next pull) — record decisions in the issue body instead.
- The `synced_at` timestamp shows when the file was last synced. If it looks stale (>24h before current date) and the issue is actively being worked, note it but still use the file.
- When listing next steps in the workflow protocol, read `{issueDir}/open/` instead of running the tracker CLI's list command (e.g. `gh issue list --state open --limit 20`).
