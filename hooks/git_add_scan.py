#!/usr/bin/env python
"""PreToolUse hook: block git add of sensitive files."""

import json
import re
import sys

# Patterns for files that should never be staged
SENSITIVE_PATTERNS = [
    r"\.env\b",
    r"\.env\.\w+",
    r"credentials\.\w+",
    r"\.pem\b",
    r"\.key\b",
    r"secrets/",
    r"\.aws/",
    r"\.ssh/",
    r"id_rsa",
    r"id_ed25519",
    r"\.p12\b",
    r"\.pfx\b",
    r"\.keystore\b",
]


def main() -> None:
    try:
        event = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    tool_input = event.get("tool_input", {})
    command = tool_input.get("command", "")

    # Only check git add commands
    if not re.search(r"\bgit\s+add\b", command):
        sys.exit(0)

    # Check each sensitive pattern against the command
    blocked = []
    for pattern in SENSITIVE_PATTERNS:
        if re.search(pattern, command):
            blocked.append(pattern)

    # Also block broad adds that could sweep in sensitive files
    broad_adds = [r"\bgit\s+add\s+-A\b", r"\bgit\s+add\s+\.\s*$", r"\bgit\s+add\s+--all\b"]
    for pattern in broad_adds:
        if re.search(pattern, command):
            blocked.append("broad add (use specific files instead)")

    if blocked:
        output = json.dumps({
            "decision": "block",
            "reason": f"Blocked git add — matched sensitive patterns: {', '.join(blocked)}",
        })
        sys.stderr.write(output)
        sys.exit(2)

    sys.exit(0)


if __name__ == "__main__":
    main()
