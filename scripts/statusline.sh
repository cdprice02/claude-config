#!/usr/bin/env bash
# Fast statusline for Claude Code - reads JSON from stdin
# Styling matches starship.toml configuration
set -euo pipefail

# ANSI color codes (matching starship)
GREEN='\033[1;32m'    # bold green
RED='\033[1;31m'      # bold red
YELLOW='\033[1;33m'   # bold yellow
CYAN='\033[1;36m'     # bold cyan
BLUE='\033[1;34m'     # bold blue
WHITE='\033[1;37m'    # bold white (for profile)
MAGENTA='\033[35m'    # magenta (for cache %)
DIM='\033[2m'         # dim/gray
RESET='\033[0m'       # reset

# Bar configuration
CONTEXT_BAR_WIDTH=8
RATE_LIMIT_BAR_WIDTH=8

# Assumed terminal width (cannot detect accurately in piped context)
# NOTE: Requires monospace terminal font for proper alignment
ASSUMED_TERM_WIDTH=160

# Read JSON input from stdin
input=$(cat)

# Helper function: format large numbers (pure bash, no bc needed)
format_number() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        local whole=$((num / 1000000))
        local frac=$(( (num % 1000000) / 100000 ))
        printf "%d.%dM" "$whole" "$frac"
    elif [ "$num" -ge 1000 ]; then
        local whole=$((num / 1000))
        local frac=$(( (num % 1000) / 100 ))
        printf "%d.%dk" "$whole" "$frac"
    else
        printf "%d" "$num"
    fi
}

# Helper function: format duration (milliseconds to human-readable)
format_duration() {
    local ms=$1
    local seconds=$((ms / 1000))
    local minutes=$((seconds / 60))
    local hours=$((minutes / 60))

    if [ "$hours" -gt 0 ]; then
        printf "%dh%dm" "$hours" "$((minutes % 60))"
    elif [ "$minutes" -gt 0 ]; then
        printf "%dm%ds" "$minutes" "$((seconds % 60))"
    else
        printf "%ds" "$seconds"
    fi
}

# Helper function: create progress bar with quarter-block precision and tall container
create_bar() {
    local pct=$1
    local width=$2

    # Calculate filled blocks with quarter-block precision (scaled by 4)
    local filled_scaled=$(( (pct * width * 4) / 100 ))
    local filled=$((filled_scaled / 4))
    local quarter=$((filled_scaled % 4))

    # Edge case rounding: show progress even when very low/high
    # If pct > 0 but filled would be 0, show at least quarter block
    if [ "$filled" -eq 0 ] && [ "$quarter" -eq 0 ] && [ "$(printf "%.0f" "$pct")" != "0" ]; then
        quarter=1
    fi
    # If pct < 100 but would fill entire bar, ensure at least quarter empty
    local total_filled=$((filled * 4 + quarter))
    if [ "$total_filled" -ge $((width * 4)) ] && [ "$(printf "%.0f" "$pct")" != "100" ]; then
        filled=$((width - 1))
        quarter=3
    fi

    local bar=""
    local i

    # Add full blocks
    for ((i=0; i<filled; i++)); do
        bar="${bar}█"
    done

    # Add partial block based on quarter value
    if [ "$quarter" -eq 1 ]; then
        bar="${bar}▎"  # 1/4 filled
        filled=$((filled + 1))
    elif [ "$quarter" -eq 2 ]; then
        bar="${bar}▌"  # 1/2 filled
        filled=$((filled + 1))
    elif [ "$quarter" -eq 3 ]; then
        bar="${bar}▊"  # 3/4 filled
        filled=$((filled + 1))
    fi

    # Add spaces for empty portion
    local empty=$((width - filled))
    for ((i=0; i<empty; i++)); do
        bar="${bar} "
    done

    # Wrap in tall container (using box-drawing characters)
    printf "│%s│" "$bar"
}

