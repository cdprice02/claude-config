#!/usr/bin/env bash
# Statusline for Claude Code - reads JSON from stdin.
# Deliberately minimal, matching caret (github.com/cdprice02/caret): model,
# directory, git branch. Set apart after a gap: prompt-cache state and a
# context bar measured against the auto-compact threshold, since cache misses
# and context size are what drive per-turn cost. Both stay gray until they
# need attention.
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
    echo "statusline: jq not found on PATH" >&2
    exit 0
fi

CYAN='\033[1;36m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
GRAY='\033[90m'
RESET='\033[0m'

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
raw_cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir')
cwd=$(basename "$raw_cwd")

branch=""
if git -C "$raw_cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git -C "$raw_cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
fi

line="${CYAN}${model}${RESET} ${BLUE}${cwd}${RESET}"
[ -n "$branch" ] && line="$line ${GREEN}${branch}${RESET}"

extras=""

# Prompt cache: gray dot plus minutes left on the TTL while warm, yellow
# when cold (the next turn re-sends the whole context at full price).
cache=$(echo "$input" | jq -r '
    .prompt_cache
    | if . == null or .caching_observed != true then empty
      elif .warm then "warm \(((.expires_at // now) - now) / 60 | floor | if . < 0 then 0 else . end)"
      else "cold" end')
case "$cache" in
    warm*) extras="${GRAY}● ${cache#warm }m${RESET}" ;;
    cold) extras="${YELLOW}○ cold${RESET}" ;;
esac

# Context bar: current context tokens against autoCompactWindow (falling back
# to the model's window), so the bar fills toward the point compaction fires.
used=$(echo "$input" | jq -r '
    .context_window.current_usage
    | if . == null then empty
      else (.input_tokens // 0) + (.cache_creation_input_tokens // 0)
         + (.cache_read_input_tokens // 0) end')
if [ -n "$used" ]; then
    limit=$(jq -r '.autoCompactWindow // empty' "$HOME/.claude/settings.json" 2>/dev/null || true)
    [ -n "$limit" ] || limit=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
    pct=$((used * 100 / limit))
    [ "$pct" -gt 100 ] && pct=100

    color=$GRAY
    [ "$pct" -ge 80 ] && color=$RED

    width=10
    filled=$((pct * width / 100))
    bar=""
    i=0
    while [ "$i" -lt "$width" ]; do
        if [ "$i" -lt "$filled" ]; then bar="${bar}▰"; else bar="${bar}▱"; fi
        i=$((i + 1))
    done
    [ -n "$extras" ] && extras="$extras "
    extras="${extras}${color}${bar} $((used / 1000))k/$((limit / 1000))k${RESET}"
fi

[ -n "$extras" ] && line="$line    $extras"

printf " %b\n" "$line"
