# claude-config

Personal Claude Code configuration, synced across machines via git.

> **Profiles are separated by branch and remote, not by settings files.**
> Public `main` (this repo) is the personal profile and the shared base.
> A private `claude-config-work` repo holds the work overlay, checked out on
> work machines as a local `work` branch tracking `private/main`. Nothing
> employer-specific (hostnames, internal project names, endpoints) may land
> here. `scripts/profile-check.sh` warns when a machine is on the wrong branch.

## What's tracked

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Global instructions loaded every session, kept deliberately thin |
| `PROJECT_TEMPLATE.md` | Scaffold for per-repo CLAUDE.md files |
| `settings.json` | Permissions, hooks, plugins, model, env |
| `skills/*/SKILL.md` | On-demand skills (see below) |
| `scripts/` | Hook scripts, see Hooks |

Not tracked: session data, logs, file history, plugin caches, `plans/`.
The `.gitignore` is **deny-by-default** (`*` plus an explicit allowlist), so a
new file is ignored unless deliberately permitted.

## Skills

Loaded on demand: only the one-line description enters context until invoked.

Most skills come from `config/skills`, a sibling submodule this repo's
`skills/` symlinks into: a personal fork of
[mattpocock/skills](https://github.com/mattpocock/skills), a fourth submodule
alongside `claude/` (this repo), `copilot/`, and `git/gitalias/` in the parent
nix-config repo. They're linked in as plain user skills, not a plugin, via
relative symlinks that `just link-skills` (in nix-config's `justfile`)
generates for every `SKILL.md` under `config/skills/skills/{engineering,
productivity, atelier}/`, e.g. `skills/tdd -> ../../skills/skills/engineering/tdd`.
Linking them as bare names matters: the fork's own skills call each other by
bare name internally (`/tdd`, not `/mattpocock-skills:tdd`), and a plugin
namespace would break those references.

To update: `git -C config/skills fetch upstream && git merge upstream/main`,
then re-run `just link-skills` from nix-config to pick up any new, renamed, or
removed skills.

The fork carries one local-only addition upstream doesn't have: an `atelier/`
bucket, currently just `toolchain` (a build/test/lint command lookup table for
Rust/Python/Node). It's a separate bucket rather than folded into
`engineering/` because upstream's contribution rules require anything under
`engineering/`/`productivity/` to also get entries in several other files
upstream itself edits on nearly every release; a bucket upstream has never
heard of sidesteps that merge-conflict surface entirely.

`vault` remains a real, non-forked skill living directly in this repo,
untouched by any of the above. `pr-workflow` is gone: fully superseded by the
fork's `to-tickets`, `implement`, and `code-review`.

## MCP servers

**None are configured locally.** This is deliberate.

- The **vault** is read from the filesystem. Obsidian Sync puts it on every
  machine, so `Grep`/`Glob`/`Read` work directly at zero MCP token cost.
  `env.OBSIDIAN_VAULT` is the portability seam for scripts and skill
  instructions, since a shell env var can hold a path that differs per
  machine. Permission-rule paths (`additionalDirectories`, the vault `deny`
  entries) cannot reference an env var; Claude Code's permission syntax has
  no interpolation, so they hardcode the `~/repos/obsidian` convention
  directly. If the vault ever lives somewhere else, those entries need a
  manual update and will not follow `$OBSIDIAN_VAULT`. An earlier
  `mcp-obsidian` server did this same job over MCP and was retired once the
  filesystem approach proved equivalent at zero token cost. A second server,
  `localdata-mcp`, was removed outright for an unrelated reason: it sat in
  `settings.json` for months referencing a binary that was never actually
  installed.
- **Account-level claude.ai connectors** (Context7, Drive, Gmail, Calendar) do
  surface inside Claude Code, but only on the personal profile. **Bedrock auth
  has no claude.ai session, so work machines get none of them, and no
  WebSearch either.** The work branch must restore what matters as plugins.
- A **remote MCP connector** covers the same vault for surfaces that cannot
  reach a filesystem: mobile, claude.ai web, Desktop. Claude Code does not
  use it; the deployment lives outside this repo, in private infrastructure.

## Plugins

| Plugin | Purpose |
|---|---|
| `skill-creator` | Create and iterate on skills |
| `rust-analyzer-lsp` | Rust language server integration |

Plugins are enabled directly in `settings.json`'s `enabledPlugins`; nothing
installs them at session start any more (see Hooks).

## Hooks

| Event | Script | What |
|---|---|---|
| SessionStart | `profile-check.sh` | Asserts profile, branch and auth mode agree. Silent when coherent, loud on mismatch. Runs first. |
| SessionStart | `session-start.sh` | Banner: path, branch, dirty count, profile |
| PostToolUse | `format-on-edit.sh` | `ruff` / `rustfmt` / JuliaFormatter by extension |
| PostToolUse | `clippy-on-edit.sh` | `cargo clippy` for `.rs` |

There used to be a third SessionStart hook, `bootstrap.sh`, that installed any
plugin missing from `PLUGINS` on a fresh machine. It was removed: the premise
was disproved on this very machine, where `rust-analyzer-lsp` was enabled and
working without ever being listed in the script. Plugins now install through
`enabledPlugins` alone, no bootstrap step required.

`statusline.sh` is the status line: reads `COLUMNS` for width and counts
characters rather than bytes (the bars are multi-byte UTF-8).

## Setup on a new machine

```bash
# If ~/.claude doesn't exist yet
git clone git@github.com:cdprice02/claude-config.git ~/.claude

# If Claude Code already created ~/.claude
cd ~/.claude
git init && git remote add origin git@github.com:cdprice02/claude-config.git
git fetch && git checkout -b main --track origin/main
```

On a [nix-config](https://github.com/cdprice02/nix-config)-managed machine this
is automatic: `~/.claude` is an out-of-store symlink to `config/claude`, and
`user.nix`'s `submodules` block wires the private remote on work machines.

This repo needs no secrets of its own. If a future plugin or connector needs
one, the convention is `~/.config/secrets/env`, sourced by shell init; see
nix-config's `secrets.env.example` for the template.

## Syncing

```bash
cd ~/.claude && git pull && git add -p && git commit && git push
```

On work machines, propagate shared changes from public `main` with
`just sync-work` in nix-config.
