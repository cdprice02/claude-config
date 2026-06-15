#!/usr/bin/env bash
# Format-on-edit hook. Reads the Write/Edit tool result on stdin, extracts
# the edited file path, and runs the appropriate formatter for its extension.
# Silent on unsupported extensions. Safe to run when formatters are missing.
set -eu

file_path=$(tr -d '\n' | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "${file_path:-}" ] && exit 0

case "$file_path" in
    *.py)
        if command -v ruff >/dev/null 2>&1; then
            ruff format "$file_path" >/dev/null 2>&1
        else
            echo "warning: ruff not found — skipping format for $file_path" >&2
        fi
        ;;
    *.rs)
        if command -v rustfmt >/dev/null 2>&1; then
            rustfmt "$file_path" >/dev/null 2>&1
        else
            echo "warning: rustfmt not found — skipping format for $file_path" >&2
        fi
        ;;
    *.jl)
        if command -v julia >/dev/null 2>&1; then
            julia -e "using JuliaFormatter; format_file(\"$file_path\")" >/dev/null 2>&1
        else
            echo "warning: julia not found — skipping format for $file_path" >&2
        fi
        ;;
esac
