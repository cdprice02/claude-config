#!/usr/bin/env bash
# PreToolUse (Bash): enforce the commit skill's message shape on `git commit`
# commands Claude runs. Exit 2 blocks the call and tells Claude why.
set -eu

command -v jq >/dev/null 2>&1 || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

cmd=$(jq -r '.tool_input.command // empty')
case "$cmd" in
    *"git commit"*) ;;
    *) exit 0 ;;
esac

# shellcheck disable=SC2016 # Python source, not shell
printf '%s' "$cmd" | python3 -I -c '
import re, shlex, sys

cmd = sys.stdin.read()
messages = []

# git commit -F - <<EOF ... EOF, possibly several in one command.
for m in re.finditer(r"git commit[^\n]*?(?:-F|--file)[ =]?-[^\n]*<<-?\s*\x27?(\w+)\x27?\n(.*?)\n\1$", cmd, re.S | re.M):
    messages.append(m.group(2))

if not messages:
    try:
        tokens = shlex.split(cmd, posix=True)
    except ValueError:
        sys.exit(0)
    parts = []
    for flag, value in zip(tokens, tokens[1:]):
        if flag in ("-m", "--message"):
            # Unwrap the $(cat <<EOF ... EOF) heredoc form.
            m = re.match(r"^\$\(cat <<-?\x27?(\w+)\x27?\n(.*?)\n\s*\1\s*\)$", value, re.S)
            parts.append(m.group(2) if m else value)
    if parts:
        messages.append("\n\n".join(parts))

problems = []
if messages and "—" in cmd:
    problems.append("contains an em-dash")
for msg in messages:
    lines = msg.strip().splitlines() or [""]
    if len(lines[0]) > 72:
        problems.append(f"subject is {len(lines[0])} chars (max 72)")
    body = [l for l in lines[1:] if l.strip() and not re.match(r"^[\w-]+: .+<.+@.+>$", l)]
    if len(body) > 3:
        problems.append(f"body is {len(body)} lines (max 3; detail belongs in the PR body)")
if problems:
    print("Commit message " + "; ".join(problems) + ". See the commit skill.", file=sys.stderr)
    sys.exit(2)
'
