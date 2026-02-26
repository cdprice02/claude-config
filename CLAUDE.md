# CLAUDE.md — User-Level Configuration

This file provides global guidance to Claude Code across all of my projects.
Project-specific build commands, architecture maps, and release processes belong in per-repo CLAUDE.md files, not here.

## About Me

- **Role**: AI/ML Engineer at a government contractor
- **Focus areas**: Classification, anomaly detection, and data engineering
- **Primary language**: Python (data science, ML pipelines, ETL, automation)
- **Secondary languages**: Rust (performance-critical tooling, CLI utilities), Julia (numerical/scientific computing)
- **Values**: Organization, readability, and clarity — code should make sense to both AI and humans
- **Decision-making context**: When choosing between approaches, prefer solutions that are **explainable and auditable** — I often work in environments where model decisions and data lineage need to be defensible. Favor well-established, documented libraries over cutting-edge-but-unstable ones. When in doubt, choose the approach that is easier to read and reason about over the one that is marginally more performant.
- **Communication style**: Lead with code, follow with concise rationale. Skip preamble. If something is ambiguous, ask rather than assume.

## Core Principles

1. **Clarity First** - When uncertain about requirements, approach, or structure, ask rather than assume
2. **Explainable & Auditable** - Prefer solutions that are defensible and maintainable over marginally more performant ones
3. **Minimal Scope** - Do what is asked; avoid unnecessary scope creep or "improvements"
4. **Standards-Driven** - Query eros-codex before writing code; consistency matters

## Workflow Rules

### Tool Use (Highest Priority)

- **Dedicated tools over bash** - Use Read (not `cat`/`head`/`tail`), Glob (not `ls`/`find`), Grep (not `grep`/`rg`), Edit (not `sed`/`awk`), Write (not `echo >`/heredoc) for all file operations. Reserve Bash exclusively for system commands, git, package managers, build tools, and tests
- **Read before modify** - Always use Read tool before Edit/Write (use Read before Bash)
- **Separate tool calls over bash chaining** - Never bundle independent operations into a single bash call using `&&`, `;`, or pipes. Use `&&` only when a later bash command genuinely depends on the exit code of a prior one (e.g., `cd dir && make`). Use `||` only for genuine fallback chains. For independent steps — especially those that could use dedicated tools (Read, Glob, Grep) — use separate tool calls so each can be reviewed individually

### General

- **Edit over Write** - Prefer editing existing files over creating new ones
- **Code over prose** - Lead with code, follow with concise rationale if needed. Keep explanations concise.
- **No secrets** - Never commit credentials, API keys, .env files, or sensitive data
- **Markdown emphasis** - Use **bold**/_italic_ instead of ALL-CAPS for emphasis in comments, documentation, and generated text
- **Root-level configs** - Files like `pyproject.toml`, `Cargo.toml`, `Makefile`, `README.md` belong in project root — don't over-nest config files
- **Consult standards** - For organizational workflow standards, query `general/autonomous-decision-making.md` via eros-codex

## Workflow Priority

### Phase 1: Planning & Research (Before Writing Code)

**Always use these first when starting new work:**

