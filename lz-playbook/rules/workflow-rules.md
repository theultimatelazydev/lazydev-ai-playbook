# Workflow Rules

**Applies to:** All AI agents working in this repository (Cursor, Claude Code, Codex, Copilot, or any other assistant), unless the user explicitly opts out for a single message.

> **Config-aware.** Paths and commands below use the `.lz-playbook.json` placeholders `{issueDir}` (default `.issues`), `{issueSyncCmd}` (default `gh-issue-sync`), `{issueTracker}` (default `github`), `{handoffDir}` (default `.ai/handoffs`), `{rulesDir}` (default `.ai/rules`), `{baseBranch}` (default `main`), and `{partialMarker}` (default `label`). Where a tracker CLI is shown, use the one that matches `{issueTracker}` (`gh` for GitHub, `tea` for Gitea, etc.).

---

## Config resolution (fail loud, not silent)

Resolve every path and branch from config — never hardcode a literal that bypasses a placeholder. If `.lz-playbook.json` is **absent**, the documented defaults apply (a zero-config project keeps working). If it is **present but missing a key a step needs**, stop and ask the user rather than assuming a default — a project that customised one value and omitted another is exactly the case a silent default corrupts. A silent default is how this whole class of bug survives: the project keeps working by coincidence until the coincidence ends.

---

## Session Startup (mandatory before any code change)

Run these two steps at the start of every session — before creating a branch or editing any file:

1. **Read the latest handoff:**
   ```bash
   ls -t {handoffDir}/ | head -1   # find the most recent file
   ```
   Then read it. It contains insertion points, decisions already made, and the exact next step.

2. **Get the issue list:**
   ```bash
   ls {issueDir}/open/
   ```
   Issues are mirrored locally in `{issueDir}/open/` (synced before sessions). Read individual files for full context: `Read {issueDir}/open/<N>-<slug>.md`. Filter by a label with `grep -l "<label>" {issueDir}/open/*.md`. Only fall back to the tracker's list command (e.g. `gh issue list --state open`) if `{issueDir}/open/` is absent.

   See the `issues` skill for the full usage guide.

---

## Context Efficiency (always apply)

**Grep before you read.** Always find the line number first, then read only the relevant slice (`offset` + `limit`). Never read a whole file when a targeted slice will do.

```bash
# Find a symbol, then read ±20 lines around it
grep -rn "my_function" src/
# → note the line, then Read with offset/limit around it
```

This applies to exploration, finding insertion points, and verifying after edits.

---

## Dispatch & Verification (when coordinating sub-agents)

These rules apply to a coordinator agent that fans work out to sub-agents (e.g. parallel worktree-isolated agents). They reduce token waste and the temptation to double-do work.

- **Know whether CI covers the checks.** If the project has CI that runs the build/typecheck + tests on every PR, trust it and don't re-run those locally unless CI is red, the change is high-risk (data/schema migrations, security- or safety-critical code), or you suspect CI doesn't cover it. If CI is **absent or disabled**, verify locally before opening the PR.
- **Pre-resolve entry points before dispatch.** Before briefing a sub-agent, run `grep -rn "<symbol>"` on the target file(s) and put the file + line number in the brief. Sub-agents that get exact anchors finish in roughly half the tokens of sub-agents told only "look in the importer module".
- **Stalled sub-agent → discard, don't resume.** If a background sub-agent stalls (permission prompt it can't answer, sandbox denial, infinite loop), relaunch a fresh one rather than trying to inherit its partial state. Worktree isolation often blocks the rescue agent from reading the dead one's files anyway, so the resume rarely saves what it costs.
- **Map conflicts before fanning out.** When dispatching N sub-agents in parallel, list the files each will touch and flag overlaps. Additive edits to the same file are fine (different functions, different branches); edits to the same lines force a serial rebase and may waste one of the agents' work.

---

## Branch & PR Requirement (mandatory for every task)

Every task — feature, fix, doc change, **or handoff** — must be developed on a **dedicated branch off `{baseBranch}`** in a **dedicated worktree** (never the shared primary checkout) and delivered via a **pull request into `{baseBranch}`**. Direct commits to `{baseBranch}` are not allowed. See **`git-safety-rules.md` § Branching model** for the full model, including the optional stable/integration (`main`/`dev`) split and the hotfix exception.

> **Handoffs follow this too.** Generating an end-of-session handoff (`{handoffDir}/handoff-YYYY-MM-DD.md`) is a change like any other: do it on a new branch off `{baseBranch}` in a dedicated worktree and ship it as a PR — never leave it uncommitted in the working copy or edit the shared primary checkout directly. See the `handoff` skill.

