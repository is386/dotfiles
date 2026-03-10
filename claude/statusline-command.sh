#!/bin/bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
model=$(echo "$input" | jq -r '.model.id')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage | select(. != null)')

folder=$(basename "$cwd")

branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null)
fi

pct=${used_pct:-0}
filled=$(echo "$pct" | awk '{printf "%d", ($1 / 100 * 12 + 0.5)}')
empty=$((12 - filled))
bar_inner=""
for i in $(seq 1 "$filled"); do bar_inner="${bar_inner}▰"; done
for i in $(seq 1 "$empty");  do bar_inner="${bar_inner}▱"; done
pct_int=$(echo "$pct" | awk '{printf "%d", $1}')
bar="${bar_inner} ${pct_int}%"

GREEN=$'\033[32m'
CYAN=$'\033[36m'
MAGENTA=$'\033[35m'
BLUE=$'\033[34m'
RESET=$'\033[0m'

parts="${BLUE}${USER}${RESET} ${GREEN}${folder}${RESET}"

if [ -n "$branch" ]; then
  parts="${parts} ${CYAN}[${branch}]${RESET}"
fi

parts="${parts} ${MAGENTA}(${model} ${bar})${RESET}"

printf '%s' "${parts}"
