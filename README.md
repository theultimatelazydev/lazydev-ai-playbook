# lazydev-playbook

A reusable **Claude Code plugin + marketplace** bundling TheUltimateLazyDev's
generic AI dev-workflow skills and agents, so they can be shared across projects
instead of copied per-repo. The skills are **config-driven** — they adapt to each
project via a `.lz-playbook.json` file (see [Configuring per project](#configuring-per-project)).

> **Early-stage.** Home: [github.com/theultimatelazydev/lazydev-playbook](https://github.com/theultimatelazydev/lazydev-playbook).
> The generic skills are config-driven, so adopting it in a new project needs no
> skill changes — just a `.lz-playbook.json`. (See also the companion
> [tea-issue-sync](https://github.com/theultimatelazydev/tea-issue-sync).)

## Layout

```
lazydev-playbook/                 ← marketplace repo root
  .claude-plugin/marketplace.json   ← lists the plugin (source ./lz-playbook)
  .lz-playbook.example.json             ← per-project config template
  lz-playbook/                        ← the plugin
    .claude-plugin/plugin.json
    skills/      14 generic skills (SKILL.md each)
    agents/      documentation-specialist
    rules/       git-safety, documentation, workflow (reference docs)
  README.md
```

## What's included

**Skills** (`/lz-playbook:<name>` once installed): `setup` (onboard a project),
`handoff`, `pickup`, `code-review`, `doc-audit`, `doc-create`, `doc-review`,
`doc-update`, `feature-planning`, `test-planning`, `architecture-review`,
`implementation`, `create-issue`, `gh-issue`.

**Agent:** `documentation-specialist`.

**Rules** (reference docs): `git-safety-rules`, `documentation-rules`, `workflow-rules`.

Project-specific skills (e.g. `generate-uam-json`, `import-pipeline-review`,
`metadata-model-review`, `live-debug-tauri-ui`, `architecture-diagram`) are
deliberately **left in their home repos** — Claude loads plugin skills *and* the
project's own `.claude/skills/`, so the two coexist.

## Configuring per project

Skills that touch project conventions (`handoff`, `pickup`, `create-issue`,
`gh-issue`, `doc-audit`, `doc-update`, `implementation`) read an optional
`.lz-playbook.json` at the consuming project's repo root. All keys optional; defaults
match a GitHub + `gh-issue-sync` setup:

| key | default | used by |
|-----|---------|---------|
| `issueDir` | `.issues` | create-issue, gh-issue, handoff, pickup, implementation |
| `issueTracker` | `github` (`github`\|`gitea`) | create-issue, gh-issue |
| `issueSyncCmd` | `gh-issue-sync` (needs a gh-issue-sync-compatible CLI: pull/push/new/close/status/diff) | create-issue, gh-issue |
| `handoffDir` | `.ai/handoffs` | handoff, pickup, implementation |
| `rulesDir` | `.ai/rules` | most skills |
| `baseBranch` | `main` | handoff, pickup, implementation |

The lazy way: run **`/lz-playbook:setup`** once — it detects your tracker, base
branch, and dirs, writes `.lz-playbook.json`, scaffolds the dirs, copies the rule
docs, and wires a managed block into `CLAUDE.md`. Or do it by hand: copy
`.lz-playbook.example.json` → `.lz-playbook.json` and edit. Example for a Gitea +
`dev`-branch project:

```json
{ "issueDir": ".issues-tea", "issueTracker": "gitea", "issueSyncCmd": "tea-issue-sync", "baseBranch": "dev" }
```

> The other 6 skills (`code-review`, `doc-create`, `doc-review`,
> `feature-planning`, `test-planning`, `architecture-review`) are tool/convention
> agnostic and need no config.

## Installing in a project

Add to the project's committed `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "lazydev-playbook": {
      "source": { "source": "github", "repo": "theultimatelazydev/lazydev-playbook" }
    }
  },
  "enabledPlugins": {
    "lz-playbook@lazydev-playbook": true
  }
}
```

Or interactively: `claude plugin marketplace add <git-url>` → `claude plugin install lz-playbook@lazydev-playbook`.

**Version pinning:** bump `version` in `lz-playbook/.claude-plugin/plugin.json`; projects only update when that changes (omit version → tracks the branch SHA, i.e. every commit).

**Reachability:** the marketplace git source must be reachable when Claude loads
it. A public remote (e.g. GitHub) resolves everywhere; a private or VPN-only host
only resolves from machines on that network.

## Rules — how they apply

Claude Code has **no native always-on "rules"** mechanism (unlike Cursor). The
`rules/` docs are reference material; to make them active in a project, reference
them from that project's `CLAUDE.md` (via `rulesDir`), or fold the protocol into
the relevant skill bodies. (A future `agents/` default-agent could embed them.)

## Roadmap

See [`ROADMAP.md`](./ROADMAP.md).

## License

MIT — see [`LICENSE`](./LICENSE).
