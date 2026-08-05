#!/usr/bin/env bash
# Statusline for Claude Code - reads JSON from stdin.
# Deliberately minimal, matching caret (github.com/cdprice02/caret): model,
# directory, git branch. Nothing else earns a permanent place on the line.
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
    echo "statusline: jq not found on PATH" >&2
    exit 0
fi

CYAN='\033[1;36m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
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

printf " %b\n" "$line"
