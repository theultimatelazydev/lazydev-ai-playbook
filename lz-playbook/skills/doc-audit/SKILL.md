# Skill: Documentation Audit

## Project config

Read optional per-project overrides from `.lz-playbook.json` at the repo root. Keys (defaults): `rulesDir` (`.ai/rules`). If the file is absent, use the default. Below, `{rulesDir}` means this resolved value.

## Suggested Path

```text
.ai/skills/doc-audit/SKILL.md
```

---

## Purpose

Run a full documentation audit and update for the project.

This is the primary entry point for the **Documentation Specialist** agent.

Use this skill when documentation needs to be reviewed, updated, standardized, or checked against the current implementation state.

---

## When to Use

Use this skill:

* After major implementation changes
* After adding or changing core systems
* After changing architecture, metadata, database schema, or product behavior
* Before moving documentation to another system, such as Docmost
* When docs feel outdated, duplicated, incomplete, or inconsistent
* When preparing a session handoff
* When the user asks what documentation is missing or stale

---

## Required Agent

Invoke or behave as:

```text
Documentation Specialist Agent
```

Suggested agent path:

```text
.ai/agents/documentation-specialist.md
```

---

## Inputs

Expected inputs may include:

* A specific documentation folder
* A specific feature or system
* A GitHub Issue number
* A recent implementation summary
* A handoff file
* The full repository context

If no scope is provided, default to:

```text
docs/
{rulesDir}/
AGENTS.md
CLAUDE.md
```

---

## Instructions

### 1. Review Existing Documentation

Scan the relevant documentation scope and identify:

* Missing docs
* Outdated docs
* Incomplete docs
* Duplicate docs
* Conflicting definitions
* Missing Document Status blocks
* Missing Open Questions sections
* Docs that no longer match implementation
* Docs that should link to related docs or issues

---

### 2. Check Implementation When Needed

When implementation status matters, inspect the relevant code before marking a document as implemented.

If implementation status is uncertain:

* Mark `Implemented` as ⚠️
* Add a note explaining why
* Add an Open Question when human confirmation is needed

Do not guess implementation status.

---

### 3. Update Document Status Blocks

Every important document should have this near the top:

```md
## Document Status

- **Defined:** ✅ / ⚠️ / ❌
- **Implemented:** ✅ / ⚠️ / ❌
- **Needs Review:** ✅ / ⚠️ / ❌
- **Last Updated:** YYYY-MM-DD
- **Updated By:** Documentation Specialist / Claude / Cursor / ChatGPT / Maintainer / Other
- **Source of Truth:** Repo / GitHub Issues / Code / Mixed
```

Use:

* ✅ for complete
* ⚠️ for partial, uncertain, or needs validation
* ❌ for missing or not done

---

### 4. Update Existing Docs

Prefer updating existing docs over creating new docs.

For each updated document:

* Improve clarity
* Remove ambiguity
* Preserve useful existing information
* Add missing sections only when useful
* Update status block
* Update Last Updated
* Update Updated By
* Add Open Questions if needed
* Add Related Docs / Issues if useful

---

### 5. Create Missing Docs

Create new docs only when the topic is important and clearly deserves its own page.

Ensure the project's core domain/metadata docs exist when relevant. For example, an asset-manager-style project might expect docs such as:

```text
docs/02-domain-model/asset-type-definitions.md   (semantic types; shipped)
docs/02-domain-model/source-system.md            (shipped `assets.source` vs planned normalization)
docs/02-domain-model/sources-and-stores.md       (source / store vision)
docs/02-domain-model/license-system.md           (shipped multi-row licenses)
docs/02-domain-model/licenses.md                 (license product intent + questions)
docs/02-domain-model/metadata-model.md           (draft + principles)
docs/02-domain-model/collections-and-grouping.md (manual vs smart vocabulary)
```

Adapt the expected set to the host project's domain. When creating a new doc, suggest the final path clearly.

---

### 6. Apply Standard Document Structure

When creating or significantly rewriting a document, use this structure unless a smaller structure is clearly better:

```md
# Document Title

## Document Status

- **Defined:** ❌
- **Implemented:** ❌
- **Needs Review:** ✅
- **Last Updated:** YYYY-MM-DD
- **Updated By:** Documentation Specialist
- **Source of Truth:** Repo

## Overview

## Problem / Context

## Goals

## Non-Goals

## Current Behavior

## Proposed / Defined Behavior

## Data Model / Technical Notes

## UI / UX Notes

## Acceptance Criteria

- [ ] Item

## Open Questions

- Question

## Related Docs / Issues

- GitHub Issue: #...
- Related docs:
```

---

### 7. Update Documentation Rules

Check and update documentation-related rules when needed.

Likely files:

```text
{rulesDir}/documentation-rules.md
{rulesDir}/workflow-rules.md
{rulesDir}/project-rules.md
AGENTS.md
CLAUDE.md
```

Rules should enforce that when agents modify or define:

* Architecture
* Data models
* Database schema
* Metadata systems
* Product behavior
* Major UI behavior
* Import/export behavior
* AI workflow
* Project rules

They must update the related docs and status blocks.

---

### 8. Prevent Duplication

Before creating a new document:

1. Search existing docs for the topic.
2. Prefer extending or refactoring the existing doc.
3. Only create a new file if the topic deserves separation.
4. Link related docs together.

---

### 9. Report Results

At the end, provide a clear report.

Use this format:

```md
## Documentation Audit Report

### Updated Files

- path/to/file.md — summary of changes

### Created Files

- path/to/new-file.md — purpose

### Docs Needing Review

- path/to/file.md — reason

### Missing or Suggested Docs

- path/to/suggested-file.md — reason

### Rules Updated

- path/to/rule.md — summary

### Open Questions

- Question

### Suggested Next Steps

1. Step
2. Step
3. Step
```

---

## Constraints

* Do not commit.
* Do not push.
* Do not delete documentation without explanation.
* Do not silently overwrite important decisions.
* Do not create duplicate docs for the same concept.
* Prefer updating existing docs before creating new ones.
* Mark uncertainty with ⚠️ instead of guessing.
* Keep Markdown readable and easy to scan.
* Keep implementation docs close to the current code behavior.

---

## Recommended Invocation

```text
Run the doc-audit skill using the Documentation Specialist agent.
Review the docs folder and AI rules, add or update Document Status blocks, create missing core metadata docs if needed, and update rules so future implementation changes also update docs.
Do not commit or push.
```

---

## Focus Areas

Pay special attention to the host project's core domains. For an asset-manager-style project, that means:

* Asset type definitions
* Source system
* License system
* Metadata model
* Collections and grouping
* Smart collections
* Import pipeline
* Local database/storage
* UI/UX behavior
* AI workflow and handoff rules
* GitHub Issues alignment

---

## Success Criteria

This skill is successful when:

* Important docs have status blocks.
* Core metadata docs exist or are explicitly marked missing.
* Outdated docs are updated or flagged.
* Unclear implementation status is marked with ⚠️.
* Documentation rules require future agents to keep docs updated.
* The final report clearly explains what changed and what still needs review.
