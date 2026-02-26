# claude-config

Personal Claude Code configuration — synced across machines via git.

## What's tracked

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Global instructions for all projects |
| `settings.json` | Permissions, hooks, plugins, model, env vars |
| `hooks/` | Pre/post tool-use hook scripts |
| `plugins/blocklist.json` | Blocked plugins |
| `plugins/known_marketplaces.json` | Plugin marketplace sources |
| `settings.local.json.example` | Template for machine-local credentials |

## What's NOT tracked

Session data, debug logs, file history, plugin caches, and `settings.local.json` (machine-local
credentials). All session data is regenerated automatically by Claude Code on each machine.

## Setup on a new machine

### 1. Clone

If `~/.claude` does not yet exist:
```bash
git clone git@github.com:cdprice02/claude-config.git ~/.claude
```

If Claude Code has already created `~/.claude` (merge existing state):
```bash
cd ~/.claude
git init
git remote add origin git@github.com:cdprice02/claude-config.git
git fetch
git checkout -b main --track origin/main
```

### 2. Machine-local settings (required)

```bash
cp ~/.claude/settings.local.json.example ~/.claude/settings.local.json
# Fill in OBSIDIAN_API_KEY from Obsidian → Settings → Local REST API
```

### 3. Plugins

`settings.json` lists enabled plugins. Claude Code will prompt on first run, or install manually:

```bash
claude plugin install context7@claude-plugins-official
claude plugin install pyright-lsp@claude-plugins-official
claude plugin install rust-analyzer-lsp@claude-plugins-official
claude plugin install security-guidance@claude-plugins-official
claude plugin install eros-codex@ErosMarketplace
```

### 4. Obsidian over SSH

The Obsidian MCP uses the Local REST API plugin at `http://localhost:27123`. On remote machines,
a reverse SSH tunnel makes that port point back to your Windows instance. Obsidian (with the
Local REST API plugin running) must be open on Windows when you connect.

**Option 1 — `~/.ssh/config` (recommended, works with VS Code and plain `ssh`):**

Add `RemoteForward 27123 localhost:27123` to each remote host entry:

```
Host remote-host
    HostName remote-host.example.com
    User your-username
    RemoteForward 27123 localhost:27123
```

The tunnel is established automatically on every `ssh <host>` connection, including VS Code
Remote SSH.

**Option 2 — One-off manual tunnel:**

```bash
ssh -R 27123:localhost:27123 user@host
```

Use this when connecting to a host not in `~/.ssh/config`, or for a quick one-off session.

**Verify the tunnel is active** (run on the remote machine):

```bash
curl http://localhost:27123/
# Should return a response from the Obsidian REST API
```

If `AllowTcpForwarding` is disabled on the remote server, the tunnel will silently fail — confirm
with the sysadmin if `curl` returns "connection refused" even with the tunnel active.

## Syncing

```bash
cd ~/.claude
git pull          # pull latest
git add -p
git commit
git push
```
