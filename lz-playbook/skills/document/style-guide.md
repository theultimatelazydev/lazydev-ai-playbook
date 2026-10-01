# Documentation Style Guide

*The shape every page of a product wiki follows, and why.*

How to write a product's **user documentation** — the wiki a person opens to learn the app, not the engineering notes behind it. The shape was proven on a ~70-page product wiki and is written to be reused as-is in any project.

> [!NOTE]
> **This is a style guide, not a tool guide.** Every rule below is about what a page says and how it is laid out. Where the tool matters, the Noltez block that implements it is named (Noltez is the canonical home for docs; it also exports them as web pages). The last section maps the original MkDocs Material syntax onto Noltez, for migrating an existing site.

## Principles

1. **Answer the reader's question, in the order they ask it.** *What is this? Do I need it? How do I use it? What can't it do? Where next?* Every page follows that order, which is why every page has the same sections.
2. **Define, then show a real example.** A concept gets one sentence of definition and then two or three **real, named** examples a reader recognizes — never `foo`, `Example Pack` or `My Item`. Real names make an abstract noun concrete in one read.
3. **Say what does NOT happen.** Readers fear the destructive case most — "will this delete my files?", "will this send my data anywhere?" Answer it on the page, bolded, before they have to ask.
4. **Limitations are content, not an apology.** Every feature page ends with what it cannot do, stated plainly. A limitation a reader discovers on their own costs more trust than the one you told them about.
5. **Document what ships.** A planned feature written up as if it exists is the fastest way to lose a reader. Planned work is either left out or labeled *planned* in its first sentence.
6. **No stub pages.** A page with nothing to say yet does not exist. A nav full of three-line placeholders is worse than a shorter nav.
7. **Every literal is checked against the product.** A button label, menu path, setting name, file name or folder a reader will follow is read from the app (or its code) before it is written, never from memory or from an older doc.
8. **One language variant, everywhere.** Pick one (e.g. US English) and hold it across prose, UI strings and code comments.

## Site shape

Ordered by what a **new** user needs first, not alphabetically:

| Section | Holds | Notes |
|---|---|---|
| Introduction | What the product is, who it is for, the one-paragraph pitch | The root page |
| Getting started | Install, first run, first useful result | Short. Ends with the reader having done one real thing |
| Core areas | One section per thing the product manages — each with an **Overview** landing page and one page per concept | The bulk of the wiki |
| Tools / integrations | Secondary capabilities | Only once the core areas exist |
| Reference | Exhaustive tables: supported formats, shortcuts, settings, data locations | Look-up, not reading |
| Troubleshooting | Symptoms → causes → fixes | See § Troubleshooting pages |
| About | FAQ, Glossary, License and credits | Glossary terms match the product's UI exactly |

**A section's first page is its Overview** — a short introduction and a map of the pages under it. In Noltez the section is a parent page and its children are the subpages.

## Page anatomy

Every concept page uses these sections, in this order. Drop a section the concept genuinely does not have; never reorder them.

| Part | What it is | Notes |
|---|---|---|
| Title | The concept's name, as the UI spells it | Plural for things you have many of (*Packs*), singular for a single thing (*Dashboard*) |
| Summary line | One sentence: what the page answers | First paragraph, in *italics*. It doubles as the page's description in search and in the web export |
| Definition | "A **pack** is a thing you acquired." + 2–3 real examples | The concept word in **bold** the first time |
| `## Overview` | How it comes to exist and how it behaves, with a small worked example | A folder tree or a before/after is worth a paragraph |
| `## Metadata` | A table of the fields it carries | Exact format below |
| `## Creating, managing and deleting` | The tasks, as steps | Numbered lists for sequences, one action per step |
| Topic sections | Anything specific to this concept | Named for the reader's question ("Which one do I want?"), not the implementation ("Resolver logic") |
| `## Limitations` | What it cannot do | Exact format below |
| `## Next steps` | 2–4 links onward | Exact format below |

### The Metadata table

Always these four columns, in this order:

| Field | Type | Description | Notes |
|---|---|---|---|
| Name | Text | What it is called. Detected automatically, editable at any time. | Clearing it resets to the detected name |
| Author URL | Link | The author's site or store page. | - |

- **Field** — the label as the UI shows it.
- **Type** — the reader's type, not the database's: *Text, Link, Number, Date, Choice, Reference, Toggle*.
- **Description** — what the field was designed for and how it is used.
- **Notes** — a limitation, an inheritance rule, a default. **`-` when empty** — never blank, so an empty cell reads as "checked, nothing to add" rather than "forgotten".
- Internal bookkeeping fields are left out, and the sentence before the table says so: *"The fields a pack carries. Anything not listed here is internal bookkeeping."*

### Limitations

A bullet list. Each item opens with **one bold sentence that states the limitation**, followed by the reason or the workaround:

- **A pack belongs to one bundle at a time.** If you bought the same pack twice, that is two packs with the same content, linked as siblings.
- **Tiers are labels, not rules.** Putting a pack in a tier records where it came from; it does not change what the pack permits.

### Next steps

2–4 bullets: a **linked page name in bold**, an em dash, and *why* the reader would go there — a reason, not a description of the page.

- **Bundles** — the deal a pack came in.
- **Licenses** — what a pack permits.

In Noltez each link is a page **mention**, so it follows renames.

## Components

### Callouts

Four kinds, each with one job. A callout opens with a **bold first line that states its point as a full sentence** — a reader skimming only the bold lines should still get the message.

