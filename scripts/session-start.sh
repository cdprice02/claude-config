#!/usr/bin/env bash
# SessionStart: banner, plus a cost warning when resuming a session whose
# prompt cache has expired (the first request re-sends the whole context).
# Plain stdout here lands in Claude's context; keep it to a line or two.
set -u

input=$(cat)

# === Banner ===
cwd=$(pwd)
cwd_display="$cwd"
case "$cwd" in
    "$HOME") cwd_display="~" ;;
    "$HOME"/*) cwd_display="~${cwd#"$HOME"}" ;;
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
    banner=$(printf '%s · %s%s · %s' "$cwd_display" "$branch" "$dirty" "$profile")
else
    banner=$(printf '%s · %s' "$cwd_display" "$profile")
fi

# === Cold resume warning ===
# The resume fields (Claude Code >= 2.1.251) appear only for resume/fork with
# at least one prior response. A warning goes out as systemMessage so it
# reaches the user, not just Claude's context.
warning=""
if command -v jq >/dev/null 2>&1; then
    warning=$(printf '%s' "$input" | jq -r '
        select(.prompt_cache_likely_expired == true and (.context_tokens // 0) >= 50000)
        | "Cold resume: \(.context_tokens / 1000 | floor)k tokens to re-cache"
          + (if .estimated_cache_write_usd then " (~$\(.estimated_cache_write_usd * 100 | round / 100))" else "" end)
          + ", idle \(.seconds_since_last_response / 3600 * 10 | floor / 10)h. Consider /compact or a fresh session with a handoff."
    ' 2>/dev/null || true)
fi

if [ -n "$warning" ]; then
    jq -n --arg banner "$banner" --arg warning "$warning" '{
        systemMessage: $warning,
        hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $banner}
    }'
else
    printf '%s\n' "$banner"
fi
