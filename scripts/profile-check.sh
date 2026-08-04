#!/usr/bin/env bash
# Assert that profile, config branch, and auth mode agree.
# Wired into settings.json SessionStart. Silent when coherent.
#
# The failure this exists to catch: a work machine ending up on the public
# `main` branch. That is silent (everything still works) but it means work
# sessions run with personal settings, which can point a corporate machine at
# personal endpoints or bill work to a personal subscription. The inverse (a
# personal machine on the work branch) leaks employer config into personal use.
#
# Profiles are separated by BRANCH AND REMOTE, not by settings.local.json:
#   public  cdprice02/claude-config       main   -> personal
#   private cdprice02/claude-config-work  main   -> checked out locally as `work`

set -u

CFG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
PROFILE="${CLAUDE_PROFILE:-personal}"
DRIFT_LIMIT="${CLAUDE_PROFILE_DRIFT_LIMIT:-5}"

command -v git >/dev/null 2>&1 || exit 0
git -C "$CFG_DIR" rev-parse --git-dir >/dev/null 2>&1 || exit 0

BRANCH=$(git -C "$CFG_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")

warn() { printf '\033[1;31m⚠ profile-check: %s\033[0m\n' "$1" >&2; }
note() { printf '\033[2m  %s\033[0m\n' "$1" >&2; }

# --- branch vs profile ------------------------------------------------------
case "$PROFILE:$BRANCH" in
    personal:main | work:work)
        ;;  # coherent
    work:main)
        warn "CLAUDE_PROFILE=work but claude-config is on 'main' (the PUBLIC branch)."
        note "This session is using PERSONAL settings on a work machine."
        note "Fix: git -C $CFG_DIR checkout work   (see user.nix submodules)"
        ;;
    personal:work)
        warn "CLAUDE_PROFILE=personal but claude-config is on the 'work' branch."
        note "Work-specific config is active on a personal machine."
        note "Fix: git -C $CFG_DIR checkout main"
        ;;
    *)
        warn "Unrecognised profile/branch combination: profile=$PROFILE branch=$BRANCH"
        note "Expected personal:main or work:work."
        ;;
esac

# --- auth mode vs profile ---------------------------------------------------
# Work runs on Bedrock; personal on the Claude subscription. A mismatch means
# either work is billing a personal subscription, or personal is pointed at an
# employer AWS account.
BEDROCK="${CLAUDE_CODE_USE_BEDROCK:-}"
if [ "$PROFILE" = "work" ] && [ -z "$BEDROCK" ]; then
    warn "CLAUDE_PROFILE=work but CLAUDE_CODE_USE_BEDROCK is unset."
    note "Work sessions should authenticate through Bedrock, not the subscription."
elif [ "$PROFILE" = "personal" ] && [ -n "$BEDROCK" ]; then
    warn "CLAUDE_PROFILE=personal but CLAUDE_CODE_USE_BEDROCK is set."
    note "Personal sessions should use the subscription."
fi

# --- work branch staleness --------------------------------------------------
# Shared changes flow public main -> private work by merge. Without a cadence
# the work branch silently rots; it has happened before.
if [ "$BRANCH" = "work" ]; then
    git -C "$CFG_DIR" fetch --quiet origin main >/dev/null 2>&1
    if git -C "$CFG_DIR" rev-parse --verify -q origin/main >/dev/null 2>&1; then
        behind=$(git -C "$CFG_DIR" rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
        if [ "${behind:-0}" -gt "$DRIFT_LIMIT" ]; then
            warn "work branch is $behind commits behind origin/main."
            note "Merge shared changes: git -C $CFG_DIR merge origin/main"
        fi
    fi
fi

exit 0
