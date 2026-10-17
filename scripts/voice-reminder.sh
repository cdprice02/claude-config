#!/usr/bin/env bash
# PreToolUse (Write|Edit): in a repo with docs/agents/voice.md, block edits
# until the session transcript shows a Read of it. A mere mention, such as
# this hook's own message, does not count. Exit 2 tells Claude to read it and
# retry.
set -eu

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
[ -n "$file" ] || exit 0

dir=$(dirname -- "$file")
while [ ! -d "$dir" ]; do dir=$(dirname -- "$dir"); done
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
voice="$root/docs/agents/voice.md"
[ -f "$voice" ] || exit 0

if [ -n "$transcript" ] && [ -f "$transcript" ] && grep -Fq "\"file_path\":\"$voice\"" "$transcript"; then
    exit 0
fi

echo "This repo has a voice guide. Read $voice in full, then retry this edit." >&2
exit 2
