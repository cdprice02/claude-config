#!/usr/bin/env python
"""PostToolUse hook: auto-lint Python files with ruff + black after Write/Edit/MultiEdit."""

import json
import subprocess
import sys


def main() -> None:
    try:
        event = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    tool_input = event.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    if not file_path.endswith(".py"):
        sys.exit(0)

    messages = []

    # Run ruff check --fix
    try:
        result = subprocess.run(
            ["ruff", "check", "--fix", file_path],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.stdout.strip():
            messages.append(f"ruff: {result.stdout.strip()}")
        if result.returncode != 0 and result.stderr.strip():
            messages.append(f"ruff warnings: {result.stderr.strip()}")
    except FileNotFoundError:
        messages.append("ruff not found, skipping lint")
    except subprocess.TimeoutExpired:
        messages.append("ruff timed out")

    # Run black
    try:
        result = subprocess.run(
            ["black", "--quiet", file_path],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode == 0:
            messages.append(f"black formatted {file_path}")
        elif result.stderr.strip():
            messages.append(f"black: {result.stderr.strip()}")
    except FileNotFoundError:
        messages.append("black not found, skipping format")
    except subprocess.TimeoutExpired:
        messages.append("black timed out")

    if messages:
        output = json.dumps({"systemMessage": " | ".join(messages)})
        sys.stderr.write(output)

    # Always exit 0 — linting should never block writes
    sys.exit(0)


if __name__ == "__main__":
    main()
