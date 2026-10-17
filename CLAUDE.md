# CLAUDE.md

Global guidance for Claude Code, loaded every session: keep it short.

> This file lives in a **public** repository. Keep it free of employer names,
> internal project names, hostnames, and infrastructure detail. Anything
> work-specific belongs on the private work branch.

## About me

ML/data engineer by trade (Python); personal projects in Rust, Nix, and a
homelab. Prefer explainable, well-established solutions over marginally
faster ones.

## Writing

No em-dashes, in code, docs, commit messages, or chat; a hook rejects them in
edits. Use a colon, semicolon, comma, parentheses, or restructure the
sentence. This applies when polishing my own writing too.

## Comments

A comment records a durable why: a hidden constraint, invariant, or
workaround, phrased timelessly. Change history, dates, and issue numbers
belong in commits and PRs; what the code visibly does needs no comment.

## Environment

Claude Code runs on macOS, WSL2, Git Bash, and Linux: keep shell snippets
POSIX-portable and paths forward-slashed. `CLAUDE_PROFILE` is `personal`
(subscription auth) or `work` (AWS Bedrock). Bedrock has no `WebSearch` and
no claude.ai connectors: use `WebFetch` against allowlisted domains.

Python tools install with `uv tool install`, never `pip`.

## Skills to call first

- Before a project's build, test, lint, or watch command: `toolchain`. A
  repo's own `docs/agents/toolchain.md` overrides it.
- Before any git commit, branch, or push: `commit`.
- Before writing a skill, a CLAUDE.md, or a per-repo CLAUDE.md:
  `writing-for-agents`. A per-repo CLAUDE.md holds only what that repo does
  differently from this file.

## Verification

For anything with runtime behavior (pipelines, notebooks, CLI output),
actually run it: tests verify code, not the feature. Say so explicitly if
verification isn't possible here.

- **Read exit codes directly.** A pipe reports the last command's status;
  judge pass/fail from an unpiped run or under `set -o pipefail`.
- **Refactors carry an equivalence oracle.** Before a behavior-preserving
  change, capture an observable that must not move (test output, a
  deterministic counter, generated artifacts) and compare after each step.
  Inverted branches, early returns, and over-broad guards are the usual
  casualties of merging functions.
- **Measurements run in the main session.** Check for stray CPU-heavy
  processes and sandbox core limits first. Show raw numbers, and rerun any
  figure taken under contention.
- **Before pushing**, run the checks CI will run; `toolchain` lists them.

## Long-running jobs

Before launching a job that may outlive the session (a benchmark suite,
mutation testing, a long CI run), record resume state durably (issue, PR, or
file): exact command, commit SHAs, output path. Launch it as a tracked
background task and wait with `Monitor`, not sleep loops.

## Grounding

- `git fetch` before reasoning about branches, PRs, or issues; trust live
  `gh` state over the local checkout.
- Read a repo's ADRs (`docs/adr/`) and style or voice docs before
  recommending a direction or writing prose for it.
- When a brief's premise is ambiguous, state your reading in one line before
  building on it.
- Prior context (a project, acronym, past decision, person) lives in the
  Obsidian vault: the `vault` skill. Library docs: Context7.

## Memory

Feedback that applies beyond the current repo belongs here or in a skill, not
in that project's memory: propose the one-line edit instead of saving it.
