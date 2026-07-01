#!/bin/sh
# Claude Code status line — mirrors Powerlevel10k p10k-classic style
# Shows: user@host  dir  git  |  model  ctx%

input=$(cat)
e=$(printf '\033')  # real ESC so colors survive being passed as %s args
r="${e}[0m"
sep=" ${e}[90m·${r} "  # gray middot between right-side items

bar() {  # 8-cell ▰▱ bar; literals only — bash 3.2 (/bin/sh) mangles multibyte concat
  n=$(( ($1 * 8 + 50) / 100 )); [ "$n" -gt 8 ] && n=8
  case "$n" in
    0) printf '▱▱▱▱▱▱▱▱';; 1) printf '▰▱▱▱▱▱▱▱';; 2) printf '▰▰▱▱▱▱▱▱';;
    3) printf '▰▰▰▱▱▱▱▱';; 4) printf '▰▰▰▰▱▱▱▱';; 5) printf '▰▰▰▰▰▱▱▱';;
    6) printf '▰▰▰▰▰▰▱▱';; 7) printf '▰▰▰▰▰▰▰▱';; *) printf '▰▰▰▰▰▰▰▰';;
  esac
}

spark() {  # single eighth-block glyph for an integer percent
  n=$(( $1 * 8 / 100 )); [ "$n" -gt 7 ] && n=7
  case "$n" in
    0) printf '▁';; 1) printf '▂';; 2) printf '▃';; 3) printf '▄';;
    4) printf '▅';; 5) printf '▆';; 6) printf '▇';; *) printf '█';;
  esac
}

dir=$(echo "$input" | jq -r '.cwd // empty')
[ -z "$dir" ] && dir=$(pwd)
dir_display="${dir#$HOME}"
[ "$dir_display" != "$dir" ] && dir_display="~$dir_display"

git_info=""
if git -C "$dir" rev-parse --git-dir --no-optional-locks > /dev/null 2>&1; then
  branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    [ -n "$branch" ] && branch="@$branch"
  fi
  if [ -n "$branch" ]; then
    ab=$(git -C "$dir" --no-optional-locks rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)
    arrows=""
    if [ -n "$ab" ]; then
      behind=${ab%%	*}; ahead=${ab##*	}
      [ "$behind" -gt 0 ] 2>/dev/null && arrows="$arrows ⇣$behind"
      [ "$ahead" -gt 0 ] 2>/dev/null && arrows="$arrows ⇡$ahead"
    fi
    if ! git -C "$dir" --no-optional-locks diff --quiet 2>/dev/null || \
       ! git -C "$dir" --no-optional-locks diff --cached --quiet 2>/dev/null; then
      gitcol="${e}[38;5;179m"
      git_info=" ${gitcol}⎇ $branch *$arrows${r}"
    else
      gitcol="${e}[38;5;108m"
      git_info=" ${gitcol}⎇ $branch$arrows${r}"
    fi
  fi
fi

# session (5h) + weekly (7d) usage — present only for Pro/Max after first API response
now=$(date +%s)
usage_block() {  # $1=used%  $2=resets_at_epoch  $3=label
  [ -z "$1" ] && return
  used=${1%%.*}  # ponytail: truncate, statusline doesn't need rounding
  if [ "$used" -ge 90 ]; then c="${e}[31m"
  elif [ "$used" -ge 80 ]; then c="${e}[38;5;208m"
  elif [ "$used" -ge 70 ]; then c="${e}[33m"
  else c="${e}[90m"; fi
  eta=""
  if [ -n "$2" ]; then
    secs=$((${2%.*} - now))
    [ "$secs" -lt 0 ] && secs=0
    d="${e}[38;5;242m"  # darker gray for the ETA
    if [ "$secs" -ge 86400 ]; then eta=" ${d}($((secs / 86400))d $((secs % 86400 / 3600))h)"
    elif [ "$secs" -ge 3600 ]; then eta=" ${d}($((secs / 3600))h)"
    else eta=" ${d}($((secs / 60))m)"; fi
  fi
  printf '%s%s%s%s %s %s%%%s%s' "$sep" "${e}[97m" "$3" "$c" "$(bar "$used")" "$used" "$eta" "$r"
}
sess_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
sess_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
usage_info="$(usage_block "$sess_used" "$sess_reset" ⧖)$(usage_block "$week_used" "$week_reset" ◷)"

model=$(echo "$input" | jq -r '.model.display_name // empty' | sed 's/ (\(.*\) context)/ [\1]/')
model_info=""
[ -n "$model" ] && model_info="${sep}${e}[90m${model}${r}"

remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
ctx_info=""
if [ -n "$remaining" ]; then
  used_int=$((100 - ${remaining%%.*}))  # ponytail: truncate, show used% for consistency
  if [ "$used_int" -ge 90 ]; then c="${e}[31m"
  elif [ "$used_int" -ge 80 ]; then c="${e}[38;5;208m"
  elif [ "$used_int" -ge 70 ]; then c="${e}[33m"
  else c="${e}[90m"; fi
  ctx_info=" ${c}$(spark "$used_int") ${used_int}%${r}"
fi

printf "%s[38;5;67m%s%s%s%s%s%s\n⠀\n" \
  "$e" "$dir_display" "$r" "$git_info" "$usage_info" "$model_info" "$ctx_info"
