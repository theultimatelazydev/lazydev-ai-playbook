# Skill: Documentation Create

## Project config

Read optional per-project overrides from `.lz-playbook.json` at the repo root. Key (default): `rulesDir` (`.ai/rules`). If the file is absent, use the default; if it is present but missing a key a step needs, stop and ask rather than assuming a default (see `{rulesDir}/workflow-rules.md` § Config resolution). Below, `{rulesDir}` means this resolved value.

Use this skill to create new documentation.

Include:
- Purpose
- Scope
- Concepts
- Decisions
- Examples
- TBDs
- Related docs

**Verify claims against code, not comments.** Describe behaviour from the code that runs, not a comment or an existing doc. For any reader-followable literal — a path, filename, command, flag, env var, API field, or the label of a UI control the reader is told to use — find where the code produces it and record that reference in the PR (pin it with a test where the project can). Full rule + the user-facing vs internal calibration: `{rulesDir}/documentation-rules.md` § Verifying documented literals against code.
