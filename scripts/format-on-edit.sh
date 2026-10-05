#!/usr/bin/env bash
# Format-on-edit hook. Reads the Write/Edit tool result on stdin, extracts
# the edited file path, and runs the appropriate formatter for its extension.
# Silent on unsupported extensions and when formatters are missing: hook
# output on exit 0 reaches neither the user nor Claude, so warnings are moot.
set -eu

command -v jq >/dev/null 2>&1 || exit 0

file_path=$(jq -r '.tool_input.file_path // empty')
[ -z "${file_path:-}" ] && exit 0

case "$file_path" in
    *.py)
        command -v ruff >/dev/null 2>&1 && ruff format -- "$file_path" >/dev/null 2>&1
        ;;
    *.rs)
        # Bare rustfmt assumes edition 2015 and fails to parse newer syntax,
        # so pass the crate's edition from the nearest Cargo.toml.
        if command -v rustfmt >/dev/null 2>&1; then
            edition=2021
            dir=$(dirname -- "$file_path")
            while [ "$dir" != "/" ] && [ "$dir" != "." ]; do
                if [ -f "$dir/Cargo.toml" ]; then
                    found=$(sed -n 's/^edition *= *"\([0-9]*\)".*/\1/p' "$dir/Cargo.toml" | head -1)
                    [ -n "$found" ] && edition=$found && break
                fi
                dir=$(dirname -- "$dir")
            done
            rustfmt --edition "$edition" -- "$file_path" >/dev/null 2>&1
        fi
        ;;
    *.nix)
        command -v nixfmt >/dev/null 2>&1 && nixfmt -- "$file_path" >/dev/null 2>&1
        ;;
esac
exit 0