| Kind | Noltez | Use it for |
|---|---|---|
| Tip | `> [!TIP]` | A shortcut, or the fix for the most common surprise |
| Note | `> [!NOTE]` | Context worth knowing that would interrupt the paragraph |
| Warning | `> [!WARNING]` | Something that goes wrong if ignored, but recoverably |
| Danger | `> [!DANGER]` | Data loss, corruption, or anything irreversible |
| Screenshot placeholder | `> [!CALLOUT]` (no color), first line **Screenshot: …** | An image still to be taken — see below |

> [!TIP]
> **If a bundle came out as one giant pack, the folder layout was not recognized.** The app could not tell where one pack ended and the next began. You can describe your own layout — see Sources.

Use them sparingly: more than two on a screen and they stop being noticed. **Danger** is reserved for the irreversible — overuse trains readers to skip it.

### Screenshot placeholders

A screenshot that does not exist yet is written as a placeholder that **specifies the shot**, so whoever takes it needs no other context:

> [!CALLOUT]
> **Screenshot: a pack page, with real metadata filled in.** Cover art, name, author, source and license visible together. Use a well-known pack, not a bare auto-detected one.

State **what is on screen**, **which state** (empty, populated, an error) and **which data** to use. Every placeholder starts with the word **Screenshot:**, so searching for it lists every shot still missing. (A custom tag such as `[!SCREENSHOT]` does not work for this: Noltez keeps any unknown tag only as a plain, uncolored callout and drops the tag name, so it can't be searched for.) Replace each with the image when it is taken; a published page should have none left.

### Collapsible questions and symptoms

Questions and troubleshooting entries are **collapsed** — the reader scans the headings and opens the one that is theirs. In Noltez, a **toggle list** (a bullet with nested bullets under it).

- **The question or symptom, in the reader's own words, as the toggle.** "Does it move, rename or change my files?" — not "File-system side effects".
- **The answer opens with the verdict in bold**: **No — not unless you ask it to.** Then one or two sentences of why, then a link.

### Tables

- **Reference tables** (formats, shortcuts, settings) use a ✓ / — vocabulary and a final **Notes** column; never leave a cell blank.
- **Comparison tables** end with a "Choose it when" column — the reason a table exists is to help someone pick.
- A table that readers will want to **filter or sort** (dozens of rows, several categories) becomes a Noltez **database** with saved views instead.

### Code, trees and diagrams

- A **folder tree** or a file sample goes in a fenced code block — the fastest way to show "given this layout, you get this".
- Commands are one per block, copy-pasteable, no `$` prompt.
- Diagrams are Mermaid in a fenced block (Noltez renders it), or an Excalidraw page when the drawing is free-form.

## Special pages

### Troubleshooting

- Grouped by **when it happens** (`## Starting up`, `## Scanning`, `## Exporting`), not by internal component.
- Each entry is a collapsed symptom in the reader's words. The answer gives **the likely cause first**, then the fix, then a link to the page that explains more.
- When there are several causes, list them **in the order worth checking**.
- The page opens with one line: *"Find the symptom, click it."*

### FAQ

The questions people actually ask, collapsed, verdict first. Safety questions ("Is there anything that deletes my files?") go at the top.

### Glossary

One entry per term the UI uses, **spelled exactly as the UI spells it**, each with a one-sentence definition and a mention of the page that covers it. When a term changes in the product, the glossary changes in the same change.

## Voice

- **Second person, present tense, active**: "You get two packs", not "Two packs will be generated for the user".
- **Short sentences.** One idea each. A paragraph is three to five lines.
- **Name things the way the UI does**, in the UI's capitalization. Bold a UI label the first time it is an instruction: *open **Settings → Library***.
- **Italicize real product and item names** used as examples: *Polygon Fantasy Kingdom*, *Kenney UI Pack*.
- **No hedging filler** — *simply*, *just*, *easily*, *obviously*. If it were simple the reader would not be here.
- **Be concrete about cost**: "About ten seconds, once" beats "a quick step".
- **Say why**, briefly, when a rule would otherwise look arbitrary: *"Internal folder names like those are never promoted, because a pack is a thing you bought, not a folder that happens to exist."*

## Before publishing a page

- [ ] Summary line present, and it answers a question
- [ ] Definition uses real, named examples
- [ ] Every UI label, path and setting name checked against the product
- [ ] Metadata table has four columns and no blank cells
- [ ] Limitations stated; nothing planned written as shipped
- [ ] Next steps link onward with a reason each
- [ ] No screenshot placeholders left on a page being published
- [ ] Glossary updated if a term was added or renamed

## Migrating from MkDocs Material

| MkDocs Material | Noltez |
|---|---|
| `description:` front matter | The italic summary line under the title |
| `nav:` in `mkdocs.yml` | The page tree — a section is a parent page, subpages are its children, in reading order |
| `!!! tip "Title"` (also `note`, `warning`, `danger`) | `> [!TIP]` with the title as the **bold first line** |
| `!!! abstract "[Insert screenshot: …]"` | `> [!CALLOUT]` whose first line is **Screenshot: …** |
| `??? question "…"` / `??? failure "…"` | A toggle list: the question as the toggle, the answer nested |
| A link to `other-page.md` | A page mention, which survives renames |
| `:material-check:` icons in tables | ✓ and — as plain characters |
| A long reference table | A database with saved views, when it needs filtering |
| Versioned docs (mike) | Not carried over — publish the current version; record changes in the changelog |
| `--strict` link validation | Mentions cannot dangle; a mention to a missing page is refused when written |

---

Source of truth: `lz-playbook/skills/document/style-guide.md` in the lazydev-ai-playbook repo. Edit there; this page is re-synced by the `document` skill under the key `repo:lazydev-ai-toolkit/docs#docs-style-guide`.
