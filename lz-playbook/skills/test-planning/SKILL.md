# Skill: Test Planning

Create a test plan for the feature or subsystem under change. Cover each of the project's affected areas — e.g. its core data/import pipeline, generation/processing steps, editing flows, search/filter, grouping, error and missing-data handling, and any external-source or licensing logic. Adapt the list to the host project's actual domains rather than assuming a fixed set.

Include:
- Unit tests
- Integration tests
- Manual test cases
- Edge cases

**When you present the plan as a list of cases**, render it as a table per `workflow-rules.md` § Work listing format — only the columns the project can fill. A criterion that describes something a **person** does is met when a person, or a test driving the real interface, has done it — not by a unit test alone; and verify each case in the environment where it can fail (see `workflow-rules.md` § Marking unmet acceptance criteria).
