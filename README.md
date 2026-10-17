# claude-config

Personal Claude Code configuration (`~/.claude`), a submodule of
[nix-atelier](https://github.com/cdprice02/nix-atelier) at `config/claude`.

> **Profiles are separated by branch and remote, not by settings files.**
> Public `main` (this repo) is the personal profile and the shared base. A
> private `claude-config-work` repo holds the work overlay, checked out on
> work machines as a local `work` branch. Nothing employer-specific may land
> here. `scripts/profile-check.sh` warns when a machine is on the wrong
> branch.

## What's tracked

The `.gitignore` is deny-by-default (`*` plus an allowlist), so a new file is
ignored unless deliberately permitted.

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Global instructions, loaded every session; kept short |
| `settings.json` | Permissions, hooks, plugins, skill visibility, model |
| `skills/` | Symlinks into `config/skills` (see below) |
| `agents/` | `vault-researcher`, a read-only Haiku agent for vault questions |
| `commands/` | `/capture`, which captures the conversation into the vault |
| `scripts/` | Hooks and the status line |

There is no per-repo CLAUDE.md template: a repo's CLAUDE.md holds only what
that repo does differently, written with the `writing-for-agents` skill.

## Skills

Every skill lives in `config/skills`, a fork of
[mattpocock/skills](https://github.com/mattpocock/skills). `just link-skills`
(run by `just sync` in nix-atelier) symlinks each `SKILL.md` under its
`engineering/`, `productivity/`, and `atelier/` buckets into `skills/` as a
bare name, so the fork's skills can call each other by name.

- `atelier/` holds the skills written here: `commit`, `toolchain`, `vault`.
  Upstream has no such bucket, so merges never touch it.
- Visibility is set in `settings.json` `skillOverrides` in three tiers:
  model-invoked (default), `user-invocable-only` (slash command only), and
  `off`.
- A weekly cloud routine opens a PR on the fork when upstream has new
  commits, with a triage table; it never merges on its own.

## Vault and MCP

The Obsidian vault reaches every machine through Obsidian Sync, so Claude
Code reads and edits it as files. Conventions live in the vault itself, at
`docs/conventions.md`, shared with every other surface. `OBSIDIAN_VAULT` is
exported by nix-atelier's `atelier.obsidianVault` option, since a
settings.json `env` value cannot expand `$HOME`.

The `hive` claude.ai connector covers what files cannot: moving notes with
wikilink repointing, semantic search, and Google Drive. claude.ai connectors
exist only on the personal profile; Bedrock (work) sessions get none of them,
and no WebSearch.

## Hooks

| Event | Script | What |
|---|---|---|
| SessionStart | `profile-check.sh` | Profile, branch, and auth mode agree; silent when coherent |
| SessionStart | `session-start.sh` | Banner, plus a warning on a cold-cache resume |
| PreToolUse (Bash) | `commit-msg-check.sh` | Commit subject at most 72 chars, body at most 3 lines, no em-dashes |
| PreToolUse (Write/Edit) | `voice-reminder.sh` | In a repo with `docs/agents/voice.md`, blocks edits until it was read |
| PostToolUse (Write/Edit) | `format-on-edit.sh` | `ruff` / `rustfmt` / `nixfmt` by extension |
| PostToolUse (Write/Edit) | `no-em-dash.sh` | Rejects em-dashes in written text |

`statusline.sh` is the status line: model, directory, branch, prompt-cache
state, and a context bar measured against `autoCompactWindow`.

## Setup and sync

On a nix-atelier machine, `~/.claude` is an out-of-store symlink to
`config/claude`, created on first activation; `atelier.submodules` wires the
private remote on work machines. Propagate shared changes to the work branch
with `just sync-work` in nix-atelier.
