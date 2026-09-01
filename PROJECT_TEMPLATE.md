# Project: {project-name}

## Overview
<!-- Brief description of what this project does and its primary goals -->

## Build & Run
<!-- Project-specific commands: setup, build, test, run -->
- Setup:
- Build:
- Test:
- Run:

## Architecture
<!-- Key directories and their roles -->
- `src/`:
- `tests/`:

## Plugins & Tools
<!-- Project-scoped MCP servers (.mcp.json), required LSPs, extensions -->

## Key Dependencies
<!-- Non-obvious or pinned dependencies worth noting -->
| Package | Purpose | Notes |
|---------|---------|-------|

## Current Status
<!-- Living section: what's in progress, what's blocked -->
- **Working on**:
- **Blocked on**:
- **Next up**:

## Project-Specific Conventions
<!-- Anything that overrides or extends the user-level CLAUDE.md -->

## Rust clippy scaffold (optional, new projects only)
<!--
Opt-in scaffold to copy into a NEW Rust project's Cargo.toml and clippy.toml.
Do not retrofit onto an existing repo: turning this on across an established
codebase all at once surfaces a wall of unrelated lint errors. An existing
repo adopts this deliberately and separately, if at all.
-->

`Cargo.toml`:

```toml
[lints.clippy]
pedantic = { level = "deny", priority = -1 }
nursery = { level = "deny", priority = -1 }
unwrap_used = "deny"
expect_used = "deny"
indexing_slicing = "deny"
arithmetic_side_effects = "deny"
unreachable = "deny"
unimplemented = "deny"
unchecked_time_subtraction = "deny"
todo = "deny"
string_slice = "deny"
panic_in_result_fn = "deny"
panic = "deny"
exit = "deny"
as_conversions = "deny"
```

`clippy.toml`:

```toml
allow-unwrap-in-tests = true
allow-expect-in-tests = true
allow-panic-in-tests = true
allow-indexing-slicing-in-tests = true
```
