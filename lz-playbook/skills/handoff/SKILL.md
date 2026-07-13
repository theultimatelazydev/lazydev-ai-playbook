---
name: handoff
description: Generates a slim end-of-session Markdown handoff in the project handoff dir (`handoff-YYYY-MM-DD.md`) that the next session's `/pickup` reads to resume work. Use when the user wants to end a session, says "gera um handoff", "quero encerrar a sessão", "generate a handoff", "create a session summary", or asks for a pickup/resume document.
---

## Project config

Read optional per-project overrides from `.lz-playbook.json` at the repo root. Keys (defaults): `handoffDir` (`.ai/handoffs`), `issueDir` (`.issues`), `rulesDir` (`.ai/rules`), `baseBranch` (`main`). If the file is absent, use the defaults. Below, `{handoffDir}` / `{issueDir}` / `{rulesDir}` / `{baseBranch}` mean these resolved values.

# Handoff

## What this is

End-of-session document that the next session's `/pickup` reads. **CLAUDE.md is auto-loaded every session at zero marginal token cost — DO NOT re-state its content here.** That includes the tech stack, hard constraints, branch + PR conventions, sub-agent dispatch protocol, and any project-specific API/schema contracts. The handoff exists for what CLAUDE.md *doesn't* cover: this session's arc, current state, open questions, and the next agent's first move.

## Steps

### Step 0 — Branch + worktree + PR (mandatory)

Like any change, do the handoff on a NEW branch in a dedicated worktree off `{baseBranch}` and ship it as a PR (`--base {baseBranch}`) — never leave the handoff (or the AGENTS.md pointer bump) uncommitted in the working copy, and never edit the shared base checkout directly. The two files (`handoff-YYYY-MM-DD.md` + the AGENTS.md pointer line) are the PR's whole diff.

### 1. Sketch the session's arc

Skim git log + your own session memory. Don't enumerate every PR — `git log --oneline origin/{baseBranch} -30` is canonical.

### 2. Write the doc

Save to **`{handoffDir}/handoff-YYYY-MM-DD.md`** (today's date). Use this 6-section structure. Omit any section that doesn't apply this session (don't pad with "N/A").

```markdown
# Handoff: [short title — what this session was about]

**Date:** YYYY-MM-DD
**Status:** [steady state / in progress / blocked]
**{baseBranch} HEAD:** [short SHA]

## 1. Session arc

One paragraph. Headline numbers (PRs merged, issues closed, issues filed) + a single-sentence theme. No PR-by-PR chronology — `git log` is the source of truth.

## 2. New conventions / vocabulary

Anything the next session needs that **isn't already in CLAUDE.md**. Module renames, new event names, new schema entities, conventions adopted, new file locations. One bullet per item, ≤2 lines each. **If a bullet here is stable enough to outlast this session, it should move to CLAUDE.md instead** — call that out and propose the edit.

If the session didn't introduce new vocabulary, omit this section.

## 3. Current state

- **Works:** brief list, pointer to PRs is fine. Don't restate features that were already working.
- **Incomplete / known follow-ups:** what's deferred, with `path:line` or `path::function` so the next agent knows where the gap is. Be honest — call out skipped scope from agent PRs.
- **Open issues backlog:** filter `{issueDir}/open/` to alpha-blocker / alpha / next-priority. Short list (#N + title + tag).

## 4. Open questions

Real blockers — decisions that must be made before specific work can continue. If none, omit.

Soft musings, "could we someday…", and not-yet-blocking observations go in §3 follow-ups, not here.

## 5. Next steps

2–4 ordered options with concrete files + why. Each option specifies whether it's parallelizable. Format:

> **Option A — [name].** Files: `path::symbol` (line N) … . [parallel-friendly: 3 agents, no overlap | solo: cross-cutting refactor].

Each option must name files, line ranges or function names, and what to change — specific enough that the next agent can act without asking questions.

## 6. Suggested first action

After /pickup, do X. One sentence + the exact command if relevant.
```

### 3. Update AGENTS.md

```markdown
**Latest session handoff:** [`{handoffDir}/handoff-YYYY-MM-DD.md`](./{handoffDir}/handoff-YYYY-MM-DD.md)
```

### 4. Confirm with the user

Reply with: file path + 3-bullet summary of the most important things the next agent needs + ask if anything is missing.

## Quality rules

- **Don't restate CLAUDE.md.** Tech stack, hard rules, branch pattern, PR body format, sub-agent dispatch protocol, pitfalls, dev commands — all already auto-loaded. Repeating them is pure overhead.
- **Don't enumerate every PR** — `git log` is canonical. The session arc is one paragraph.
- **Do not include a "suggested commit message" section.** Per `{rulesDir}/workflow-rules.md`, the workflow drops commit-message blocks from end-of-task replies and handoff docs alike — the merged PRs already carry their own messages and `git log` is the canonical record. Reference PR numbers (`#N`) inline if needed; never paste a commit-message template.
- **Bullets > prose.**
- **`path:line` or `path::function`** in §5 so the next agent can `Read` with offset+limit instead of scanning whole files.
- **Self-contained vs CLAUDE.md-aware** — the handoff is meant to be read alongside CLAUDE.md, NOT in isolation. If the next session might NOT have CLAUDE.md (rare for this repo), see "Verbose form" below.

## Quality checklist

Before finishing, verify:

- [ ] No section duplicates CLAUDE.md content (tech stack table, hard-rules list, branch convention, sub-agent protocol, pitfalls — all should be ABSENT).
- [ ] No "suggested commit message" section anywhere — per `{rulesDir}/workflow-rules.md`, handoffs reference PR numbers but never paste commit-message templates.
- [ ] §1 is one paragraph max.
- [ ] §3 names `path:line` for every "incomplete / follow-up" item.
- [ ] §5 next-step options name files + functions + line ranges, with conflict map for parallel options.
- [ ] §4 contains real blockers, not nice-to-knows.
- [ ] AGENTS.md latest-handoff pointer updated.
- [ ] Handoff is on a new branch + PR to `{baseBranch}` — not left uncommitted in the working copy.

## Verbose form (rare)

If the next session might NOT have CLAUDE.md auto-loaded — handing off to a fresh repo, an external contractor, a non-Claude agent without project access — expand each section to include the duplicated CLAUDE.md context (tech stack, hard rules, conventions, dispatch protocol, pitfalls, dev commands, etc.). Default is the slim form above; only switch to verbose when the user explicitly asks for "full handoff" or the audience is genuinely outside this repo's tooling.
