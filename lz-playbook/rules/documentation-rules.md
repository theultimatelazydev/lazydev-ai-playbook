# Documentation Rules

- Keep README high-level and readable.
- Use `docs/` for detailed documentation.
- Update docs when architecture or public behavior changes.
- Use ADRs for major decisions.
- Keep docs portable Markdown.
- Avoid relying on Obsidian-only features for source-of-truth docs.
- Use TBD sections for unresolved questions.
- Keep references mapped to features and lessons.
- The issue tracker (not a docs folder) is the source of truth for open work; see `workflow-rules.md` § Task Tracking.

## Verifying documented literals against code

Describe behaviour by reading the **code**, not a comment or an existing doc. Comments outlive the code they describe, and a wrong claim copied into a user-facing page is expensive and public.

- **A doc comment is evidence of intent, never evidence of current behaviour.** Confirm behaviour against the code that runs, not the sentence above it. A proposed root cause read from source is not confirmed until you have checked the mechanism it describes isn't already prevented elsewhere.
- **When a doc states a literal a reader will follow** — a path, filename, directory, command, flag, environment variable, API field, or the label of a control the reader is told to click or type — find *where in the code that literal is produced*, and put that code reference in the PR. These are the claims a reader acts on literally, so they are the ones to verify rather than infer.
- **Where the project can assert it, pin it.** A test comparing a documented literal against the code that produces it is cheap and catches the whole class. Where the docs live outside anything the test suite can reach, the fallback is the code reference above, recorded in the PR so a reviewer checks it in one click rather than trusting it.
- **Calibrate breadth — user-facing vs internal.** Apply the full rule to anything a **user** reads. For **internal** engineering docs — dense with `path/file.ts:123` references whose line numbers drift on every edit — prefer **symbol names over line numbers** (they don't drift); pinning the most drift-prone thing there costs more than it saves.
