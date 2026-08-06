---
name: vault
description: Search, read, and capture notes in the Obsidian second-brain vault at $OBSIDIAN_VAULT. Use when the task needs prior context (a project, acronym, past decision, meeting, or person you don't recognize from the repo), or when something worth keeping was just discovered, such as a tool evaluation, a troubleshooting pattern, an architecture decision, or a project insight. Covers the PARA layout, frontmatter and tag conventions, note templates, the insight pipeline, and which paths are read-only.
---

# Obsidian vault

A collaborative second brain spanning 2022–present. Project history, meeting
records, people, and reusable technical knowledge that is not in training data.

The vault is **a normal directory on every machine**: Obsidian Sync replicates
it. Use `Grep`, `Glob`, and `Read` directly. There is no MCP server, and none is
needed.

Always reference it as **`$OBSIDIAN_VAULT`**. The path differs per machine
(macOS, WSL2, Git Bash, HPC); the variable is the portability seam.

> If `$OBSIDIAN_VAULT` is empty or a command errors with a literal `~` in the
> path, the variable is unset or was stored unexpanded: `~` does not expand
> when it comes from a variable. Fall back to `$HOME/repos/obsidian` and fix
> `env.OBSIDIAN_VAULT` in settings.json.

## Layout

```text
$OBSIDIAN_VAULT/
├── Home.md · Dashboard*.md      # navigation hubs
├── projects/
│   ├── work/{org}/               # per-project: MOC, context/, meetings/
│   ├── personal/                # per-project subdirectories
│   └── academic/
├── knowledge/                   # reusable, four domains:
│   ├── remote-sensing/  ai-ml/  infrastructure/  development/
├── journal/YYYY/MM - MMM/YYYY-MM-DD.md
├── people/@First Last.md
├── templates/                   # Templater syntax, substitute values manually
└── docs/                        # vault-maintenance.md, vault-history.md
```

## Search before creating

Duplicates are the main failure mode. Always look first.

```bash
rg -il "{topic}" "$OBSIDIAN_VAULT" --glob '*.md'             # filename + content
rg -l "^type: knowledge" "$OBSIDIAN_VAULT/knowledge"        # by frontmatter
rg -o 'tags:.*topic/[a-z-]+' "$OBSIDIAN_VAULT" -r '$0'      # by tag
```

Then navigate: `Home.md` → MOC → note. Or follow `## Related Knowledge` sections
in adjacent notes. Prefer appending to an existing note over creating a near-duplicate.

## Where to save

```text
Reusable across projects?
├─ YES → knowledge/{remote-sensing|ai-ml|infrastructure|development}/
└─ NO  → projects/{work|personal|academic}/{org}/{project}/context/
```

Day-to-day observations go in the current daily note's `## Insights` section,
tagged `#insight`, not straight into `knowledge/`.

| Content | Goes to |
|---|---|
| A domain algorithm or technique evaluation | `knowledge/remote-sensing/` |
| Python dependency management comparison | `knowledge/development/tools/` |
| A specific project's sprint plan | `projects/work/{org}/{project}/context/` |

## What is worth capturing

Capture proactively; the value compounds:

- **Research findings**: tool and library evaluations, comparisons. Not basic usage.
- **Troubleshooting patterns**: reusable fixes. Not one-off project bugs.
- **Technical decisions**: architecture and design choices, *with the reasoning*. Not routine implementation.
- **Project insights**: discoveries during the work. Not attendance or status updates.

## Frontmatter

Knowledge:
```yaml
---
type: knowledge
tags: [domain/remote-sensing, topic/{topic}, technique/{technique}]
aliases: [alternate name, another alternate name]
---
```

Project context: `type: context` + `tags: [org/{org}/{project}]`

Meeting: `type: meeting`, `date: YYYY-MM-DD`, `tags: [org/…, meeting/…]`,
and `prev: "[[YYYY-MM-DD]]"` for recurring series; chronology depends on it.

`type:` values in use: `journal`, `meeting`, `person`, `knowledge`, `moc`,
`context`, `documentation`, `dashboard`.

### Tags

| Prefix | Purpose |
|---|---|
| `domain/` | ai-ml, remote-sensing, infrastructure, development |
| `topic/` | specific technology |
| `technique/` | methodology |
| `org/{org}/{project}` | organizational |
| `meeting/` | meeting type |

Single domain tag when clear, multiple only when genuinely cross-domain. Never
duplicate parent tags (`org/{org}/{project}` alone, not both it and `org/{org}`);
Obsidian's hierarchical search already finds nested tags. Tag technical content
only; skip for administrative notes. Typical: 0–2 domain, 0–3 topic, 0–2 technique.

Use the frontmatter `status:` field, never a status tag.

## Naming and linking

- Knowledge: `Topic Name.md` · Meeting: `YYYY-MM-DD.md` · Person: `@First Last.md`
- `[[Note Title]]` for internal links; `[[@First Last]]` for people, which
  auto-creates the person note and backlink
- Knowledge notes **require** a `## Related Knowledge` section; context notes
  should have one
- Link to the relevant MOC at the bottom

**Attachments are not in the vault.** PDFs and images live in Google Drive and
are referenced as markdown links, not wikilinks:
`[Paper Name.pdf](https://drive.google.com/file/d/<id>/view)`. Never write
`[[something.pdf]]`; nothing will resolve. Reachable everywhere via the Drive
connector.

**Personal Google Docs belong in the vault too**, not just reusable
technical/project knowledge. The vault is meant to be a first-class,
queryable record of the user's own history: letters, resumes, application
essays, hobby guides, and one-off correspondence all migrate. Lack of
*current* utility is not a reason to exclude something; it may matter for a
future connection. The only real exclusions are genuinely unmigratable
documents: content not owned by the user (a doc that lives in someone
else's Google account, merely shared), or a format that would degrade as
markdown (encoded/binary blobs, spreadsheets). Checked 2026-08-05: the Drive
Google Docs corpus (42 files) was inventoried against this rule; 37 migrated
into new `projects/personal/{project}/context/` folders (college-applications,
career, speedcubing, early-programming, dnd-characters, correspondence,
travel), 2 were dropped entirely at the user's request (encoded game-save
blobs with no readable content), and 3 stayed in Drive as not owned by the
user. Judge a new document against the rule above when it comes up.

## Capture workflow

1. Decide the type: reusable, project-specific, or a daily insight
2. **Search** for an existing note; append rather than duplicate
3. Read the matching `templates/` file (Knowledge Note, Research Findings,
   Troubleshooting Pattern, Project Context, Meeting Note) and substitute the
   Templater `<% tp.* %>` placeholders with real values
4. Write frontmatter, body, `## Related Knowledge`, MOC link
5. **Tell the user what was captured and the filepath**

### Insight pipeline

Daily fleeting note → insight → knowledge note.

Capture in the daily note under `## Insights` with `#insight`. Review weekly via
the Dashboard. Promote anything durable into `knowledge/{domain}/`, link back to
the originating daily note, then remove the `#insight` tag.

## Write scope

Read and write anywhere in the vault, including `templates/`, `docs/`,
`Home.md`, `Dashboard*.md`, MOC files, and `.obsidian/`. Project MOCs follow
the `templates/Project MOC.md` pattern (see an existing one, e.g.
`projects/personal/isotope/MOC - Isotope.md`, before writing a new one).
`Home.md`, `Dashboard*.md`, and the top-level aggregator MOCs
(`MOC - All Projects.md`, `MOC - Currently Active.md`) are Dataview-driven
and hand-tuned; take more care there; a bad edit breaks the query for the
whole vault. `.obsidian/` holds Obsidian's own app/plugin config, not vault
content, edit only when a task specifically calls for it.

## Pitfalls

- Don't invent tags without checking the existing hierarchy
- Don't hand-edit MOC dataview output; fix the source note's frontmatter
- Don't omit `prev:` on recurring meetings
- Don't mix project context with reusable knowledge
- Don't reintroduce `[[file.pdf]]` attachment links

## Filesystem vs. the remote connector

Claude Code reaches the vault via the filesystem, not the remote `vault` MCP
connector: zero tool-schema cost, and it's what everything above assumes.
Desktop, mobile, and claude.ai web have no filesystem, so they use the
connector instead; it reaches the same vault, but through a narrower,
audit-logged surface.

The connector has capabilities the filesystem doesn't: Excalidraw canvas
editing, batch frontmatter updates across many files in one call,
frontmatter-indexed search, the built-in vault-analytics checks (broken
wikilinks, missing frontmatter, suspicious tag variants), daily-note path
resolution against the vault's own naming convention, and binary
(image/PDF) writes. If a task genuinely needs one of those from Claude Code,
rare since `git`/`rg`/cross-repo work only exist on the filesystem side,
reach for the connector rather than reimplementing it by hand.

## Sync

Obsidian Sync replicates the vault; the git repo is **archived** and read-only,
so don't commit or push from here. Sync retains 30 days of history: treat
deletions as effectively permanent after that, and prefer archiving a note over
deleting it.
