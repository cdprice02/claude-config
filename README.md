# claude-config

Personal Claude Code configuration, synced across machines via git.

> **Profiles are separated by branch and remote, not by settings files.**
> Public `main` (this repo) is the personal profile and the shared base.
> A private `claude-config-work` repo holds the work overlay, checked out on
> work machines as a local `work` branch tracking `private/main`. Nothing
> employer-specific (hostnames, internal project names, endpoints) may land
> here. `scripts/profile-check.sh` warns when a machine is on the wrong branch.

## What's tracked

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Global instructions loaded every session, kept deliberately thin |
| `PROJECT_TEMPLATE.md` | Scaffold for per-repo CLAUDE.md files |
| `settings.json` | Permissions, hooks, plugins, model, env |
| `skills/*/SKILL.md` | On-demand skills (see below) |
| `scripts/` | Hook scripts, see Hooks |

Not tracked: session data, logs, file history, plugin caches, `plans/`.
The `.gitignore` is **deny-by-default** (`*` plus an explicit allowlist), so a
new file is ignored unless deliberately permitted.

## Skills

Loaded on demand: only the one-line description enters context until invoked.

| Skill | Covers |
|---|---|
| `vault` | The Obsidian vault at `$OBSIDIAN_VAULT`: layout, search, capture conventions, frontmatter and tags, write scope |
| `pr-workflow` | Issue → worktree → PR → merge, including multi-PR programs |

The `nix-config` skill lives in that repo's own `.claude/skills/`; it describes
one repo, so it loads only inside it, not in every session everywhere.

## MCP servers

**None are configured locally.** This is deliberate.

- The **vault** is read from the filesystem. Obsidian Sync puts it on every
  machine, so `Grep`/`Glob`/`Read` work directly at zero MCP token cost.
  `env.OBSIDIAN_VAULT` is the portability seam for scripts and skill
  instructions, since a shell env var can hold a path that differs per
  machine. Permission-rule paths (`additionalDirectories`, the vault `deny`
  entries) cannot reference an env var; Claude Code's permission syntax has
  no interpolation, so they hardcode the `~/repos/obsidian` convention
  directly. If the vault ever lives somewhere else, those entries need a
  manual update and will not follow `$OBSIDIAN_VAULT`.
- **Account-level claude.ai connectors** (Context7, Drive, Gmail, Calendar) do
  surface inside Claude Code, but only on the personal profile. **Bedrock auth
  has no claude.ai session, so work machines get none of them, and no
  WebSearch either.** The work branch must restore what matters as plugins.
- A **remote MCP connector** covers the same vault for surfaces that cannot
  reach a filesystem: mobile, claude.ai web, Desktop. Claude Code does not
  use it; the deployment lives outside this repo, in private infrastructure.

## Plugins

| Plugin | Purpose |
|---|---|
| `commit-commands` | `/commit`, `/commit-push-pr`, `/clean_gone` |
| `skill-creator` | Create and iterate on skills |
| `claude-md-management` | Audit CLAUDE.md quality, capture session learnings |

`scripts/bootstrap.sh` installs these on first session start. It registers **no**
MCP servers.

## Hooks

| Event | Script | What |
|---|---|---|
| SessionStart | `profile-check.sh` | Asserts profile, branch and auth mode agree. Silent when coherent, loud on mismatch. Runs first. |
| SessionStart | `session-start.sh` | Banner: path, branch, dirty count, profile |
| SessionStart | `bootstrap.sh` | Async; installs missing plugins |
| PostToolUse | `format-on-edit.sh` | `ruff` / `rustfmt` / JuliaFormatter by extension |
| PostToolUse | `clippy-on-edit.sh` | `cargo clippy` for `.rs` |

`statusline.sh` is the status line: reads `COLUMNS` for width and counts
characters rather than bytes (the bars are multi-byte UTF-8).

## Setup on a new machine

```bash
# If ~/.claude doesn't exist yet
git clone git@github.com:cdprice02/claude-config.git ~/.claude

# If Claude Code already created ~/.claude
cd ~/.claude
git init && git remote add origin git@github.com:cdprice02/claude-config.git
git fetch && git checkout -b main --track origin/main
```

On a [nix-config](https://github.com/cdprice02/nix-config)-managed machine this
is automatic: `~/.claude` is an out-of-store symlink to `config/claude`, and
`user.nix`'s `submodules` block wires the private remote on work machines.

This repo needs no secrets of its own. If a future plugin or connector needs
one, the convention is `~/.config/secrets/env`, sourced by shell init; see
nix-config's `secrets.env.example` for the template.

## Syncing

```bash
cd ~/.claude && git pull && git add -p && git commit && git push
```

On work machines, propagate shared changes from public `main` with
`just sync-work` in nix-config.
