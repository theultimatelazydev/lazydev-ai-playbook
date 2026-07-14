# Changelog

All notable changes to this project are documented here. This project follows
[Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/).

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
