# Roadmap

## Done ✅

- [x] Scaffold plugin + marketplace; bundle the generic skills, agent, and rules.
- [x] Parameterize project-specifics via `.lz-playbook.json` (config-driven skills).
- [x] Extract to its own repository, decoupled from any single consuming project.
- [x] License + `.gitignore` + manifest-validation CI (GitHub + Gitea).

## Next

- [ ] **Smoke-test outside the origin project.** Install into a throwaway repo
      with a `.lz-playbook.json` and confirm the skills resolve the placeholders
      (`{issueDir}`, `{baseBranch}`, …). The substitution is a convention the
      skill bodies describe — validate it end-to-end.
- [ ] **Consumer adoption.** Wire consuming projects to install via the
      marketplace and delete any vendored copies of these generic skills, so
      there is a single source of truth (no drift).

## Considering

- [ ] `sync-cursor.mjs` — project the `rules/` docs into `.cursor/rules/` +
      `AGENTS.md` for Cursor (secondary; Claude is the primary target).
- [ ] Default the config to `.claude/`-based paths instead of `.ai/`, given the
      toolkit is Claude-focused (see the config table in the README).
- [ ] A default `agents/` agent that embeds the `rules/` docs so they apply
      without per-project `CLAUDE.md` wiring.
