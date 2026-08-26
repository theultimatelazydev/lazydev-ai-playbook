# Skill: Documentation Update

## Project config

Read optional per-project overrides from `.lz-playbook.json` at the repo root. Key (default): `rulesDir` (`.ai/rules`). If the file is absent, use the default; if it is present but missing a key a step needs, stop and ask rather than assuming a default (see `{rulesDir}/workflow-rules.md` § Config resolution). Below, `{rulesDir}` means this resolved value.

Use this skill to update existing docs.

Rules — follow `{rulesDir}/documentation-rules.md`:
- Preserve existing intent.
- Update related docs when necessary; mark unresolved items as TBD.
- **Verify claims against code, not comments.** A doc comment is evidence of intent, never current behaviour. For any reader-followable literal (path, filename, command, flag, env var, API field, UI control label), find where the code produces it and record that reference in the PR — see `{rulesDir}/documentation-rules.md` § Verifying documented literals against code.
- Don't duplicate shared rules from `{rulesDir}/` — cite them.
