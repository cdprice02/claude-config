# claude-config

Personal Claude Code configuration — synced across machines via git.

## What's tracked

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Global instructions loaded every session |
| `PROJECT_TEMPLATE.md` | Scaffold for per-repo CLAUDE.md files |
| `settings.json` | Permissions, hooks, plugins, MCP servers, model |
| `scripts/` | Hook scripts (format-on-edit, clippy-on-edit, session-start, bootstrap, statusline) |
| `agents/` | Custom agents (code-reviewer, debugger) |
| `.env.local.example` | Template for machine-local secrets |

## What's NOT tracked

Session data, debug logs, file history, plugin caches, `.env.local` (machine-local secrets).

## MCP Servers

| Server | Purpose |
|---|---|
| `mcp-obsidian` | Obsidian vault search and capture — requires `bunx` and Obsidian Local REST API plugin running |
| `brave-search` | Web/paper search — free tier 2k queries/month at https://api.search.brave.com |
| `localdata` | Data/file profiling (HDF5, NetCDF, Parquet, SQL) |

`mcp-obsidian` is registered at user scope by `bootstrap.sh` on first session start. `localdata-mcp` is auto-installed by `bootstrap.sh` via `uv tool install`. `brave-search` runs via `npx` with no install step.

## Plugins

| Plugin | Purpose |
|---|---|
| `commit-commands` | `/commit`, `/commit-push-pr`, `/clean_gone` |
| `skill-creator` | Create and iterate on custom skills |

## Setup on a new machine

```bash
# If ~/.claude doesn't exist yet
git clone git@github.com:cdprice02/claude-config.git ~/.claude

# If Claude Code already created ~/.claude
cd ~/.claude
git init
git remote add origin git@github.com:cdprice02/claude-config.git
git fetch
git checkout -b main --track origin/main
```

Then set up secrets:

```bash
cp ~/.claude/.env.local.example ~/.claude/.env.local
# fill in OBSIDIAN_API_KEY and BRAVE_API_KEY, then source in ~/.bashrc
```

`bootstrap.sh` handles MCP registration and `localdata-mcp` install automatically on first session start.

## Syncing

```bash
cd ~/.claude && git pull && git add -p && git commit && git push
```