1. **eros-codex** — Check organizational standards for the language/domain
2. **Obsidian** — Search knowledge base for related notes, past decisions, patterns
3. **LSP tools** — Navigate codebase, understand structure, check types
4. **context7** — Get version-specific library documentation and examples
5. **WebFetch** — External documentation (when context7/Obsidian don't have it)

### Phase 2: Implementation (During Code Work)

**File operations (prefer specialized tools over bash):**

1. **Read** — understand context first (prefer over `cat`, `head`, `tail`)
2. **Glob** — find files by pattern (prefer over `find`, `ls`)
3. **Grep** — search file contents (prefer over `grep`, `rg` commands)
4. **Edit** — modify existing files (prefer over `sed`, `awk`)
5. **Write** — create new files only when needed (prefer over `echo >`, `cat <<EOF`)

**Note:** Even when a workflow step mixes bash and file tool calls, prefer separate tool calls over consolidating into a single bash call (regardless of whether `&&`, `;`, or pipes would be used).

**Development tools:**

6. **LSP tools** — Go-to-definition, find references, inline docs, refactoring
7. **Bash** — system commands, git, package managers, build tools, tests

**Re-checking during implementation:**

- **eros-codex** / **Obsidian** / **context7** / **WebFetch** can be consulted again if you need to verify a pattern, standard, or API detail, but prefer doing thorough research in Phase 1

**Important**: Use specialized tools instead of bash commands for file operations. Reserve Bash exclusively for system commands and terminal operations that require shell execution.

## Plugin Usage & Standards Precedence

### eros-codex: Organizational Standards

Query `eros-codex:codex-agent` for organizational standards:

**How to query:**
- "List all Python standards" → Discover available guidelines
- "Get languages/python/guidelines" → Retrieve specific standard
- "Search for error handling" → Find standards by keyword

**Available standards:**
- **Languages:** Python, Rust, Go, JavaScript, TypeScript, Java, C, C++, Bash, Docker, Ansible, and more
  - `guidelines.md` — Idiomatic patterns, common pitfalls, performance
  - `code-development.md` — Design patterns, error handling, async/await
  - `code-documentation.md` — Docstrings, type hints, documentation style
  - `project-configuration.md` — Build tools, linting, testing, dependencies
- **General:**
  - `autonomous-decision-making.md` — Decision-making framework
  - `repository-management.md` — Git workflow, commits, branching

**When to use:**
- Starting new code? Check `languages/<lang>/guidelines.md`
- Setting up project? Check `languages/<lang>/project-configuration.md`
- Unsure about patterns? Check `languages/<lang>/code-development.md`
- Git workflow questions? Check `general/repository-management.md`

### LSP Tools: Language Standards & Navigation

**Currently Installed:**
- **pyright-lsp** (Python) — Type checking, navigation, refactoring, linting
- **rust-analyzer-lsp** (Rust) — Type checking, navigation, macro expansion, diagnostics

**LSPs provide:**
- **Type checking** — Catch errors before runtime
- **Code navigation** — Go-to-definition, find references, symbol search
- **Refactoring** — Rename symbols, extract functions, code actions
- **Current language standards** — LSPs track latest syntax (languages evolve faster than org standards)
- **Inline documentation** — Hover for API docs, function signatures

**Note:** Other LSPs available via `claude plugin install <name>` (TypeScript, Go, C/C++, Java, etc.)

### context7: Documentation Lookup

Use **context7** for:
- **Pulling version-specific documentation** from source repositories
- **Getting code examples** directly from library sources
- **Staying current** with API changes and best practices

**When to use:**
- Need docs for specific library versions (pandas 2.1.0 vs 2.2.0)
- Looking for canonical code examples from official repos
- Verifying API signatures and usage patterns

**Example queries:**
- "Get documentation for pandas DataFrame.merge"
- "Show examples of async/await in tokio"
- "What's the API for sklearn.ensemble.RandomForestClassifier in version 1.3?"

### Obsidian: Personal Knowledge Management

Use **Obsidian MCP** for:
- **Taking research notes** during codebase exploration
- **Documenting decisions** and architectural choices
- **Building a knowledge base** with linked notes across projects
- **Capturing insights** from experiments and investigations

**Status:** ✓ Configured (2026-02-19) via REST API plugin

**Setup reference:** https://github.com/MarkusPfundstein/mcp-obsidian

## Obsidian Knowledge Base Workflow

> **Availability:** The Obsidian MCP connects to the Obsidian Local REST API plugin at
> `http://localhost:27123`. On the Windows workstation this is direct. On remote/SSH machines,
> an SSH reverse tunnel forwards that port back to the Windows instance — Obsidian does not need
> to be installed on the remote machine. If Obsidian is unreachable (tunnel not active), skip
> Obsidian steps gracefully without treating their absence as an error.

**Vault structure:** Hybrid **PARA + Folders + MOCs** system (Projects, Archive, Resources, Areas)
- See `obsidian/CLAUDE.md` for comprehensive vault documentation
- Navigate via `Home.md` → MOCs (Maps of Content)

### When to Query Obsidian (Proactive)

**At project start** (before reading code):
1. Search for project name, technology stack, or domain concepts
2. Check for related research notes, past decisions, or known patterns
3. Surface relevant context to inform your approach

**When encountering unfamiliar concepts**:
- Before researching externally, query Obsidian for existing notes
- Check for past evaluations of libraries, frameworks, or patterns
- Look up troubleshooting patterns from similar issues

**Before making architectural decisions**:
- Search for related past decisions and their rationale
- Check if patterns/conventions already exist in knowledge base
- Review lessons learned from similar projects

**Query pattern**:
```
obsidian_simple_search(query="<technology/concept/pattern>")
obsidian_get_file_contents(filepath="<relevant note path>")
```

### Vault Organization

**Primary domains:**
- **projects/** — Work and academic projects (active and archived)
  - `projects/work/<employer>/<project>/` — Work projects organized by employer (KBR)
  - `projects/academic/<project>/` — Academic projects
  - Each project has: `MOC - ProjectName.md`, `context/`, `meetings/`
- **knowledge/** — Technical knowledge base across four domains:
  - `knowledge/remote-sensing/` — Satellite imagery, cloud detection (9 files)
  - `knowledge/ai-ml/` — ML algorithms, computer vision (2 files)
  - `knowledge/infrastructure/` — AWS, Azure, HPC, containerization (9 files)
  - `knowledge/development/` — Testing, frontend, backend, tools (17 files)
- **journal/** — Daily notes (`YYYY/MM - MMM/YYYY-MM-DD.md`) — 449+ entries
- **people/** — Person notes with @ prefix (`@First Last.md`)
- **templates/** — Note templates (Templater plugin)

### Frontmatter Standards

**Required fields:**
- `type:` — Note type (meeting, knowledge, context, moc, journal, person)
- `tags:` — Hierarchical tags (see Tag Hierarchy below)

**Conditional fields:**
- `date:` — Meetings and journals (YYYY-MM-DD format)
- `created-at:` — Project MOCs only (project start date)
- `status:` — Project MOCs only (active, archived)
- `archived-at:` — Archived project MOCs only (YYYY-MM-DD)
- `prev:` — Recurring meetings (link to previous: `"[[YYYY-MM-DD]]"`)
- `aliases:` — Knowledge files (alternative search terms)

**Example:**
```yaml
# Meeting note
---
type: meeting
date: 2026-02-23
tags:
  - org/kbr/lcnext
  - meeting/ai-tagup
prev: "[[2026-02-20]]"
---

# Knowledge file
---
type: knowledge
tags:
  - domain/remote-sensing
  - topic/cloudmasking
  - technique/deep-learning
aliases: [cloud masking, cloud detection]
---
```

### Tag Hierarchy

| Prefix | Purpose | Examples |
|--------|---------|----------|
| `domain/` | Knowledge domain | domain/remote-sensing, domain/ai-ml, domain/infrastructure, domain/development |
| `topic/` | Specific subject/technology | topic/cloudmasking, topic/wildfire, topic/python-versioning, topic/aws |
| `technique/` | Methodology/practice | technique/deep-learning, technique/testing, technique/environment-management |
| `org/` | Organization hierarchy | org/kbr, org/kbr/lcnext, org/kbr/wrfs, org/omnitech |
| `meeting/` | Meeting type | meeting/ai-tagup, meeting/tech-sync, meeting/1on1 |

**Important:**
- Status is frontmatter (`status: active`), not tags
- All work files include org tag — prefer nested tags like `org/kbr/lcnext` over the bare parent `org/kbr`
- Meeting tags are generic (`meeting/*` + project tags)
- No time-based tags (use `date:` field)

### What to Capture to Obsidian (Automatic During Work)

Capture the following automatically as you work:

**Research findings** (library/tool evaluations, technique comparisons):
- Location: `knowledge/<domain>/<subdomain>/<topic>.md`
- Template: `templates/Research Findings.md`
- Tags: `domain/<domain>`, `topic/<specific-topic>`, `technique/<technique>`
- Examples:
  - `knowledge/development/tools/uv-package-manager.md`
  - `knowledge/ai-ml/algorithms/random-forest-vs-xgboost.md`

**Generic troubleshooting patterns** (reusable across projects):
- Location: `knowledge/<domain>/<subdomain>/<problem-pattern>.md`
- Template: `templates/Troubleshooting Pattern.md`
- Tags: `domain/<domain>`, `topic/<problem-area>`, `technique/<technique>`
- Examples:
  - `knowledge/development/debugging/python-memory-leaks.md`
  - `knowledge/infrastructure/containerization/docker-networking-issues.md`

**Project-specific context** (decisions, insights, project-specific issues):
- Location: `projects/<work-or-academic>/<employer>/<project>/context/<topic>.md`
- Template: `templates/Project Context.md`
- Tags: Project tag (e.g., `kbr/lcnext`), org tag (e.g., `org/kbr`)
- Examples:
  - `projects/work/kbr/lcnext/context/architecture-decisions.md`
  - `projects/work/kbr/lcnext/context/deployment-troubleshooting.md`

### Capture Workflow

When you've completed research or made decisions:

1. **Determine note type**:
   - Is it reusable knowledge? → Knowledge Note in `knowledge/<domain>/`
   - Is it project-specific? → Project Context in `projects/<work|academic>/<employer>/<project>/context/`

2. **Check for existing note**:
   - Use `obsidian_simple_search` to search for related content
   - Use `obsidian_list_files_in_dir` to browse relevant directory

3. **Read template** to understand structure:
   - `templates/Research Findings.md` — Library/tool evaluations
   - `templates/Troubleshooting Pattern.md` — Reusable solutions with symptoms/cause/resolution
   - `templates/Knowledge Note.md` — Generic knowledge capture
   - `templates/Project Context.md` — Project decisions and context

4. **Structure content** following template:
   - Fill in frontmatter with appropriate fields
   - Use existing tag hierarchy: `domain/`, `topic/`, `technique/`, project tags
   - Link to related notes with `[[note-name]]`
   - For knowledge files: Include "## Related Knowledge" section with cross-references
   - Link to relevant MOC at bottom (e.g., `[[MOC - Remote Sensing]]`)

5. **Write to Obsidian**:
   - New note: Use `obsidian_append_content` (creates file if doesn't exist)
   - Append to existing: Use `obsidian_patch_content` (target specific heading)

6. **Announce capture**:
   - Tell user what was captured and where
   - Provide filepath for easy access

### Available Templates

Read from `templates/` folder before creating notes:

**General knowledge:**
- `templates/Knowledge Note.md` — Generic knowledge capture with domain/topic/technique tags
- `templates/Research Findings.md` — Library/tool evaluations with decision tracking
- `templates/Troubleshooting Pattern.md` — Reusable solutions with symptoms/cause/resolution

**Project-specific:**
- `templates/Meeting Note.md` — Standard meeting format with attendees, discussion, action items
- `templates/Project Context.md` — Project decisions, insights, and context

**Organizational:**
- `templates/Knowledge MOC.md` — Map of Content for knowledge domains
- `templates/Project MOC.md` — Project overview and navigation hub
- `templates/Daily Note.md` — Auto-created daily journal with frontmatter

**Note:** Templates use Templater syntax (`<% tp.* %>`). When creating notes programmatically, replace these with actual values.

### Best Practices

- **Query first**: Always search Obsidian before deep external research
- **Capture incrementally**: Don't wait until end of session; capture as you discover
- **Link liberally**: Connect notes with `[[WikiLinks]]` to build knowledge graph
- **Use person mentions**: Link people with `[[@First Last]]` syntax
- **Be concise**: Capture insights, not transcripts
- **Use consistent paths**: Follow the location patterns above
- **Preserve MOC structure**: Don't manually edit dataview query results — update source file frontmatter
- **Maintain chronology**: For recurring meetings, use `prev:` field to link to previous meeting

### Precedence When Conflicts Arise

1. **eros-codex organizational standards** (highest priority for USGS EROS code)
   - Example: Commit format, branch naming, error handling patterns, docstring style
2. **LSP language standards** (authoritative for up-to-date language features)
   - Example: Latest Python/Rust syntax, type system features, standard library APIs
3. **Language community conventions** (fallback when above are silent)
   - Example: PEP 8, Rust book, BlueStyle (Julia)

**Note:** All language-specific preferences have been removed from this file to ensure organizational consistency and reduce maintenance burden. Trust eros-codex and LSP tools as sources of truth.

## Data Science Conventions

- Separate data loading, transformation, and analysis into distinct steps/functions
- **Never** hardcode file paths — use arguments, config, or environment variables
- Intermediate results should be inspectable (return DataFrames, dicts, or named tuples — not print statements)
- For notebooks: keep cells focused; one logical step per cell
- Prefer reproducible pipelines over ad-hoc scripts when the workflow will be reused
- When appropriate, add lightweight validation (shape checks, null counts, dtype assertions) rather than full test suites
- For ML work: track experiments, log hyperparameters, and version datasets. Prefer deterministic seeds for reproducibility.

## Swarm & Multi-Agent Orchestration

When I request complex tasks that benefit from parallelism, use sub-agents effectively:

### Concurrency Principles

- Batch related operations into a single message — **"1 message = all related operations"** (i.e., multiple parallel tool calls in one response — not bash chaining with `&&`)
- Use the **Task tool** to spawn sub-agents for independent workstreams
- Give each sub-agent a clear, self-contained objective with all necessary context
- Don't poll or check status repeatedly after spawning — wait for results

### When to Use Sub-Agents

- **Data pipelines**: Separate agents for data ingestion, transformation, validation, and analysis
- **Multi-language projects**: One agent per language boundary (e.g., Python bindings + Rust core)
- **Research tasks**: Parallel investigation of different approaches or libraries
- **Large refactors**: Split by module or functional area

### Agent Coordination Patterns

| Pattern | Use When |
|---------|----------|
| **Mesh** | Embarrassingly parallel tasks — data exploration, independent analyses, parallel file processing |
| **Hierarchical** | Multi-step pipelines requiring sequenced stages — ETL workflows, staged model training, coordinated refactors |

### Example: Spawning a Data Pipeline Swarm

```python
# Spawn all agents in ONE message:
Task("Data Loader", "Read and validate the raw CSV files in data/raw/, report schema and row counts")
Task("Feature Engineer", "Given the validated data, compute features X, Y, Z and save to data/processed/")
Task("Model Trainer", "Train model on processed features, output metrics to results/")
Task("Report Generator", "Summarize metrics into a markdown report in docs/")
```

## File Organization Guidance

**Organizational standards:** Query `eros-codex:codex-agent`:
- `general/repository-management.md` — Repository structure, file management
- `languages/<lang>/project-configuration.md` — Language-specific project layouts

**Personal defaults** (override per-project as needed):

| Directory | Contents |
|-----------|----------|
| `src/` | **All source code** (the project directory name provides the package name) |
| `notebooks/` | Jupyter notebooks |
| `data/` | Raw and processed data (gitignored as appropriate) |
| `tests/` | Test files |
| `scripts/` | One-off or utility scripts |
| `docs/` | Documentation |
| `config/` | Configuration files (YAML, TOML, etc.) |

Root-level files like `pyproject.toml`, `Cargo.toml`, `Makefile`, `justfile`, `README.md`, `.gitignore`, and `CLAUDE.md` are expected in the root.

**Important**: Always use `src/` for source code. Do not name the source directory after the package — the project directory itself provides that identity. Language-conventional alternatives like `lib/` (Rust crates, Julia packages) or `app/` (application entry points) are acceptable when they follow the language's standard layout.

## Git Conventions

**Organizational standards:** Query `eros-codex:codex-agent`:
- `general/repository-management.md` — Commit messages (conventional format), branch naming, merge requests, workflow

**Follow organizational standards completely** — no personal overrides. All team members should use consistent Git workflows.

## What Belongs in a Project-Level CLAUDE.md (Not Here)

The following should be defined per-repo, not globally:
- Build/test/run commands specific to that project
- Architecture diagrams and component maps
- Release and deployment processes
- Project-specific environment setup
- CI/CD pipeline details
- Dependencies and version constraints

## Project-Level CLAUDE.md Template

When I ask you to initialize or scaffold a project-level `CLAUDE.md`, use this template as a starting point. Fill in the sections based on the repo's contents and structure:

```markdown
# Project: <project-name>

## Overview
<!-- Brief description of what this project does and its primary goals -->

## Build & Run
<!-- Project-specific commands — conda env, test suite, entry points -->
- `conda activate <env-name>`
- `python -m pytest tests/`
- `python src/<entry>.py --config config/default.yaml`

## Architecture
<!-- Key directories and their responsibilities -->
- `src/data/` — data loading and preprocessing
- `src/features/` — feature engineering pipeline
- `src/models/` — model definitions and training loops
- `src/evaluate/` — metrics computation and reporting

## Plugins & Tools
<!-- Project-specific plugins, LSPs, and MCP servers -->

**Required Plugins:**
- List plugins that team members should install (e.g., `typescript-lsp` for TS projects)

**Project MCP Servers:**
- Document any project-scoped MCP servers (defined in `.mcp.json`)
- Include setup instructions and required API keys/credentials

**Recommended LSPs:**
- Language servers specific to this project's tech stack

## Key Dependencies
<!-- Non-obvious or pinned dependencies worth noting -->
| Package | Purpose | Notes |
|---------|---------|-------|
| | | |

## Current Status
<!-- Living section: what's in progress, what's blocked -->
- **Working on**:
- **Blocked on**:
- **Next up**:

## Project-Specific Conventions
<!-- Anything that overrides or extends the user-level CLAUDE.md -->
```
