#!/usr/bin/env bash
# PreCompact: back up the transcript before compaction discards context.
set -eu

command -v jq >/dev/null 2>&1 || { echo "precompact-backup: jq not found on PATH" >&2; exit 0; }

input=$(cat)
transcript_path=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
session_id=$(printf '%s' "$input" | jq -r '.session_id // "unknown"')

[ -z "$transcript_path" ] && exit 0
[ -f "$transcript_path" ] || exit 0

backup_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/backups/transcripts"
mkdir -p "$backup_dir"

timestamp=$(date +%Y%m%d-%H%M%S)
cp -- "$transcript_path" "$backup_dir/${timestamp}-${session_id}.jsonl" 2>/dev/null || true
