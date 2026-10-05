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

## Toolchain

Before running a project's build, test, lint, or watch command, call the Skill
tool with "toolchain". A repo's own `docs/agents/toolchain.md` overrides it.

## Verification

For anything with runtime behavior (pipelines, notebooks, CLI output), actually
run it: tests verify code correctness, not feature correctness. Say so
explicitly if verification isn't possible in this environment.

- **Read exit codes directly.** A pipe (`| tail`, `| grep`) reports the last
  command's status, so judge pass/fail from an unpiped run or under
  `set -o pipefail`.
- **Refactors carry an equivalence oracle.** Before a behavior-preserving
  change, capture an observable that must not move (test output, a
  deterministic benchmark counter, generated artifacts) and compare after
  each step, not only at the end. Inverted branches, early returns, and
  over-broad guards are the usual casualties of merging functions.
- **Measurements run in the main session.** Before a benchmark, check for
  stray CPU-heavy processes and sandbox limits on core detection. Show raw
  numbers, not a summary, and rerun any figure taken under contention.
- **Before pushing**, run the checks CI will run; the toolchain skill lists
  them per stack.

## Long-running jobs

Before launching a job that may outlive the session (a benchmark suite,
mutation testing, a long CI run), record resume state somewhere durable: the
issue, the PR, or a file. Include the exact command, the commit SHAs, and the
output path, so a fresh session can pick up the analysis. Launch it as a
tracked background task.

## Grounding

- `git fetch` before reasoning about branches, PRs, or issues; trust live
  `gh` state over the local checkout.
- Read a repo's ADRs (`docs/adr/`) and style or voice docs before
  recommending a direction or writing prose for it.
- When a brief's premise is ambiguous (a creative request, an unfamiliar
  domain), state your reading in one line before building on it.

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

## Research order

1. **Vault**: prior decisions and project context (per the trigger above)
2. **Context7**: library and framework documentation
3. **Code intelligence**: navigation and symbols
4. **WebFetch**: known URLs · **WebSearch**: open-ended (personal profile only)
