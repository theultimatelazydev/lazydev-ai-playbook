# Skill: Documentation Update

## Project config

Read optional per-project overrides from `.lz-playbook.json` at the repo root. Keys (defaults): `rulesDir` (`.ai/rules`). If the file is absent, use the default. Below, `{rulesDir}` means this resolved value.

Use this skill to update existing docs.

Rules:
- Preserve existing intent.
- Update related docs when necessary.
- Mark unresolved items as TBD.
- Avoid duplicating shared rules from `{rulesDir}/`.
