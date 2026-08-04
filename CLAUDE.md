# CLAUDE.md

Global guidance for Claude Code. Project-specific context belongs in per-repo
`CLAUDE.md` files; use `PROJECT_TEMPLATE.md` as the starting point.

> This file lives in a **public** repository. Keep it free of employer names,
> internal project names, hostnames, and infrastructure detail. Anything
> work-specific belongs on the private work branch.

## Writing

No em-dashes, in code, docs, commit messages, or chat. Use a colon, semicolon,
comma, parentheses, or restructure the sentence instead. This applies to my
own writing too when helping polish it, not just generated content.

## Environment

Claude Code runs on several machines across macOS, WSL2, Git Bash, and Linux.
Keep shell snippets POSIX-portable and paths forward-slashed so they work
everywhere. `CLAUDE_PROFILE` is set to `personal` or `work`; personal profiles
use subscription auth, work profiles use AWS Bedrock.

**On Bedrock profiles, `WebSearch` is unavailable.** Use Context7 for library
docs and `WebFetch` against allowlisted domains instead.

## Verification

For anything with runtime behavior (pipelines, notebooks, CLI output), actually
run it: tests verify code correctness, not feature correctness. Say so
explicitly if verification isn't possible in this environment.

## Knowledge base

An Obsidian vault at `$OBSIDIAN_VAULT` holds project context, past decisions,
meeting history, and domain knowledge that isn't in training data. It is
synced to every machine, so read it with the normal file tools: `Grep`,
`Glob`, `Read`.

Check it **when the task depends on prior context**, not reflexively:

- a project, system, or acronym you don't recognize from the repo
- a past decision, architecture choice, or tool evaluation
- meeting history, people, or anything with an organizational answer

Skip it for self-contained work; a compile error or a local refactor doesn't
need the vault.

Read `$OBSIDIAN_VAULT/CLAUDE.md` for capture conventions before writing to it.
Treat `templates/`, MOC files, and `Dashboard*.md` as read-only; they're
hand-maintained navigation.

## Research order

1. **Vault**: prior decisions and project context (per the trigger above)
2. **Context7**: library and framework documentation
3. **Code intelligence**: navigation and symbols
4. **WebFetch**: known URLs · **WebSearch**: open-ended (personal profile only)
