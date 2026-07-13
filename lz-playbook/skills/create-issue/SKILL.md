---
name: create-issue
description: Scaffold one or more new issues in the local issue mirror using the project's canonical frontmatter, label vocabulary, and body sections, then sync them with the configured issue-sync tool. Use this whenever the user asks to create, file, or open issues — single or batch.
---

## Project config

Read optional per-project overrides from `.lz-playbook.json` at the repo root. Keys (defaults): `issueDir` (`.issues`), `issueSyncCmd` (`gh-issue-sync`), `issueTracker` (`github`), `rulesDir` (`.ai/rules`). If the file is absent, use the defaults. Below, `{issueDir}` / `{issueSyncCmd}` / `{issueTracker}` / `{rulesDir}` mean these resolved values.

# Create-Issue Skill

This is the **writing** counterpart to the `gh-issue` skill. `gh-issue` reads from `{issueDir}/`; `create-issue` writes to it.

## When to use

- The user asks to create / file / open one or more issues.
- The user dumps a bullet list of features, bugs, or ideas and asks them turned into issues.

Do **not** use this skill to:

- Comment on or close existing issues — use `{issueSyncCmd} close` / `.comment.md` files directly.
- Edit an already-synced issue file in place — modify the file and run `{issueSyncCmd} push`.
- Re-file something that already exists — see [Step 2](#step-2--check-for-duplicates) and prefer commenting on the existing issue.

## Inputs

The skill accepts **batch input** (a list of bullets). A single-issue request is just one bullet.

For each bullet, work out:

| Field | Source |
|-------|--------|
| **Title** | Derived from the bullet — must start with a phase prefix in square brackets: `[Alpha]`, `[Beta]`, `[Feature]`, `[Tooling]`, `[Docs]`, `[Docs/UI]`, etc. Use the same convention seen in existing files in `{issueDir}/open/` and `{issueDir}/closed/`. |
| **Phase** | The user usually states it (alpha / alpha-blocker / beta / future). When unstated, infer from the bullet's wording and confirm before creating. |
| **Labels** | Always include phase-driven labels (`alpha-blocker` and/or `alpha`, or `feature` for beta items). Add scope labels: `import`, `metadata`, `ui`, `type:ui`, `type:file-support`, `type:infra`, `bug`, `documentation`, `source-tracking`, `search`, `core`, `distribution`, etc. Always include exactly one priority: `p0`–`p5`. |
| **Body** | Use the canonical section structure (see [Step 4](#step-4--scaffold-the-file)). |

## Workflow

### Step 1 — Validate labels against the source of truth

The only legal labels are those in `{issueDir}/.sync/labels.json`. Read that file at the start of the run and reject any requested label that is not in the list. **Do not invent new labels.** If a label seems missing, surface it to the user and ask whether to add it (separate change to the label set, out of scope of this skill).

```bash
# Read once at the start of a batch:
cat {issueDir}/.sync/labels.json
```

Priority defaults if the user does not specify:

| Phase | Default priority |
|-------|------------------|
| `alpha-blocker` | `p1` (use `p0` only if it's an outright blocker on shipping alpha) |
| `alpha` | `p2` |
| beta / `feature` | `p3` |
| backlog / future | `p4` |

### Step 2 — Check for duplicates

Before scaffolding any new file, scan `{issueDir}/open/` and `{issueDir}/closed/` for similar titles. Cheap heuristic:

```bash
ls {issueDir}/open/ {issueDir}/closed/ | grep -iE "<two or three keywords from the title>"
```

For each potential duplicate, **read the file** and decide:

- **Same problem, still open** → do not create a new issue. Offer to add a comment via a `.comment.md` file next to the existing issue, or to update the existing body.
- **Same problem, closed** → it's a follow-up. Create a new issue and explicitly link to the closed one in the **Related** section, with `(closed; this is the concrete follow-up)` annotation.
- **Different problem, similar wording** → proceed and add a `Related` cross-link.

Always surface duplicates to the user before silently creating something new.

### Step 3 — Push back on under-specified requests

Per `{rulesDir}/workflow-rules.md`, "mark open questions as TBD rather than silently deciding." If a bullet is too vague to scope (no clear acceptance criteria, no obvious user-visible outcome), pause and clarify with the user instead of inventing scope. Examples that need clarification:

- "Make tagging better" — what specifically is wrong?
- "Improve the UI" — which screen, what behavior?
- "Fix the import" — which step, which symptom?

### Step 4 — Scaffold the file

File path: `{issueDir}/open/T<random-hex>-<phase>-<kebab-slug>.md` — `{issueSyncCmd}` requires the `T` prefix on new local files; it renames them to the real number on push. (The configured sync tool must support the `new`/`push` flow used here.)

Frontmatter — multi-line YAML lists (this is the convention in existing project files; **do not** use the inline `[a, b]` form):

```yaml
---
title: '[Phase] Concise title (under 80 chars when possible)'
labels:
    - alpha          # or feature, etc.
    - alpha-blocker  # only if blocking alpha
    - p1             # exactly one p0–p5
    - import         # scope labels
    - metadata
state: open
---
```

Do **not** add `synced_at` or the `info:` block — `{issueSyncCmd}` populates those on push.

Body — use these sections in this order; omit any section that genuinely doesn't apply, but keep the order stable:

```markdown
## Summary

One paragraph: what this issue is, plus a one-line link to any related closed/open issue if this is a follow-up.

## Problem / Motivation

Why it matters now. Concrete real-world symptoms preferred over abstract gripes.

## User Story

As a <role>, I want <capability>, so that <outcome>.

## Current Behavior

(Bug-style issues only.) What happens today, with a concrete example if helpful.

## Expected Behavior

What should happen instead.

## Scope

### In Scope
- Bullet list.

### Out of Scope
- Bullet list — explicit non-goals matter as much as goals.

## Acceptance Criteria

- [ ] Checkbox list. Each item is testable / observable.
- [ ] Include test coverage requirement when logic changes (per project workflow rules).

## Suggested Implementation Notes

**Entry points (mandatory when known).** Resolve the exact files, functions, and line numbers the implementer will touch — don't make them re-discover. Do this *before* writing the issue: run `grep -n "<symbol>" <path>` and paste the result. The implementer (human or agent) saves real time/tokens on every read.

```markdown
- `src/services/source_inference.*::infer_source` (around L<n>) — extend the heuristic table.
- `src/components/<Feature>.*` (search for the type-switch block) — add the new branch.
- `src/data/<registry>.json` — add the new entry; run the project's sync/codegen step if it has one.
```

**Constraints to respect** — call out any from the consuming project's `CLAUDE.md` / `AGENTS.md` that apply (fixed API/param contracts, required wrappers or init calls, forbidden imports, single-source-of-truth files that must be regenerated, banned dependencies, etc.).

## Questions

(Include this section only when there are genuine open questions at issue-creation time. Format each as `**Q:** <question>`. When answered later, edit the question in place to `**Q:** <question> → **A (YYYY-MM-DD):** <answer>` — do NOT delete the question, the trail matters. See `{rulesDir}/workflow-rules.md` § Issue body conventions.)

## Related

- [#NN — Title](<issue-tracker-url>/NN) (open / closed; one-line annotation on relevance)
- CLAUDE.md / rules references when relevant.
```

Cross-link to issues using the project's `{issueTracker}` URL form (e.g. `https://github.com/<org>/<repo>/issues/<N>` for GitHub, or the equivalent Gitea URL) so links work both locally and on the tracker's web UI.

### Step 5 — Push

After all files in the batch are written, run:

```bash
{issueSyncCmd} push --dry-run    # preview
{issueSyncCmd} push              # for real
```

(The configured sync tool must support the `push` subcommand.) Report each created issue's number and URL back to the user.

### Step 6 — After creation: issues are living documents

Once an issue exists, **edit the body in place** rather than commenting when:

- A decision is made later → append `**Edit N (YYYY-MM-DD):** <decision>` at the bottom (sequential numbering; don't rewrite earlier text).
- An open question is answered → edit the `## Questions` entry in place: `**Q:** ... → **A (YYYY-MM-DD):** ...` (don't delete the question).
- New entry points or file paths are discovered → update the **Suggested Implementation Notes** section directly.

After any edit to a file under `{issueDir}/open/`, run `{issueSyncCmd} push` to propagate the change to the tracker.

Full pattern documented in `{rulesDir}/workflow-rules.md` § Issue body conventions.

## Hard rules

- **Never invent a label** — only use labels in `{issueDir}/.sync/labels.json`.
- **Never silently create a duplicate** — surface possible duplicates to the user first.
- **Never create issues for requests labeled TBD / open question** — clarify first.
- **Never edit `{issueDir}/.sync/`** — that folder is managed by `{issueSyncCmd}`. (Editing `{issueDir}/open/<file>.md` IS allowed and encouraged — see Step 6.)
- **Never bypass `{issueSyncCmd}`** — do not call the tracker CLI's create/edit/comment commands directly (e.g. `gh issue create`/`gh issue edit`/`gh issue comment`). Reading-only tracker CLI calls (e.g. `gh pr ...`, `gh repo ...`, `gh run ...`, `gh label list`) are unaffected.

## Examples

### Single-issue input

> "Create an issue for adding keyboard shortcut help. Alpha. p3."

→ One bullet, one file, one push. Title `[Alpha] Keyboard shortcut help dialog`, labels `[alpha, p3, type:ui]`.

### Batch input

> "Create issues for these alpha-blockers:
> - improve tagging system: too noisy …
> - add NSFW flag …
> - improve auto-source for HumbleBundle …"

→ Three bullets, three files, one push at the end. For each bullet, run Steps 1–4 in turn; only call `{issueSyncCmd} push` once after all files are written.

### Batch with a duplicate

> "Create issues for: improve auto-collections; add 9-slice preview; …"

→ Spot the existing `#53 — Improve Auto Collections Grouping` open issue, surface it to the user, and ask whether the request is the same bug or a different one. Do not auto-create a duplicate.

## Related

- `gh-issue` skill — reading side.
- `{issueSyncCmd}` — the configured issue-sync tool (gh-issue-sync-compatible interface: pull/push/new/close/status/diff).
- `{rulesDir}/workflow-rules.md` — clarifies-before-deciding rule.
- `CLAUDE.md` — project context, constraints, and SSOT rules referenced in **Suggested Implementation Notes**.
