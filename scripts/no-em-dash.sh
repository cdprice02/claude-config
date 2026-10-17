#!/usr/bin/env bash
# PostToolUse (Write|Edit): reject em-dashes in newly written text. Exit 2
# feeds stderr back to Claude, which then rewrites the passage.
set -eu

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // "the file"')

# Memory indexes follow the harness's own "- [Title](file.md) — hook" format.
case "$file" in
    */.claude/projects/*/memory/* | */config/claude/projects/*/memory/*) exit 0 ;;
esac

text=$(printf '%s' "$input" | jq -r '
    .tool_input | [.content, .new_string, (.edits // [] | .[].new_string)]
    | map(select(. != null)) | join("\n")')

case "$text" in
    *—*)
        echo "Em-dash written to $file. Rewrite each one with a colon, semicolon, comma, parentheses, or a restructured sentence." >&2
        exit 2
        ;;
esac
exit 0