### Branch naming

Use the pattern: `<type>/<issue-number>-<short-slug>`

Examples:
- `feat/38-unit-tests`
- `fix/19-missing-files`
- `chore/37-ci-pipeline`

If there is no issue, create one before starting (or use `chore/no-issue-<slug>`).

### Before starting work

1. Confirm the target issue number.
2. Create and switch to the branch **off `{baseBranch}`** in a **dedicated worktree**: `git checkout -b feat/N-slug origin/{baseBranch}`
3. Do not start editing files on `{baseBranch}` directly.

### On completion

1. Stage and commit all changes on the feature branch.
2. Push the branch to origin.
3. **Open a PR into `{baseBranch}` automatically** with the tracker's PR command (`gh pr create --base {baseBranch}`, `tea pr create --base {baseBranch}`, etc.) — do not wait for user approval to create the PR.
4. The maintainer reviews the PR and merges (or requests changes).

> Agents perform all git operations on feature branches autonomously. The agent **must never** touch `{baseBranch}` directly. See `git-safety-rules.md`.

---

## Pull Request Requirements (mandatory)

### Body structure

The PR body **must** start with a `## Summary` heading. The very first line **inside** that section is a **bare** closing keyword — no Markdown link wrapping:

```markdown
## Summary

Closes #N

<one-paragraph or bulleted summary of what the PR does>

## Decisions

…

## Test plan

…

## Deleted files

<list with reasons, or "None.">
```

Rules:
- The keyword must be **bare** — `Closes #N` (or `Fixes`/`Resolves`) on its own line, NOT wrapped in `[Closes #N](url)` markdown-link form. Both GitHub and Gitea auto-render `#N` as a clickable link *and* fire the auto-close parser on a bare keyword; the markdown-link form has been observed to break auto-close, forcing manual closes.
- The `Closes` line is the **first line inside `## Summary`**, separated from the rest of Summary by a blank line. It is **not** above the heading, and **not** at the bottom of the body.
- Use whichever keyword fits (`Closes`, `Fixes`, `Resolves`). Multiple issues → one keyword per line, stacked at the top of Summary (`Closes #A`, newline, `Closes #B`).
- The commit message body still ends with plain `Closes #N` (same bare form).
- If you want a clickable link **elsewhere** in the body (e.g. a Related section), use the markdown-linked form there. Only the top-of-Summary closing-keyword line must be bare.

> **Auto-close caveat:** the closing keyword only fires when the PR merges into the tracker's **default branch**. If `{baseBranch}` is an integration branch (e.g. `dev`) that is *not* the default, merges there will **not** auto-close the issue — close it manually or make the integration branch the default. See `git-safety-rules.md`.

### Required sections

Every PR body must include:

1. **Summary** (with the bare `Closes #N` keyword line as described above) — what changed and why.
2. **Decisions** — any significant architectural or product choices taken during implementation.
3. **Test plan** — tests added/changed, plus manual test steps for UI-only changes.
4. **Deleted files** — list them with reasons, or write `None.`.
5. **Acceptance criteria** — when the PR implements an issue, list that issue's acceptance criteria, each marked **met** or **unmet**. See **Marking unmet acceptance criteria** below.

Anything else the reviewer needs (edge cases, follow-up items, related issues) goes in additional sections after these.

### Marking unmet acceptance criteria

A feature shipped in installments looks complete from each PR's title while being permanently incomplete. So **when any acceptance criterion is unmet, that must be visible while scanning a list of PRs — not only inside the body.** The marker is configurable via `{partialMarker}` (default `label`); the choice must **never** be a title *prefix*:

1. **A PR label — `partial`** (`{partialMarker}: label`, the default where the host supports labels). Renders in the list view, survives a rename, touches neither title nor commit history. Set it when any criterion is unmet; remove it when all are met.
2. **A title *suffix* — `feat(scope): add the thing [partial]`** (`{partialMarker}: suffix`). Use where labels are unavailable or inconvenient. Visible in the list, harmless at the end of a title.
3. **A body checklist alone** (`{partialMarker}: checklist`) — the fallback, and **explicitly insufficient on its own**: it is what the projects already did, and what failed. Only choose it when the host has neither labels nor editable titles.

- **Never a title *prefix*.** Where a project squash-merges, the PR title becomes the permanent commit message — so `partial: feat(scope): …` is not a parseable conventional commit: it breaks changelog generation and stays wrong in history forever. A suffix or label gives the same visibility at no cost to anyone.
- **"Verified by unit tests" does not mark a user-facing criterion met.** If a criterion describes something a person does, it is met when a person — or a test driving the real interface — has done it.
- **A criterion is verified in the environment where it can fail.** Where behaviour depends on platform, filesystem, hardware, or configuration, a pass in the convenient environment proves nothing about the one the bug lives in. "Verified" without naming the environment is not verification.

