---
name: pickup
description: Orients a new agent session by reading the latest handoff and producing a concise briefing + suggested first action. Use when starting a new session, resuming work, saying "let's pick up", "let's pick up from where we left", "pickup", "vamos continuar", "continue from where we left off", "what was I doing?", or asking what to work on next.
---

## Project config

Read optional per-project overrides from `.lz-playbook.json` at the repo root. Keys (defaults): `handoffDir` (`.ai/handoffs`), `issueDir` (`.issues`), `rulesDir` (`.ai/rules`), `baseBranch` (`main`). If the file is absent, use the defaults. Below, `{handoffDir}` / `{issueDir}` / `{rulesDir}` / `{baseBranch}` mean these resolved values.

# Pickup

## What this is

Read the latest handoff + render a tight briefing. CLAUDE.md is auto-loaded — don't re-read or re-state its content.

## Steps

### 1. Find the latest handoff

```bash
ls -t {handoffDir}/handoff-*.md | head -1
```

Read that file.

If no handoff exists, fall back to the priority-ordered list:
- `ls {issueDir}/open/` for the active backlog (use the `issues` skill to read individual issues).
- `git log --oneline origin/{baseBranch} -10` for recent shipped work.
- AGENTS.md for the canonical pointers.

Skip any backlog files the project's own docs mark as deprecated or stale — the issue tracker (`{issueDir}/`) is the source of truth for open work.

### 2. Prune local branches/worktrees whose PRs already merged/closed

Leftover branches and worktrees accumulate across sessions — left unchecked they grow to a dozen-plus worktrees, which can slow tooling and pollute test globs. Clean them up as part of orienting.

**Procedure:**

```bash
# 1. Refresh remote state + list local branches/worktrees
git fetch origin --prune
git worktree list
git branch

# 2. Resolve which local head-branches have a MERGED or CLOSED PR
#    (use the tracker CLI: gh for GitHub, tea for Gitea, etc.)
gh pr list --state all --json number,state,headRefName \
  -q '.[] | select(.state=="MERGED" or .state=="CLOSED") | .headRefName'
# Intersect that set with the local branches from step 1.

# 3. For each merged/closed branch that has a worktree, remove it then delete the branch:
git worktree remove --force --force <path>   # double --force: worktrees are usually locked
git branch -D <branch>                        # force: squash-merges don't show as `git branch --merged`
git worktree prune
# Also delete the throwaway scaffolding branches: git branch -D worktree-agent-*
```

Report a one-line summary in the briefing (step 4): how many branches/worktrees were removed.

**Safety — NEVER delete these:**

- `{baseBranch}` (and any other protected base/release branch), and the branch checked out in the CURRENT/primary worktree (this session's own).
- Any branch whose PR is still **OPEN**, or that has no PR and has unmerged local-only commits (work not yet pushed/merged).
- **Other live sessions' worktrees** — do not remove a worktree you didn't create or whose branch isn't a confirmed merged/closed PR (e.g. another coordinator session's `claude/<name>` worktree). Only act on branches/worktrees confirmed merged/closed via the tracker CLI.
- **Verify merge state via the tracker CLI** (PR MERGED/CLOSED) before deleting. Do NOT rely on `git branch --merged` (it misses squash-merges) and do NOT delete on a guess.

### 3. Render a briefing

Reply with:

```markdown
## Session Briefing

**Picking up from:** [handoff filename]
**Status:** [one sentence from handoff §1]

### What's relevant now
[1–2 bullets from handoff §3 — only items the user is likely to act on]

### Next-step options
[from handoff §5 — keep top 2–3 options; don't expand on each unless asked]

### Suggested first action
> [from handoff §6, exact command/file if given]
```

Keep this **short** — it's a launchpad, not a recap. If the user wants detail on any option, they'll ask.

### 4. Ask for direction

> "Want to start with [top option], or something else?"

## Rules

- **Never invent context** that isn't in the handoff. If a section is missing or unclear, say "handoff §X is empty / unclear" and ask the user.
- **No git operations** without explicit user approval (per `{rulesDir}/git-safety-rules.md`) — the **one exception** is the step-2 cleanup, which may delete only branches/worktrees confirmed MERGED/CLOSED via the tracker CLI (never `{baseBranch}`/other protected base branches/the current worktree/open or unmerged work).
- **Don't re-read CLAUDE.md** — it's auto-loaded.
- **Don't re-summarize the full handoff in chat.** The briefing is a 5-bullet launchpad, not a copy.
- If the handoff is older than ~7 days, surface that to the user — backlog priorities may have shifted.
