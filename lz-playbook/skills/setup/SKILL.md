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

Get the three rule docs (`git-safety-rules.md`, `documentation-rules.md`, `workflow-rules.md`) into `{rulesDir}/`. Use whichever source is reachable in the current environment — **try local first, fall back to the public repo**:

- **Local (desktop Claude Code):** the docs ship beside this skill in the plugin's `rules/` dir (sibling to `skills/`). If that directory is readable, copy from there.
- **Public repo (sandboxed runtimes — e.g. Cowork):** the plugin is often installed in an app-internal directory the tool sandbox **cannot read**. When the local `rules/` dir isn't readable, fetch each doc from the plugin's public repo instead:
  - `https://raw.githubusercontent.com/theultimatelazydev/lazydev-ai-playbook/main/lz-playbook/rules/workflow-rules.md`
  - `https://raw.githubusercontent.com/theultimatelazydev/lazydev-ai-playbook/main/lz-playbook/rules/git-safety-rules.md`
  - `https://raw.githubusercontent.com/theultimatelazydev/lazydev-ai-playbook/main/lz-playbook/rules/documentation-rules.md`
- If neither source is reachable (offline + unreadable plugin dir), **skip the copy and say so** — the skills still work without local rule docs; only the `CLAUDE.md` pointer below assumes they exist.
- If the project already maintains a file of the same name, **ask before overwriting**.

Then add a **managed block** to `CLAUDE.md` at the repo root, between markers, pointing at them and listing the skills:

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

Both sync CLIs are **zero-config** — run inside a repo whose `origin` points at the tracker and they infer the instance / owner / repo from the git remote (auth comes from `gh`/`tea`/`$GITEA_TOKEN`). A config file is **optional, override-only**, so setup does **not** create one. Don't instruct the user to write a `config.json`; only mention it if they need to override an inferred value (e.g. sync from a non-`origin` remote).

### 7. (Optional) Reduce permission prompts for issue ops

The `issues`, `create-issue`, `handoff`, and `pickup` skills call the tracker sync CLI (`{issueSyncCmd}`) often, and Claude Code prompts on each shell call by default. If the user works with the tracker regularly, offer to allowlist the sync commands so those runs stop prompting.

- **Ask first** whether they want this. If they don't use `{issueSyncCmd}`, skip the step entirely.
- If yes, **ask how broad** — wider scope means fewer prompts, but the write ops reach the live tracker. Offer three scopes:
  - **Reads only** — `pull`, `status`, `diff` (and `list` where the CLI supports it). Never prompts for inspection; still prompts to create, close, or push.
  - **Reads + local** *(recommended)* — the above plus `new` (writes a number-less **local** file; doesn't touch the tracker). Prompts only on true remote writes (`push`, `close`, `reopen`).
  - **Everything** — `{issueSyncCmd}:*`. No prompts at all, including remote writes.
- Write the chosen entries to **`.claude/settings.local.json`** — the **personal, git-ignored** settings file, *not* the committed `settings.json`. Merge into `permissions.allow`; never clobber existing entries. Example for the **Reads + local** scope with `{issueSyncCmd}` = `tea-issue-sync`:

```json
{
  "permissions": {
    "allow": [
      "Bash(tea-issue-sync pull:*)",
      "Bash(tea-issue-sync status:*)",
      "Bash(tea-issue-sync diff:*)",
      "Bash(tea-issue-sync list:*)",
      "Bash(tea-issue-sync new:*)"
    ]
  }
}
```

- Use the resolved `{issueSyncCmd}` in the patterns (`gh-issue-sync` for GitHub, `tea-issue-sync` for Gitea). For the **Everything** scope a single `Bash({issueSyncCmd}:*)` entry replaces the per-subcommand list.
- Ensure `.claude/settings.local.json` is git-ignored (Claude Code ignores it by default; if the project's `.gitignore` doesn't already cover it, add it) — these are per-developer choices and must not be committed.

### 8. (Optional) Commit the team install

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

### 9. Summarise

Report what changed — config values written, dirs created, rules copied, `CLAUDE.md` block added/updated, tracker-CLI status, and any issue-op permissions written to `settings.local.json` (with the scope chosen) — and the first move: **"Run `/lz-playbook:pickup` to start a session."**

## Rules

- **Idempotent** — re-running merges config and replaces the managed block; it never duplicates.
- **Confirm before writing** to `CLAUDE.md` and `.claude/settings.json` — both are committed, human-owned files; show a diff first.
- **Never clobber** an existing `.lz-playbook.json`, rule doc, or settings file — merge and surface conflicts.
- **Personal vs committed settings** — issue-op permissions (Step 7) go in `.claude/settings.local.json` (git-ignored, per-developer); the team install (Step 8) goes in `.claude/settings.json` (committed). Never write auto-allow permissions into the committed file.
- **Permissions are opt-in** — only write them after the user says yes and picks a scope; never allowlist tracker write ops by default.
- Detection is best-effort; the user's confirmation in Step 2 is authoritative.