---

## Testing Requirement (mandatory for every feature or fix)

Every PR that adds or changes logic must include tests:

- **Changed feature** → update the existing tests to cover the new behaviour.
- **New feature** → add tests for it in the same PR (no new feature ships without tests).
- **Backend / domain logic** → a unit test co-located per the project's test convention; use in-memory fixtures for data-backed functions where possible.
- **New pure functions** → at minimum one happy-path and one edge-case test.
- **UI-only changes** (layout, styles, copy) → manual test is acceptable; note it in the PR body.

No new logic feature may be merged without at least one test covering its primary path.

---

## Task Tracking

**Source of truth:** the project's issue tracker (`{issueTracker}`), mirrored locally to `{issueDir}/open/`.

- All open work, bugs, and backlog items live in the tracker, mirrored locally to `{issueDir}/open/`.
- When listing next steps, read `{issueDir}/open/` (see `issues` skill). Fall back to the tracker's list command only if the folder is absent.
- Order by milestone → priority (highest first, using the project's own priority vocabulary) → issue number ascending. Render any listing per **Work listing format** below.

### Scope belongs to the maintainer

Scope is not the agent's to reduce. Writing a requirement into an issue's `## Out of Scope` is a scope reduction wearing a planning costume, and filling in a template section does not feel like breaking a rule — which is exactly why it must be a rule. An agent may record a non-goal **only** when it can point at one of:

1. **A different feature, named** — ideally with the issue that owns it.
2. **A decided constraint, with its decision referenced** — a design record, a prior ruling, an issue. (These lines are valuable: they stop the next agent relitigating something settled. The rule must not squeeze them out.)
3. **An exclusion the maintainer stated** — in the request, or in a plan/epic that already named the legitimate cut. If a plan named the cut, that is the cut; there is not a second one.

Anything else is **not an exclusion, it is a question**: it goes in `## Questions` and is raised in conversation *before* the issue is filed. An agent that believes something should be deferred says so and waits — it does not write the deferral into the issue and proceed. See the `create-issue` skill for the body template that enforces this.

### Issue body conventions

Issues are **living documents**. Record decisions in the issue **body** — the durable single source of truth — not in comments. (Comments are fine to *read* for context; some sync tools mirror them locally as read-only `.comments.md` sidecars — see the `issues` skill.)

- **At creation, include file paths the implementer will touch.** Spending tokens at creation saves repeated lookups during implementation, e.g. `Files: src/components/Foo`, `Insertion: after the Bar block in src/lib/baz:120`. The `create-issue` skill's **Suggested Implementation Notes** section is where these go; resolve them once at issue-author time so every later reader (human or agent) doesn't re-discover.
- **Decisions made later** are appended as `**Edit N (YYYY-MM-DD):** <decision>` at the bottom of the body. Use sequential numbers. Don't rewrite earlier text — the trail of decisions matters when an approach gets reconsidered.
- **Open questions** live under a `## Questions` section in the body. When answered, edit the question inline: `**Q:** ... → **A (YYYY-MM-DD):** ...`. Don't delete the question.
- After any edit, run `{issueSyncCmd} push` to sync back to the tracker.

### Read-only tracker commands are still fine

Read-only tracker calls (`gh pr ...` / `tea pr ...`, `... repo view`, `... label list`, run/status queries) are unaffected — only **issue mutations** go through `{issueSyncCmd}`. PR creation/merging continues to use the tracker's normal PR flow.

---

## Work listing format

**Whenever any skill lists work** — open issues, a wave, a plan, a backlog, a session summary, a set of findings — render a **table**, one row per item, not a bare number or a prose sentence. A bare issue number tells the reader nothing about what it is:

| # | Title | Category | Weight | P | Status |
|---|---|---|---|---|---|

- **#** — issue or PR number, linked where the host supports it.
- **Title** — the item's **real** title, verbatim. A re-summarised title makes the list unsearchable against the tracker.
- **Category** — where the project records one (label, type, area).
- **Weight** — S / M / L, where the project has a size vocabulary.
- **P** — priority, where the project defines one.
- **Status** — the **actionable** state in a few words: *Ready* · *Blocked on the author field* · *Merged; 2 criteria open* · *Premise dead; needs rewrite*.

**Rules for the table:**

- **Omit a column the project cannot fill. Never invent a value.** A guessed weight is worse than no weight column — it is indistinguishable from a recorded one.
- **If the project has no vocabulary for a column the maintainer asked for, say so and propose adding it** — do not silently drop it and do not fabricate. (A project may have priority and category labels but no size vocabulary at all; a weight column there is honest only by being absent until labels exist.)
- **Status is the most valuable column and the easiest to fake.** "Open" is not a status — it restates the section heading. Status answers *what would happen if someone picked this up right now*.
- **Group by wave / milestone / epic** where the project has one, with a count in each heading.
- Keep it scannable — this is read to decide what to do next, not archived.

---

## Task Completion Protocol (mandatory)

After completing any **meaningful** task — code changes, doc updates that reflect behaviour, multi-file refactors, new features, or non-trivial fixes — the agent **must**, in the **same response** (before stopping), deliver **all three** of the following **together**:

### 1. PR link

The agent has already created the PR autonomously (per "Branch & PR Requirement" above). Surface the live PR — title + URL — at the top of the trailer. The PR title is in conventional-commit form and is the canonical record of what shipped, so a separate "suggested commit message" block is **redundant and must not be included** in the reply.

Format:

```
**PR:** [<conventional title>](<full PR URL>)
```

If the work didn't produce a PR (rare — e.g. a multi-step task where one step is "stage edits, ask the user before pushing"), state that explicitly instead: `**PR:** not yet created — waiting on <X>`. Never paste a fabricated commit message in place of the link.

### 2. Next 5 steps (from the tracker)

Provide exactly **5 prioritized next steps** pulled from open issues.

- Read `{issueDir}/open/` (local mirror) instead of calling the tracker's list command. See `issues` skill for usage.
- Order by milestone → priority (highest first) → issue number ascending.
- If fewer than 5 open issues exist, fill remaining slots with concrete follow-up tasks from the project's backlog doc.
- Be specific — name the feature, file path, or command. Avoid vague bullets.
- Render as the **Work listing format** table above, rows in priority order (the Status column carries what each step needs).

### 3. Handoff note (one line)

A single sentence summarising the session state for the next agent or session pickup. Prefix it with **Handoff:**

**Order in the reply:** PR link → Next 5 steps → Handoff note. All three must appear in the same assistant turn.

> **Why no commit message?** The agent already creates the PR; the PR title carries the conventional-commit form and the body carries the details. Restating it in chat is pure overhead the maintainer scrolls past. This applies in **end-of-task replies and in handoff documents** alike — neither should include a "suggested commit message" block.

---

## Lesson promotion

A handoff, issue, or PR is a **record**. The rule docs — and the always-loaded `CLAUDE.md` — are what is actually **read on the next turn**. A lesson that lives only in a record will be repeated, so a lesson stable enough to outlast the session must be **promoted to its durable home, in the same PR as the handoff that raised it**. Proposing is not enough: nothing downstream applies a proposal.

- **Apply, don't propose.** A handoff item marked for promotion is written into the durable home in the handoff's own PR. The handoff records that it *landed* (file + section), not that it was suggested.
- **Promote to the home the project already uses — match its convention, don't impose one.** Read `{rulesDir}` and the always-loaded file to see how existing rules are written: some projects keep every rule in the always-loaded file; some keep a one-line pointer there with the full rule in a `{rulesDir}` doc; some have no rules dir at all. Detect which, and match it — a promotion in an unfamiliar shape reads as an outsider's edit and gets reverted. If the target is genuinely ambiguous, ask rather than guess.
- **A promotion earns its slot.** The always-loaded file is read every turn and is finite; appending without limit makes it long enough to be skimmed rather than read — this same failure one level up. If that file is already dense, compress or move something adjacent into `{rulesDir}` in the same edit, so the net does not just grow.
- **A promotion carries its evidence** — the incident and what it cost. A rule with a cost attached survives review; a rule that reads as a bare preference gets argued with every time it surfaces.
- **A promotion can be rejected, and the rejection is recorded.** When the maintainer declines one, that decision is written where the next handoff will see it (a `Rejected promotions` note in `{handoffDir}` or the rules doc) and the item is **not re-proposed** — otherwise a lesson over-generalised from a single incident gets enshrined by attrition.
- **Failure condition (state it plainly):** a promotion that survives **two handoffs** without either landing or being explicitly rejected is a defect in this process, not a pending idea. `pickup` surfaces these.

`handoff` applies promotions; `pickup` checks the previous handoff's promotions actually landed.

---

## When this does not apply

- Pure Q&A or read-only exploration with **no** edits to the repo.
- The user explicitly says to skip handoff formatting for this reply.

---

## Rationale

Keeps `{baseBranch}` always in a releasable state. The maintainer reviews quality via PRs without having to approve each git command. The issue tracker is the single authoritative backlog.
