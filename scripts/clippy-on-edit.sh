#!/usr/bin/env bash
# Clippy-on-edit hook. Reads the Write/Edit tool result on stdin; if the edited
# file is Rust, runs cargo clippy and prints the last 20 lines of output.
set -eu

file_path=$(tr -d '\n' | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "${file_path:-}" ] && exit 0

case "$file_path" in
    *.rs)
        if command -v cargo >/dev/null 2>&1; then
            manifest=$(cargo locate-project --manifest-path "$(dirname "$file_path")/Cargo.toml" \
                --message-format plain 2>/dev/null || true)
            if [ -n "$manifest" ]; then
                cargo clippy --manifest-path "$manifest" --quiet 2>&1 | tail -20
            else
                cargo clippy --quiet 2>&1 | tail -20
            fi
        else
            echo "warning: cargo not found — skipping clippy for $file_path" >&2
        fi
        ;;
esac
