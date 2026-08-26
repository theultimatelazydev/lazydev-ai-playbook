# Git Safety Rules

## Branching model — `main` is the stable release, `dev` is the next version

Two long-lived branches:

- **`main`** = the public, stable, "live" release. It is updated **only** by (a) merging `dev → main` when a version is shipped, or (b) a **hotfix** PR (see below). Never feature-by-feature.
- **`dev`** = the integration / working branch — the *next* version. **All** ordinary work (features, fixes, refactors, docs, infra) branches off `dev` and is delivered via a **PR back into `dev`**.

`main` is **untouchable directly**: no direct commits, pushes, rebases, or force-pushes under any circumstances. The same applies to `dev` — reach it only via merged PRs. Only PRs merged by the maintainer land on either.

- **Default flow (almost everything):** branch off `dev` → PR into `dev`.
- **Release:** when a version is closed, `dev → main` (maintainer-run).
- **Hotfix (exception):** a genuinely urgent fix for the live release branches off `main`, PRs into `main`, and must then be **back-merged `main → dev`** so `dev` keeps it. Only use this for true production hotfixes — normal fixes go to `dev`.

## Git autonomy — visibility is automatic; destruction always asks

Two rules govern everything below, and they pull in opposite directions on purpose. Keep them distinct: collapsing them is how an agent ends up force-pushing confidently while sitting on an unpushed branch.

- **Visibility is automatic.** All work is pushed to a branch and opened as a PR — **including handoffs, documentation, and rule changes**. The PR is the unit of visibility and the maintainer's only decision point; nothing waits for permission to become *seeable*. A maintainer reviews the repository, not your working tree — an unpushed branch is invisible to them, so an agent that has finished a coherent piece of work and is *asking whether to push it* has already made the mistake. Push, open the PR, and ask the question **in the PR**, attached to something the maintainer can read.
- **Destruction always asks.** The operations an agent may run unattended are the **exhaustive allowlist** below. Anything not on it requires explicit approval — whether or not it appears in the examples that follow.

Neither rule weakens the other. Making work *visible* is never licence to touch a protected branch; the destruction gate never justifies sitting on unpushed work.

### The autonomy allowlist (exhaustive)

On any branch that is **not** `{baseBranch}` (nor another protected base/release branch such as `main`/`dev`), the agent may run **these operations, and only these**, without waiting for approval:

- `git checkout -b <branch> origin/{baseBranch}` — create the feature branch off `{baseBranch}` (off a release branch only for a hotfix)
- `git add <explicit paths>` — stage (never `git add -A` / `.`; see Worktree hygiene)
- `git commit` — commit with a conventional message
- `git push -u origin <branch>` — push your own feature branch (first push and later fast-forward pushes of it)
- Open a PR targeting `{baseBranch}` with the tracker's PR command (`gh pr create --base {baseBranch}`, `tea pr create --base {baseBranch}`; `--base main` only for a hotfix)
- Prune a local branch/worktree **only** once the tracker confirms its PR MERGED or CLOSED (the `pickup` cleanup) — never on unmerged or unreviewed work

The agent **must** open the PR automatically on task completion. Anything not in this list — including every operation in the examples below — needs an explicit go-ahead first.

### PR requirements (mandatory — see workflow-rules.md)

Before opening the PR, the agent must verify the PR body includes:
- A clear description of what changed
- `Closes #N` (or `Fixes #N`) referencing the tracker issue
- Notes on any deleted files and why
- Any significant decisions made

### Requires explicit approval (illustrative, not the rule)

The rule is the allowlist above. This list is **examples** — common, destructive, and easy to reach for — not a boundary; an operation's absence here never implies it is allowed.

- Merging a PR, and the release merge into `main` — **maintainer only**.
- Any direct operation on a protected branch (`{baseBranch}`, `main`, `dev`): commit, push, rebase, force-push, history rewrite, merge.
- Force-publishing or rewriting shared history: `push --force` / `--force-with-lease`, `rebase` or `commit --amend` on already-pushed work, `filter-branch` / `filter-repo`.
- Discarding work: `reset --hard`, `checkout -- <path>` / `restore`, `clean -fd`, `stash` (it hides work where its owner won't look), `branch -D` / `worktree remove --force` on **unmerged or unreviewed** work.
- Deleting refs on the remote: `push origin --delete <branch>`, `tag -d` / force-moving tags, `reflog expire` / `gc --prune`.
- **Repository- or tracker-level destruction — not git commands, so no git-focused rule catches them:** deleting, transferring, archiving, renaming, or changing the visibility of the repo through `gh` / `tea` (`gh repo delete`, `tea repos delete`, etc.).
- `rm`, moving, or overwriting user asset files — images, audio, models, data (see File safety).

### Never touch a checkout you don't own

Never run an operation that mutates the **working tree or checked-out branch of a checkout the agent did not create** — the maintainer's primary checkout, or another session's worktree. This includes `stash`, `checkout`, `reset`, `clean`, and writing files into that tree. (Real incident: an agent ran `git stash push --include-untracked` against a maintainer's primary checkout to run a control experiment; the tree happened to be clean, so nothing was lost — but a manual check, not the rules, is what saved it.) Work only in your own worktree; to inspect another, read it, never mutate it.

## File safety

- Never overwrite, move, or delete user asset files (images, audio, models, etc.).
- File deletions in the codebase are allowed on feature branches — document them in the PR body.

## Worktree & local-verify hygiene (token + error discipline)

When the session runs inside a git **worktree** (cwd under `.claude/worktrees/<name>`):

- **Every `Read` / `Edit` / `Write` must target the worktree absolute path** — never the bare repo root (`/…/<repo>/src/…`). Editing the bare repo writes to whatever branch the primary checkout has out (usually the default branch), **not** your feature branch; the change is orphaned and you pay to relocate it (`mv` + `git checkout --` + re-read + re-edit). `git` already runs from the worktree cwd, so this only bites *file* ops (the existing `git -C <worktree>` guidance covers git itself).
- **Minimise branch switches in one worktree.** Each `git switch` / `checkout -b` resets read-state and makes the harness re-dump touched file contents — expensive. Do all of a task's reads + edits before switching; prefer a fresh branch off `origin/{baseBranch}` over rebasing-by-switching.
- **Stage explicit paths — never `git add -A` / `git add .`** They grab dependency dirs, lockfiles, build artifacts, and stray scratch files, forcing extra fix cycles. List the files you changed.
- **Verify locally before every PR** — especially if the project's CI is disabled or unreliable. Run the project's own build/typecheck + test commands. **Start Bash commands with the actual binary** — a leading `cd …&&` or `VAR=… ` prefix breaks permission-allowlist prefix-matching (and a stray `cd` can target the wrong tree); use tool-native path flags instead (e.g. `git -C <worktree>`, a build tool's `--manifest`/`--project`/`--cwd` flag).
