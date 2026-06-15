# CLAUDE.md

Global guidance for Claude Code. Project-specific context belongs in per-repo `CLAUDE.md` files — use `PROJECT_TEMPLATE.md` as the starting point.

## Environment

Work machine: Windows 11, Git Bash. Personal: macOS. Keep shell snippets POSIX-portable and paths forward-slashed.

## Verification

For anything with runtime behavior (pipelines, notebooks, CLI output), actually run it — tests verify code correctness, not feature correctness. Say so explicitly if verification isn't possible in this environment.

## Workflow

**Always check the Obsidian vault first** — 816 notes (2022–2026) with project context, past decisions, and domain knowledge not in training data. Use proactively for:
- Project names (LCNext, classification, anomaly detection, cloudmask)
- Domain work (remote sensing, AI/ML, infrastructure)
- Past decisions, architecture choices, tool evaluations

**Search pattern:**
1. `mcp__mcp-obsidian__obsidian_simple_search(query="keyword")`
2. `mcp__mcp-obsidian__obsidian_list_files_in_dir(path="knowledge/ai-ml")`
3. `mcp__mcp-obsidian__obsidian_get_file_contents(filepath="...")`
4. Read `~/repos/obsidian/CLAUDE.md` for capture workflow and conventions

Then: **context7** (library docs) → **code intelligence** (navigation/symbols) → **Brave Search** (web/paper search) → **WebFetch** (known URLs).

