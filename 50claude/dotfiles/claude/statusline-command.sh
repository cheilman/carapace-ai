#!/usr/bin/env bash
# Claude Code status line - mirrors p10k prompt elements:
# context (user@hostname), dir (cwd), vcs (git branch), model, context usage

input=$(cat)

user=$(whoami)
host=$(hostname -s)
cwd=$(echo "$input" | jq -r '.cwd')

# Git branch (mirroring p10k vcs element) - skip optional locks to avoid stalling
git_branch=""
if git -C "$cwd" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

# Model and context window usage
model=$(echo "$input" | jq -r '.model.display_name')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Build status line with ANSI colors
printf "\033[1;32m%s@%s\033[0m:\033[1;34m%s\033[0m" "$user" "$host" "$cwd"

if [ -n "$git_branch" ]; then
  printf " \033[1;33m(%s)\033[0m" "$git_branch"
fi

printf " | %s" "$model"

if [ -n "$ctx_pct" ]; then
  printf " | ctx: %.0f%%" "$ctx_pct"
fi
