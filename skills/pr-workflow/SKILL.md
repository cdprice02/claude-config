---
name: pr-workflow
description: Run the issue-to-merge PR workflow, including multi-PR programs where a dozen or more related PRs land in a deliberate order. Use when starting work on a GitHub issue, opening or reviewing a PR, sequencing a batch of related changes, keeping parallel worktree branches current with main, or deciding merge order. Covers worktree-per-issue setup, branch and PR naming, CI gates, review discipline, and how to keep a program of PRs from rotting.
---

# PR workflow

Issue-driven, worktree-per-issue, every PR based on `main`.

**These are not stacked PRs.** Nothing bases on another PR; every PR targets
`main`. A "PR stack" here means a *program* of related but independently
mergeable PRs landed in a chosen order. That distinction drives everything
below: there is no chain to restack, but there *is* an ordering problem and a
staleness problem.

## Naming

| Thing | Pattern | Example |
|---|---|---|
| Branch | `<type>/issue-<N>-<slug>` | `feat/issue-148-shlex-lexer` |
| Worktree | `../<repo>-worktrees/issue-<N>` | `~/repos/{repo}-worktrees/issue-148` |
| PR title | conventional commit | `feat: history persistence, up/down navigation, and reverse search` |

`type` is one of `feat` `fix` `refactor` `chore` `test` `perf` `docs`, matching
the commit convention. PR titles reference issues inline when several are closed
at once: `perf: lazy iterator pipeline (lexer, parser, resolver) (#118)`.

## Starting work

```bash
gh issue view <N>                                   # read it first
git -C <repo> worktree add ../<repo>-worktrees/issue-<N> -b <type>/issue-<N>-<slug>
```

One worktree per issue keeps parallel work isolated without stashing or
branch-switching. Remove it when the PR merges:

```bash
git worktree remove ../<repo>-worktrees/issue-<N>
git worktree prune
```

`commit-commands:clean_gone` clears branches whose remotes are deleted, along
with their worktrees.

## Opening the PR

Fill the repo's `PULL_REQUEST_TEMPLATE.md`: description with `closes #N`, type
checkbox, and the test checklist. Do not tick a checklist item you have not
actually run.

Reference the issue so it closes on merge. Keep the PR focused: one issue, one
concern. A PR that grew a second concern should be split before review, not
explained away in the description.

## CI gates

Check before requesting review, not after:

```bash
gh pr checks <N>
```

A typical gate set covers `build` and `test` across every platform the repo
targets, plus `lint` and `coverage`. When Windows is one of them, its path
handling is a recurring source of failures that pass locally on macOS; don't
assume a platform is clean without checking its own run.

**Coverage is advisory, not blocking.** A `-0.01%` coverage drop failing the
check is noise; a real drop means tests were not added. Judge which it is rather
than reflexively chasing green.

## Review

Gate merges on real review, not on green CI. Green means it did not break; it
does not mean it is right.

Use `/code-review` for the working diff, `/review` for a PR by number. For a
program of PRs, review each one on its own terms; a batch that gets rubber
stamped because "it's all the same refactor" is where defects hide.

When responding to review: fix the substance, push, and re-request. Do not
resolve a thread you did not actually address.

## Multi-PR programs

The real work is ordering and staleness.

**Order by dependency, then by blast radius.** Land the PR that changes a shared
interface before the ones that consume it. Within an independent set, land the
smallest first: it validates the CI path cheaply and shortens the queue.

**Rebase, do not merge.** Every branch bases on `main`, so as PRs land the others
go stale:

```bash
git -C ../<repo>-worktrees/issue-<N> fetch origin
git -C ../<repo>-worktrees/issue-<N> rebase origin/main
```

Rebase each remaining branch after every merge into `main`, not once at the
end. Deferring means resolving N conflicts at once against a `main` that has
moved N times, which is how a program stalls.

**Re-run CI after every rebase.** A branch that was green against an older `main`
is unverified against the new one. This is the step most often skipped and the
one that produces "it passed in the PR but broke on main."

**Keep the program visible.** Track which PRs are open, merged, and blocked:

```bash
gh pr list --state open --json number,title,headRefName --jq '.[] | "\(.number) \(.headRefName)"'
```

If a PR in the middle turns out to be wrong, close it and renumber the plan
rather than forcing it through to preserve a sequence.

## Merging

Confirm before merging: CI green on the *current* head, review actually done,
issue referenced, description matches what shipped.

Never merge a PR the user asked to hold. "Do not merge N yet, I want real review"
means exactly that even when CI is green and everything else in the program has
landed.
