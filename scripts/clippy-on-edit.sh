#!/usr/bin/env bash
# Clippy-on-edit hook. Reads the Write/Edit tool result on stdin; if the edited
# file is Rust, runs cargo clippy and prints the last 20 lines of output.
set -eu

command -v jq >/dev/null 2>&1 || { echo "clippy-on-edit: jq not found on PATH" >&2; exit 0; }

file_path=$(jq -r '.tool_input.file_path // empty')
[ -z "${file_path:-}" ] && exit 0

case "$file_path" in
    *.rs)
        if command -v cargo >/dev/null 2>&1; then
            if ! manifest=$(cd -- "$(dirname -- "$file_path")" && \
                cargo locate-project --message-format plain 2>/dev/null); then
                manifest=""
            fi
            if [ -n "$manifest" ]; then
                cargo clippy --manifest-path "$manifest" --quiet 2>&1 | tail -20
            else
                echo "warning: no Cargo.toml found above $file_path, skipping clippy" >&2
            fi
        else
            echo "warning: cargo not found, skipping clippy for $file_path" >&2
        fi
        ;;
esac
