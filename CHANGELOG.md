# Changelog

All notable changes to this project are documented here. This project follows
[Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **`document` — a house style for user documentation** (`skills/document/style-guide.md`). How a
  product wiki is shaped and written: site order, page anatomy (summary line → definition with real
  examples → Overview → Metadata → tasks → Limitations → Next steps), the four-column Metadata
  table, one job per callout kind, screenshot placeholders that start with `Screenshot:` so search
  finds them, collapsed questions as toggle lists, troubleshooting/FAQ/glossary patterns, voice
  rules and a pre-publish checklist. Includes a MkDocs Material → Noltez mapping for migrating an
  existing site. Mirrored as a Noltez page keyed `repo:lazydev-ai-toolkit/docs#docs-style-guide`.

### Changed
- **`document` speaks Noltez.** note-app was renamed; the skill now names `mcp__noltez__*` tools.
  Existing `repo:note-app/…` keys are left alone — a key is identity.

## [0.3.0]

Templates and rule docs overhauled from cross-project usage — seven interacting defects where the
tooling produced the bad behaviour, so a rule alone couldn't fix it. **Re-run `/lz-playbook:setup`**
to adopt (see the README "Updating an existing project" note).

### Added
- **`create-issue` — `Definition of done` + an owned `Out of Scope`.** Each issue body leads its
  scope with a mandatory **Definition of done** (the user-visible outcome — replaces the old
  `Expected Behavior` heading). `Out of Scope` belongs to the maintainer: an agent may record only
  a named different feature, a decided constraint with its reference, or a maintainer-stated cut —
  anything else routes to `## Questions` and is raised in conversation before filing.
- **Applied lesson promotion** (`handoff` + `workflow-rules` § Lesson promotion). A lesson worth
  outlasting the session is now **applied in the handoff's own PR**, promoted to the durable home
  the project already uses (matching its convention), earning its slot, carrying its evidence.
  Handoffs record what landed in a new §7; rejections are recorded so they aren't re-proposed; a
  promotion surviving two handoffs without landing or rejection is flagged as process debt.
- **`pickup` promotion check.** Before the briefing, `pickup` verifies the previous handoff's
  promotions actually landed and surfaces unlanded ones as work (capped at three, offers to batch).
- **Work listing format** (`workflow-rules`). One table spec — `#`, Title, Category, Weight,
  Priority, Status — that every work-listing skill now renders, omitting columns the project can't
  fill, never inventing values, and proposing vocabulary when a column is asked for but undefined.
- **PR acceptance-criteria + partial marking.** A PR implementing an issue lists that issue's
  criteria met/unmet; when any is unmet the PR is flagged in the PR *list* via the new
  `partialMarker` config key (`label` default / `suffix` / `checklist`) — never a title prefix.
  "Verified by unit tests" doesn't mark a user-facing criterion met, and a criterion is verified in
  the environment where it can fail.
- **`setup` — optional issue-op permission setup.** When the user opts in, `/lz-playbook:setup`
  offers to allowlist the tracker sync CLI so `issues`/`create-issue`/`handoff`/`pickup` stop
  prompting on every call; entries go to the personal, git-ignored `.claude/settings.local.json`.

### Changed
- **Git autonomy is now a matched pair — *visibility is automatic; destruction always asks***
  (`git-safety-rules`). All work (handoffs, docs, and rule changes included) is pushed to a branch
  and opened as a PR without waiting for approval — the PR is the unit of visibility. The autonomy
  allowlist is stated **exhaustive** (anything not listed needs approval); the approval list is
  reframed as non-exhaustive examples and extended to cover force-push/rebase/amend, `filter-branch`,
  `restore`/`clean`/`stash`, remote ref & tag deletion, `reflog`/`gc`, and **repository/tracker-level
  destruction via `gh`/`tea`**. A checkout the agent doesn't own is off limits.
- **Skills cite rule docs instead of paraphrasing them.** `pickup` no longer contradicts
  `git-safety-rules` on git operations; `doc-audit` no longer says "do not commit/push" (it delivers
  a PR); `implementation`/`issues` cite rules they used to restate; priority ordering no longer
  hardcodes a project-specific `alpha-blocker`/`p0–p5` scheme.
- **Documentation skills verify literals against code** (`documentation-rules` +
  `doc-create`/`doc-update`/`doc-audit`/`doc-review`). A doc comment is evidence of intent, never
  current behaviour; any reader-followable literal (path, command, flag, API field, UI label) is
  checked against the code that produces it and the reference recorded in the PR — full rule for
  user-facing docs, drift-free symbol names for internal ones.
- **Config resolution fails loud, not silent.** No `.lz-playbook.json` → documented defaults still
  apply (zero-config projects keep working); file present but a needed key missing → the skill stops
  and asks. Skills no longer hardcode paths/branches that bypass the config placeholders.
- `setup` now documents that the sync CLIs are **zero-config** (infer instance/owner/repo from the
  git `origin` remote); a config file stays optional/override-only.
- **Comment sidecars documented.** Where the sync tool mirrors comments (`tea-issue-sync` with
  `output.comments: true`), each issue gets a read-only `<n>-<slug>.comments.md` sidecar worth
  reading for context — the body stays the durable source of truth.

### Fixed
- Corrected the `tea-issue-sync` config filename in `setup` to **`.tea-issue-sync.json`** (upstream
  renamed it from `config.json`).
- Removed leaked project-specific vocabulary/paths from the generic skills (`test-planning` domain
  list, `doc-audit` `.ai/skills`/`.ai/agents`/`project-rules.md` and GitHub-only references,
  `create-issue` mis-attributed citation).

## [0.2.0]

### Added
- **`/lz-playbook:setup`** — one-command onboarding: detects the project's tracker,
  base branch, and directories; writes `.lz-playbook.json`; scaffolds the issue/
  handoff/rules dirs; copies the rule docs; and adds a managed block to `CLAUDE.md`.
  Idempotent and confirm-before-write on committed files.

### Changed
- Renamed the `gh-issue` skill to **`issues`** (`/lz-playbook:issues`). It was already
  tracker-agnostic (routing through the configured `{issueSyncCmd}` — `gh-issue-sync`
  for GitHub, `tea-issue-sync` for Gitea); the old name just read as GitHub-only.

### Fixed
- `setup` now fetches the rule docs from the plugin's public repo when the plugin
  directory isn't readable (sandboxed runtimes such as Cowork), instead of failing
  the local copy. Local copy remains the desktop fast path.
- Corrected the GitHub repo URLs (README, install snippet, `setup`'s `CLAUDE.md`
  block) to `lazydev-ai-playbook` — the actual public mirror.

## [0.1.0]

### Added
- Initial release: a reusable Claude Code plugin + marketplace bundling 13 generic
  AI dev-workflow skills (handoff, pickup, code/doc/architecture review, feature/
  test planning, implementation, create-issue, and issue reading), the
  `documentation-specialist` agent, and the git-safety/documentation/workflow rule
  docs. Config-driven per project via `.lz-playbook.json`. MIT-licensed, with
  manifest-validation CI for GitHub and Gitea.
