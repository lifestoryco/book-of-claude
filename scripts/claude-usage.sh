#!/usr/bin/env bash
# Claude Code Usage — fetch utilization, calculate pacing, render markdown dashboard
set -euo pipefail

# --- Token ---
TOKEN="${CLAUDE_CODE_OAUTH_TOKEN:-}"
if [[ -z "$TOKEN" ]]; then
  TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken // empty') || true
fi
if [[ -z "${TOKEN:-}" ]]; then
  echo "**ERROR:** No OAuth token. Run \`claude login\` or launch from Claude Desktop."
  exit 1
fi

# --- Fetch ---
R=$(curl -s --max-time 5 "https://api.anthropic.com/api/oauth/usage" \
  -H "Authorization: Bearer $TOKEN" \
  -H "anthropic-beta: oauth-2025-04-20") || true

if [[ -z "${R:-}" ]] || ! echo "$R" | jq -e . >/dev/null 2>&1; then
  echo "**ERROR:** API request failed."; exit 1
fi
if echo "$R" | jq -e '.error' >/dev/null 2>&1; then
  echo "**ERROR:** $(echo "$R" | jq -r '.error.message // .error // "unknown"')"; exit 1
fi

# --- Helpers ---
now=$(date +%s)

parse_epoch() {
  local ts="$1"
  ts="${ts%%.*}"; ts="${ts%%+*}"
  if [[ "$(uname)" == "Darwin" ]]; then
    date -j -u -f "%Y-%m-%dT%H:%M:%S" "$ts" +%s 2>/dev/null || echo "$now"
  else
    date -u -d "${ts/T/ }" +%s 2>/dev/null || echo "$now"
  fi
}

fmt_duration() {
  local s=$1 d h m
  d=$((s / 86400)); h=$(( (s % 86400) / 3600 )); m=$(( (s % 3600) / 60 ))
  local out=""
  [[ $d -gt 0 ]] && out="${d}d "
  [[ $h -gt 0 || $d -gt 0 ]] && out="${out}${h}h "
  echo "${out}${m}m"
}

fmt_clock() {
  if [[ "$(uname)" == "Darwin" ]]; then
    date -j -f "%s" "$1" "+%a %-I:%M %p" 2>/dev/null || echo "?"
  else
    date -d "@$1" "+%a %-I:%M %p" 2>/dev/null || echo "?"
  fi
}

bar() {
  local util=$1 pace=$2
  local fill=$(( (util + 2) / 5 ))
  local pace_pos=$(( (pace + 2) / 5 ))
  [[ $fill -gt 20 ]] && fill=20
  [[ $pace_pos -gt 20 ]] && pace_pos=20

  local bar=""
  for ((i=0; i<20; i++)); do
    if [[ $i -eq $pace_pos ]] && (( (pace_pos - fill >= 2) || (fill - pace_pos >= 2) )); then
      bar="${bar}│"
    elif [[ $i -lt $fill ]]; then
      bar="${bar}█"
    else
      bar="${bar}░"
    fi
  done
  echo "$bar"
}

render_meter() {
  local name="$1" util_raw="$2" resets_at="$3" total_hours="$4"
  if [[ "$util_raw" == "null" ]]; then return; fi
  local util=${util_raw%.*}
  local total_s=$((total_hours * 3600))
  local reset_epoch
  reset_epoch=$(parse_epoch "$resets_at")
  local remaining=$(( reset_epoch - now ))
  [[ $remaining -lt 0 ]] && remaining=0
  local elapsed=$(( total_s - remaining ))
  [[ $elapsed -lt 0 ]] && elapsed=0
  [[ $elapsed -gt $total_s ]] && elapsed=$total_s

  local pace_pct="0.0"
  if [[ $total_s -gt 0 ]]; then
    pace_pct=$(echo "scale=1; $elapsed * 100 / $total_s" | bc)
  fi
  [[ "$pace_pct" == .* ]] && pace_pct="0$pace_pct"
  local pace_int=${pace_pct%.*}

  local diff_val
  diff_val=$(echo "scale=1; $util_raw - $pace_pct" | bc)
  [[ "$diff_val" == .* ]] && diff_val="0$diff_val"
  [[ "$diff_val" == -.* ]] && diff_val="-0${diff_val#-}"

  local abs_diff
  abs_diff=$(echo "scale=1; val=$diff_val; if (val<0) val=-val; val" | bc)
  [[ "$abs_diff" == .* ]] && abs_diff="0$abs_diff"
  local time_diff_s
  time_diff_s=$(echo "scale=0; $abs_diff * $total_s / 100" | bc)

  local is_over=0 direction sign dot
  if echo "$diff_val" | grep -q '^-'; then
    direction="under pace"; sign=""; dot="✅"
  else
    direction="over pace"; sign="+"; dot="⚠️"; is_over=1
  fi

  local progress
  progress=$(bar "$util" "$pace_int")
  local reset_clock
  reset_clock=$(fmt_clock "$reset_epoch")

  echo "${dot} **${name}** — \`${util_raw}%\` used"
  echo "\`${progress}\` ${sign}${diff_val}% ${direction} ($(fmt_duration "$time_diff_s"))"
  echo "Resets in $(fmt_duration "$remaining") — *${reset_clock}*"
  echo

  return $is_over
}

# --- Extract ---
w_u=$(echo "$R" | jq -r '.seven_day.utilization // "null"')
w_r=$(echo "$R" | jq -r '.seven_day.resets_at // "null"')
s_u=$(echo "$R" | jq -r '.five_hour.utilization // "null"')
s_r=$(echo "$R" | jq -r '.five_hour.resets_at // "null"')
n_u=$(echo "$R" | jq -r '.seven_day_sonnet.utilization // "null"')
n_r=$(echo "$R" | jq -r '.seven_day_sonnet.resets_at // "null"')

if [[ "$w_u" == "null" && "$s_u" == "null" && "$n_u" == "null" ]]; then
  echo "No active meters. Run \`claude login\` to authenticate."
  exit 0
fi

# --- Render ---
echo "## BURN RATE"
echo

render_meter "Session" "$s_u" "$s_r" 5 || true
render_meter "Week" "$w_u" "$w_r" 168 || true

if [[ "$n_u" != "null" ]]; then
  SONNET_OUT=$(render_meter "Sonnet" "$n_u" "$n_r" 168)
  sonnet_over=$?
  if [[ $sonnet_over -eq 1 ]]; then
    echo "$SONNET_OUT"
  else
    echo "✅ **Sonnet** — \`${n_u}%\` · under pace"
    echo
  fi
fi

w_int=${w_u%.*}; s_int=${s_u%.*}
if [[ "$w_int" -ge "$s_int" ]]; then
  tightest="Week"; headroom=$((100 - w_int))
else
  tightest="Session"; headroom=$((100 - s_int))
fi
if [[ $headroom -le 15 ]]; then
  echo "⚠️ **${tightest}** is your bottleneck — ${headroom}% headroom"
fi

echo "---"
