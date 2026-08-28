---
name: document
description: Write and maintain a project's documentation INSIDE a running note-app workspace, through the noteapp MCP tools — create the doc tree, keep it updated on re-runs (keyed upserts, never duplicates), restructure and retire pages, and propose databases behind a confirm-first flow. Use when the user says "document this project in note-app", "update the docs in the app", "move these docs into note-app", or wants project documentation to live in the app instead of flat Markdown files.
---

# Document — project docs that live in note-app

## What this is

The playbook's skills write docs to files. This one writes them **into a running note-app workspace**, through the `noteapp` MCP tools — so the docs live where the user reads and edits them, and a re-run **updates** what it wrote instead of duplicating it.

⚠️ **The app must be OPEN.** Reads are answered by the running app and writes are applied by it (the app holds the key; the MCP process never does). Every tool says this in its own words when the app is closed — relay that, never retry silently.

## Preconditions — check, and say plainly when they fail

1. **The tools exist**: `mcp__noteapp__list_spaces` (and, for writing, `create_page`). Absent tools mean the server was registered without `--allow-write`, or not registered at all — the owner fixes both from note-app's **Settings → MCP server** (it generates the exact command). A server registered mid-session needs a fresh session.
2. **Something is shared**: `list_spaces` returning *"Nothing in this workspace has been shared with assistants yet"* means the owner has not granted access. Writing needs **Can edit** reaching the destination space. Report it; do not work around it.
3. Every refusal from these tools is written to be relayed — do that instead of paraphrasing.

## The addressing contract (never skip)

Every page this skill creates carries an **`external_key`**: `repo:<repo-name>/docs#<stable-slug>` — e.g. `repo:my-app/docs#root`, `repo:my-app/docs#architecture`. The key is what makes a re-run an UPDATE (`created: false` in the receipt) instead of a duplicate; two live pages with one key refuse loudly, and that refusal goes to the user, never resolved by guessing.

- **Slug = the doc's identity, not its title.** Titles may change on upsert (the key licenses the rename); slugs never do.
- **Read before you write.** Fetch the page (`read_page`) immediately before computing a replacement — v1 upserts REPLACE the body, and the before-state's recoverability lives in version history, not in your memory.

## Steps

### 1. Map the destination

`list_spaces` → pick the space the user names (ask once if ambiguous). First run in an empty space: `create_page` with `space_id` roots the tree. After one successful create, the destination is remembered for the session — later calls may omit it.

### 2. Author the tree

- One **root page** (`…#root`) — what the project is, and a short map of the subpages.
- **Subpages by topic**, not by source file: Overview / Architecture / Guides / Status are a good default; follow the project's own structure when it has one. Markdown becomes real blocks — headings, lists, `- [ ]` checklists, tables, quotes, fenced code.
- **Curate, don't dump.** A page a person will read beats a mirror of the repo. Link to the repo for exhaustive references.

### 3. Keep it true on re-runs

- Changed source → `create_page` with the same `external_key` (upsert) or `append_to_page` for additions.
- Moved/renamed source → `rename_page` / `move_page` (same-space moves; the tools name every refused shape).
- Retired source → `trash_page` — recoverable by the owner; nothing is ever hard-deleted from here.
- `list_pages` returns each page's `external_key` — that is your inventory for diffing against the source.

### 4. Databases — propose → confirm → create (the owner's flow, verbatim)

When the docs need a database (a feature matrix, a decision log, a tracker): **show the user the structure first** — property names, types, option sets, view layouts — and get their yes, unless they already specified it exactly. Then `create_database` (all eight view layouts; `list_databases` shows what exists), `create_row` with values by property NAME and option LABELS, `update_row` for changes. An unknown property or option is refused, never created — schema definitions are the owner's. Give database rows keys too (`gitea:<repo>#<n>` for issue mirrors, `repo:<name>/docs#<slug>` for doc rows).

### 5. Report

End with: the tree you wrote (titles + keys), what a re-run will update, and anything refused — with the tool's own sentence.

## Worked example

note-app's own workspace: a `Note App Docs` tree (root + Overview / Architecture / Working with agents / Status & Roadmap, keys `repo:note-app/docs#…`) authored and maintained this way, plus a `Note App Tracker` database created through the confirm flow with issue rows keyed `gitea:note-app#<n>` — re-runs update both in place.

## Boundaries

- **This is the supported agent surface** (note-app #549/#518) — not `agent-write.mjs`, not the CRDT log, not a future HTTP API.
- No hard deletion, no schema edits beyond what the tools offer (`delete_option` exists; add/rename/retype are the owner's, in the app).
- When a workspace is unreachable, say so and stop — never fall back to writing files and calling it done.