# Extract baseline fields with jq
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
raw_cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir')
cwd=$(basename "$raw_cwd")
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
ctx_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# Calculate cache hit rate (pure bash arithmetic)
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
regular_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
total_cache_eligible=$((cache_read + cache_create + regular_input))
if [ "$total_cache_eligible" -gt 0 ]; then
    # Calculate percentage with one decimal place using integer math
    cache_hit_rate=$(( (cache_read * 1000) / total_cache_eligible ))
    cache_hit_whole=$((cache_hit_rate / 10))
    cache_hit_frac=$((cache_hit_rate % 10))
    cache_hit_rate="${cache_hit_whole}.${cache_hit_frac}"
else
    cache_hit_rate="0.0"
fi

# Get git info (branch, ahead/behind, stash count, uncommitted changes)
branch=""
sync_status=""
stash_status=""
lines_added=0
lines_removed=0
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")

    # Git sync status (ahead/behind remote) - starship format
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        # Get ahead/behind counts (POSIX-compatible)
        ahead_behind=$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null || echo "0	0")
        ahead=$(echo "$ahead_behind" | awk '{print $1}')
        behind=$(echo "$ahead_behind" | awk '{print $2}')

        # Format like starship: ⇡N ⇣N or ⇕⇡N⇣N for diverged
        if [ "$ahead" != "0" ] && [ "$behind" != "0" ]; then
            sync_status="⇕⇡${ahead}⇣${behind}"
        elif [ "$ahead" != "0" ]; then
            sync_status="⇡${ahead}"
        elif [ "$behind" != "0" ]; then
            sync_status="⇣${behind}"
        fi
    fi

    # Stash count - starship format: $N
    stash_count=$(git stash list 2>/dev/null | wc -l | awk '{print $1}')
    if [ "$stash_count" != "0" ]; then
        stash_status="\$${stash_count}"
    fi

    # Get staged + unstaged changes (line counts)
    # Combine unstaged and staged diffs
    unstaged_stat=$(git diff --shortstat 2>/dev/null || echo "")
    staged_stat=$(git diff --cached --shortstat 2>/dev/null || echo "")

    # Parse unstaged changes
    if [ -n "$unstaged_stat" ]; then
        unstaged_added=$(echo "$unstaged_stat" | sed -n 's/.* \([0-9]\+\) insertion.*/\1/p')
        unstaged_removed=$(echo "$unstaged_stat" | sed -n 's/.* \([0-9]\+\) deletion.*/\1/p')
        lines_added=$((lines_added + ${unstaged_added:-0}))
        lines_removed=$((lines_removed + ${unstaged_removed:-0}))
    fi

    # Parse staged changes
    if [ -n "$staged_stat" ]; then
        staged_added=$(echo "$staged_stat" | sed -n 's/.* \([0-9]\+\) insertion.*/\1/p')
        staged_removed=$(echo "$staged_stat" | sed -n 's/.* \([0-9]\+\) deletion.*/\1/p')
        lines_added=$((lines_added + ${staged_added:-0}))
        lines_removed=$((lines_removed + ${staged_removed:-0}))
    fi
fi

# Format context tokens and create bar
ctx_tokens_fmt=$(format_number "$ctx_tokens")
ctx_pct_int=$(printf "%.0f" "$ctx_pct")
ctx_bar=$(create_bar "$ctx_pct_int" "$CONTEXT_BAR_WIDTH")

# Detect profile from env var
profile="${CLAUDE_PROFILE:-unknown}"

