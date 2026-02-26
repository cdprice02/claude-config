#!/usr/bin/env python
"""PreToolUse hook: block writes containing credential patterns."""

import json
import os
import re
import sys

# File path patterns that should never be written
SENSITIVE_FILE_PATTERNS = [
    r"\.env$",
    r"\.env\.[^/\\]+$",
    r"credentials\.[^/\\]+$",
    r"\.pem$",
    r"\.key$",
    r"[/\\]\.aws[/\\]",
    r"[/\\]secrets[/\\]",
]

# Content patterns indicating embedded credentials
CREDENTIAL_PATTERNS = [
    (r"AKIA[0-9A-Z]{16}", "AWS access key"),
    (r"""(?i)(?:api[_-]?key|apikey)\s*[=:]\s*['"][A-Za-z0-9_\-]{20,}['"]""", "API key assignment"),
    (r"""(?i)bearer\s+[A-Za-z0-9_\-\.]{20,}""", "Bearer token"),
    (r"""(?i)(?:password|passwd|pwd)\s*[=:]\s*['"][^'"]{8,}['"]""", "Password literal"),
    (r"-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----", "Private key header"),
    (r"""(?i)(?:secret[_-]?key|client[_-]?secret)\s*[=:]\s*['"][A-Za-z0-9_\-]{16,}['"]""", "Secret key assignment"),
    (r"""(?i)(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}""", "GitHub token"),
    (r"""(?i)sk-[A-Za-z0-9]{20,}""", "OpenAI/Stripe secret key"),
]


def check_file_path(file_path: str) -> str | None:
    """Return a reason string if the file path matches a sensitive pattern."""
    for pattern in SENSITIVE_FILE_PATTERNS:
        if re.search(pattern, file_path):
            return f"Sensitive file path: {file_path} matches pattern {pattern}"
    return None


def check_content(content: str) -> str | None:
    """Return a reason string if content contains credential patterns."""
    for pattern, description in CREDENTIAL_PATTERNS:
        match = re.search(pattern, content)
        if match:
            # Show a redacted snippet for context
            snippet = match.group(0)
            redacted = snippet[:8] + "..." + snippet[-4:] if len(snippet) > 16 else snippet[:4] + "..."
            return f"{description} detected: {redacted}"
    return None


def main() -> None:
    try:
        event = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    tool_name = event.get("tool_name", "")
    tool_input = event.get("tool_input", {})

    # Determine file path and content based on tool type
    file_path = tool_input.get("file_path", "")
    if tool_name == "Write":
        content = tool_input.get("content", "")
    elif tool_name in ("Edit", "MultiEdit"):
        content = tool_input.get("new_string", "")
    else:
        sys.exit(0)

    # Check file path
    path_issue = check_file_path(file_path)
    if path_issue:
        output = json.dumps({
            "decision": "block",
            "reason": path_issue,
        })
        sys.stderr.write(output)
        sys.exit(2)

    # Check content
    if content:
        content_issue = check_content(content)
        if content_issue:
            output = json.dumps({
                "decision": "block",
                "reason": f"Credential pattern found — {content_issue}",
            })
            sys.stderr.write(output)
            sys.exit(2)

    # Clean — allow the operation
    sys.exit(0)


if __name__ == "__main__":
    main()
