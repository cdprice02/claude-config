#!/usr/bin/env bash
# SessionStart: banner + context detection + Obsidian reminder
# Bootstrap (MCPs, plugins) runs separately via async SessionStart hook in settings.json
set -u

# === Banner ===
cwd=$(pwd)
cwd_display="$cwd"
case "$cwd" in
    "$HOME") cwd_display="~" ;;
    "$HOME"/*) cwd_display="~${cwd#$HOME}" ;;
esac

branch=""
dirty=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
    dirty_count=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "${dirty_count:-0}" != "0" ]; then
        dirty=" (${dirty_count} dirty)"
    fi
fi

profile="${CLAUDE_PROFILE:-personal}"

if [ -n "$branch" ]; then
    printf '%s · %s%s · %s\n' "$cwd_display" "$branch" "$dirty" "$profile"
else
    printf '%s · %s\n' "$cwd_display" "$profile"
fi

# === Plan Mode Shared Context Guidance ===
# stat -f (macOS) / stat -c (Linux) — try both
_stat_mtime() { stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null; }
_latest_plan=$(ls "$HOME/.claude/plans"/*.md 2>/dev/null | head -1)
if [ -n "$_latest_plan" ] && [ "$(_stat_mtime "$_latest_plan")" -gt "$(( $(date +%s) - 300 ))" ] 2>/dev/null; then
    cat <<'EOF'

📋 Plan Mode - Shared Context Strategy:
   Before spawning parallel Explore agents:
   1. Gather foundational context all agents need (repo structure, configs, git status, CLAUDE.md)
   2. Pass this shared context in each agent's prompt
   3. Assign each agent a specific exploration area to avoid overlap
   Benefits: Fewer permission prompts, no duplicate reads, efficient exploration
EOF
fi