# Get profile-specific metrics
if [ "$profile" = "personal" ]; then
    # Claude Pro rate limits with bars
    session_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0')
    weekly_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // 0')

    # Convert to integer and create bars
    session_pct_int=$(printf "%.0f" "$session_pct" 2>/dev/null || echo "0")
    weekly_pct_int=$(printf "%.0f" "$weekly_pct" 2>/dev/null || echo "0")

    # Color bars based on usage
    if [ "$session_pct_int" -lt 50 ]; then
        session_color="$GREEN"
    elif [ "$session_pct_int" -lt 80 ]; then
        session_color="$YELLOW"
    else
        session_color="$RED"
    fi

    if [ "$weekly_pct_int" -lt 50 ]; then
        weekly_color="$GREEN"
    elif [ "$weekly_pct_int" -lt 80 ]; then
        weekly_color="$YELLOW"
    else
        weekly_color="$RED"
    fi

    session_bar=$(create_bar "$session_pct_int" "$RATE_LIMIT_BAR_WIDTH")
    weekly_bar=$(create_bar "$weekly_pct_int" "$RATE_LIMIT_BAR_WIDTH")

    profile_metrics="5h: ${session_color}$(printf "%.1f%%" "$session_pct")${RESET} ${session_color}${session_bar}${RESET} 7d: ${weekly_color}$(printf "%.1f%%" "$weekly_pct")${RESET} ${weekly_color}${weekly_bar}${RESET}"
elif [ "$profile" = "work" ]; then
    # Session cost
    cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
    profile_metrics=$(printf "${YELLOW}\$%.3f${RESET}" "$cost")
else
    profile_metrics=""
fi

# Format and print output (single line, minimal context info)
# Color context percentage and bar: green < 50%, yellow 50-80%, red >= 80%
if [ "$ctx_pct_int" -lt 50 ]; then
    ctx_color="$GREEN"
elif [ "$ctx_pct_int" -lt 80 ]; then
    ctx_color="$YELLOW"
else
    ctx_color="$RED"
fi

# Color the context bar based on percentage
ctx_bar_colored="${ctx_color}${ctx_bar}${RESET}"

# Build primary info (left side)
primary="${CYAN}${model}${RESET} ${BLUE}${cwd}${RESET}"
if [ -n "$branch" ]; then
    # Combine sync and stash status
    git_status=""
    [ -n "$stash_status" ] && git_status="${git_status}${stash_status}"
    [ -n "$sync_status" ] && git_status="${sync_status}"

    git_info="${GREEN}${branch}${RESET}"
    [ -n "$git_status" ] && git_info="$git_info ${YELLOW}${git_status}${RESET}"

    # Show line changes (velocity) - dim when zero, colored when non-zero
    if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
        git_info="$git_info ${DIM}(${RESET}${GREEN}+${lines_added}${RESET}${DIM}/${RESET}${RED}-${lines_removed}${RESET}${DIM})${RESET}"
    else
        git_info="$git_info ${DIM}(+0/-0)${RESET}"
    fi

    primary="$primary ${DIM}|${RESET} $git_info"
fi

# Build secondary info (right side) - profile, metrics, context
secondary="${WHITE}${profile}${RESET}"
if [ -n "$profile_metrics" ]; then
    secondary="$secondary ${DIM}|${RESET} ${profile_metrics}"
fi
secondary="$secondary ${DIM}|${RESET} ${ctx_color}$(printf "%.1f%%" "$ctx_pct")${RESET} ${ctx_bar_colored} ${DIM}${ctx_tokens_fmt}${RESET}"

# Calculate exact space padding to fit assumed terminal width
# Strip ANSI codes to get actual display length
primary_plain=$(printf "%b" "$primary" | sed 's/\x1b\[[0-9;]*m//g')
secondary_plain=$(printf "%b" "$secondary" | sed 's/\x1b\[[0-9;]*m//g')
primary_len=$(printf "%s" "$primary_plain" | wc -c | awk '{print $1}')
secondary_len=$(printf "%s" "$secondary_plain" | wc -c | awk '{print $1}')

# Calculate exact spacing needed
spaces_needed=$((ASSUMED_TERM_WIDTH - primary_len - secondary_len - 2))

# Ensure non-negative
if [ "$spaces_needed" -lt 0 ]; then
    spaces_needed=1
fi

# Build spaces string
spaces=$(printf "%${spaces_needed}s" "")

# Print single line with exact space padding
printf " %b%s%b\n" "$primary" "$spaces" "$secondary"
