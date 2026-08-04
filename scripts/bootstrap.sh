#!/usr/bin/env bash
# Bootstrap plugins on any machine.
# Wired into settings.json SessionStart hook; runs automatically, async.
#
# To add a plugin: add its id to PLUGINS.
#
# No MCP servers are registered here any more:
#   - mcp-obsidian   retired. Obsidian Sync puts the vault on every machine, so
#                    the `vault` skill reads it with Grep/Glob/Read. Same
#                    capability, zero MCP tool-schema tokens.
#   - localdata-mcp  removed. settings.json referenced it for months while the
#                    binary was never actually installed.
# Account-level connectors (Context7, Drive, Gmail, Calendar) come from the
# claude.ai session and need no registration, but note they are unavailable
# under Bedrock auth, so work profiles must enable equivalents as plugins.

set -u

# ── Plugins ───────────────────────────────────────────────────────────────────
# Marketplace plugins auto-install when enabled, but listing them here ensures
# they are present on fresh machines where auto-install has not run yet.

PLUGINS=(
    "commit-commands@claude-plugins-official"
    "skill-creator@claude-plugins-official"
    "claude-md-management@claude-plugins-official"
)

_installed=$(claude plugin list 2>/dev/null)
for plugin in "${PLUGINS[@]}"; do
    echo "$_installed" | grep -qF "$plugin" || \
        claude plugin install "$plugin" >/dev/null 2>&1 || true
done
