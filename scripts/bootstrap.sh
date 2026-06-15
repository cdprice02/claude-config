#!/usr/bin/env bash
# Bootstrap MCPs and plugins on any machine.
# Wired into settings.json SessionStart hook — runs automatically, async.
#
# To add an MCP:    copy an mcp_register line below
# To add a plugin:  add its id to PLUGINS

set -u

# ── MCP Servers ──────────────────────────────────────────────────────────────
# $HOME in args is single-quoted so it expands at server startup, not here.

mcp_register() {
    local name="$1" scope="$2"; shift 2
    claude mcp get "$name" >/dev/null 2>&1 || \
        claude mcp add --scope "$scope" "$name" -- "$@" >/dev/null 2>&1 || true
}

mcp_register mcp-obsidian user sh -c 'bunx mcp-obsidian "$HOME/repos/obsidian"'

# localdata-mcp is configured in settings.json but requires the tool to be installed
command -v localdata-mcp >/dev/null 2>&1 || \
    uv tool install localdata-mcp >/dev/null 2>&1 || true

# ── Plugins ───────────────────────────────────────────────────────────────────
# Official marketplace plugins auto-install when enabled, but listing them here
# ensures they're present on fresh machines where auto-install hasn't run yet.

PLUGINS=(
    "commit-commands@claude-plugins-official"
    "skill-creator@claude-plugins-official"
)

_installed=$(claude plugin list 2>/dev/null)
for plugin in "${PLUGINS[@]}"; do
    echo "$_installed" | grep -qF "$plugin" || \
        claude plugin install "$plugin" >/dev/null 2>&1 || true
done
