---
name: setup
description: One-command onboarding for a project that just installed the lz-playbook plugin. Detects the project's conventions, writes .lz-playbook.json, scaffolds the handoff/issue/rules dirs, copies the rule docs, and adds a managed block to CLAUDE.md. Use right after installing the plugin, or when the user says "set up lz-playbook", "configure the playbook", "onboard this repo".
---

# Skill: Setup

Onboards the current repository to the lz-playbook plugin: after this runs, the config exists, the directories exist, the rules are active, and the `/lz-playbook:` skills work against the project's own conventions. **Idempotent** — safe to re-run; it updates in place rather than duplicating.

## Config keys

`.lz-playbook.json` at the repo root (all optional; these are the defaults):

| key | default | meaning |
|-----|---------|---------|
| `issueDir` | `.issues` | local issue mirror |
| `issueTracker` | `github` | `github` \| `gitea` |
| `issueSyncCmd` | `gh-issue-sync` | tracker sync CLI (pull/push/new/close/status/diff) |
| `handoffDir` | `.ai/handoffs` | session handoff docs |
| `rulesDir` | `.ai/rules` | where the rule docs live |
| `baseBranch` | `main` | integration / PR-target branch |

## Steps

### 1. Detect the project's conventions (don't ask blindly)

Run read-only probes and propose values:

- **Tracker** — `git remote get-url origin`. Host contains `github.com` → `issueTracker: github`, `issueSyncCmd: gh-issue-sync`. Otherwise (Gitea / self-hosted) → `gitea` + `tea-issue-sync`.
- **Base branch** — `git remote show origin | sed -n 's/.*HEAD branch: //p'` (fallbacks: strip `origin/` from `git symbolic-ref --short refs/remotes/origin/HEAD`; else `main`).
- **Issue dir** — if `.issues-tea/` exists use it; elif `.issues/` exists use it; else default by tracker (`github → .issues`, `gitea → .issues-tea`).
- **Handoff / rules dirs** — reuse `.ai/handoffs` / `.ai/rules` if present; else the defaults.

### 2. Confirm with the user

Show the detected table and ask them to confirm or override any value **before writing anything**. If `.lz-playbook.json` already exists, load it and present a merge — never silently clobber.

### 3. Write `.lz-playbook.json`

Write only the keys that differ from the defaults (keep it minimal and readable). If the file exists, merge the confirmed values in.

### 4. Scaffold directories

Create if missing: `{issueDir}/open`, `{handoffDir}`, `{rulesDir}`. Leave existing dirs untouched.

### 5. Activate the rules

The rule docs ship inside this plugin at `../../rules/` (relative to this skill file): `git-safety-rules.md`, `documentation-rules.md`, `workflow-rules.md`.

- Copy them into `{rulesDir}/`. If the project already maintains a file of the same name, **ask before overwriting**.
- Add a **managed block** to `CLAUDE.md` at the repo root, between markers, pointing at them and listing the skills:

```markdown
<!-- lz-playbook:start -->
## lz-playbook

This project uses the [lz-playbook](https://github.com/theultimatelazydev/lazydev-ai-playbook) plugin. Follow the rule docs in `{rulesDir}`:
- `{rulesDir}/workflow-rules.md` — branch / PR / testing / task-completion protocol
- `{rulesDir}/git-safety-rules.md` — branching model + git autonomy
- `{rulesDir}/documentation-rules.md` — documentation conventions

Skills: `/lz-playbook:pickup` (start a session), `/lz-playbook:handoff` (end one), plus code/doc/architecture review, feature/test planning, implementation, and issue ops (`create-issue`, `issues`).
<!-- lz-playbook:end -->
```

- If `CLAUDE.md` doesn't exist, offer to create it with this block. On a re-run, replace only the content **between** the markers — never duplicate the block.
- Show the diff and confirm before writing (`CLAUDE.md` is a committed, human-owned file).

### 6. Check the tracker CLI

Verify `{issueSyncCmd}` is on PATH (`command -v {issueSyncCmd}`). If missing, point the user at it — don't fail setup over it (the non-issue skills work regardless):

- `gh-issue-sync` → https://github.com/mitsuhiko/gh-issue-sync
- `tea-issue-sync` → https://github.com/theultimatelazydev/tea-issue-sync

### 7. (Optional) Commit the team install

Offer to add the marketplace + plugin to the project's committed `.claude/settings.json` so teammates get it automatically:

```json
{
  "extraKnownMarketplaces": {
    "lazydev-playbook": { "source": { "source": "github", "repo": "theultimatelazydev/lazydev-ai-playbook" } }
  },
  "enabledPlugins": { "lz-playbook@lazydev-playbook": true }
}
```

Merge into existing settings; ask first — this is a committed, team-wide change.

### 8. Summarise

Report what changed — config values written, dirs created, rules copied, `CLAUDE.md` block added/updated, tracker-CLI status — and the first move: **"Run `/lz-playbook:pickup` to start a session."**

## Rules

- **Idempotent** — re-running merges config and replaces the managed block; it never duplicates.
- **Confirm before writing** to `CLAUDE.md` and `.claude/settings.json` — both are committed, human-owned files; show a diff first.
- **Never clobber** an existing `.lz-playbook.json`, rule doc, or settings file — merge and surface conflicts.
- Detection is best-effort; the user's confirmation in Step 2 is authoritative.
