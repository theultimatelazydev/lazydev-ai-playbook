# Skill: Implementation

## Project config

Read optional per-project overrides from `.lz-playbook.json` at the repo root. Keys (defaults): `issueDir` (`.issues`), `issueSyncCmd` (`gh-issue-sync`), `handoffDir` (`.ai/handoffs`), `rulesDir` (`.ai/rules`), `baseBranch` (`main`). If the file is absent, use the defaults. Below, `{issueDir}` / `{issueSyncCmd}` / `{handoffDir}` / `{rulesDir}` / `{baseBranch}` mean these resolved values.

Use this skill when adding features, fixing bugs, or making any code change to the repo.

> This skill is stack-agnostic. For language/framework-specific conventions (where commands live, required wrappers, forbidden imports, test layout), defer to the consuming project's own `CLAUDE.md` / `AGENTS.md` and the docs under `{rulesDir}`.

---

## Phase 1 — Orient (before touching any file)

### 1a. Get the issue
Prefer the local issue mirror via the `gh-issue` skill (read `{issueDir}/open/<N>-*.md`). If you must hit the tracker directly, use its read-only view command (e.g. `gh issue view <N>` for GitHub, `tea issue <N>` for Gitea). If you can't reach the tracker, check the latest handoff's §5 (Next Steps) — it has context.

### 1b. Check the latest handoff
Read `{handoffDir}/handoff-YYYY-MM-DD.md` (most recent). It may have exact insertion points, relevant snippets, and decisions already made — skip re-deriving them.

### 1c. Find before you read
**Always grep before opening a file.** Grep gives you line numbers so you can read only the relevant slice with `offset` + `limit`.

```bash
# Find a definition (function / class / type — adapt the pattern to the language)
grep -rn "def my_function\|function myFunction\|fn my_function" src/

# Find all call sites
grep -rn "my_function" src/

# Find where to insert (e.g. the last registration in a list/registry)
grep -n "register(" src/registry.* | tail -5
```

Read files with `offset` + `limit` targeting the grep hit ± 15 lines. Never read a full file when a slice will do.

### 1d. Standard insertion points for common task types
Discover the project's real conventions rather than assuming — grep for a sibling of the thing you're adding and mirror it.

| Task | How to find where it goes |
|------|---------------------------|
| New public function / endpoint / command | Grep an existing sibling; add next to it and register it wherever siblings are registered |
| New data type / model | Find the module that holds existing types; append after the last one |
| New UI component | Follow the existing component-directory layout; import it in the parent that needs it |
| New unit test | Co-locate with the code under test if the project does, else the mirror path in the test tree |
| Wiring/startup hook | Grep the app's init/bootstrap path and add there |

---

## Phase 2 — Plan (write nothing yet)

Before editing:
1. List every file you will touch and why.
2. For each file, name the exact insertion point (function/symbol name, or line range from grep).
3. Note any contract that two layers must agree on (e.g. a type shared across a serialization boundary, an API shape shared by client and server) and how the project keeps them in sync.

This list becomes the checklist you tick off as you write.

---

## Phase 3 — Implement

Work in dependency order — lowest layer first, wiring last. A typical sequence:

1. **Core types / models** — add any new data structures first.
2. **Domain / business logic** — add the pure logic plus its unit tests.
3. **Interface layer** — the endpoint / command / handler that exposes the logic.
4. **Registration** — wire the new entry into whatever registry/router/handler-list the project uses.
5. **Client / consumer types** — mirror any shared contract on the consuming side.
6. **UI / caller** — the user-facing call and presentation.

Keep edits scoped. Do not rewrite unrelated code. Do not change a signature other callers depend on without updating all callers.

---

## Phase 4 — Verify

Run the project's own test and build/typecheck commands (find them in `CLAUDE.md` / `AGENTS.md`, the README, or the package/build manifest — e.g. `package.json` scripts, a `Makefile`, `Cargo.toml`). Both must pass:

- **Tests** — the unit/integration suite for the changed code.
- **Build / typecheck** — a clean compile or type-check with zero new errors.

If these commands are not available in the current environment, note it explicitly so the maintainer knows to run them locally before merging.

---

## Phase 5 — Commit & PR

Follow `{rulesDir}/workflow-rules.md` exactly:
- `git checkout -b <type>/<N>-<slug> origin/{baseBranch}` (must be on a feature branch — never commit directly to `{baseBranch}`)
- `git add <only the files you changed>`
- Commit with conventional format
- Push and open PR (`--base {baseBranch}`) with `Closes #N` in body

---

## Rules (always apply)

- Follow existing architecture — put new code where its siblings live, not wherever is convenient.
- Match the surrounding code's idioms, naming, and comment density.
- Respect the consuming project's own hard constraints — read its `CLAUDE.md` / `AGENTS.md` for required wrappers, forbidden imports, fixed API contracts, and similar rules before editing.
- Update docs (changelog, relevant `docs/` files) when behaviour or public APIs change.
- Mark open questions as TBD rather than silently deciding.
