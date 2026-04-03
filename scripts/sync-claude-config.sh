#!/usr/bin/env bash
# sync-claude-config.sh — Sync .claude/ config from origin/main into current worktree
# Usage: bash scripts/sync-claude-config.sh [worktree_path]
#
# Reads commands, rules, agents, and settings directly from origin/main via git.
# Ensures worktrees always get the authoritative remote state.

set -euo pipefail

WORKTREE_PATH="${1:-.}"
WORKTREE_LIST="$(git -C "$WORKTREE_PATH" worktree list --porcelain)"
MAIN_REPO="$(echo "$WORKTREE_LIST" | head -1 | sed 's/worktree //')"

if [ -z "$MAIN_REPO" ]; then
  echo '{"error": "Could not determine main repo path"}'
  exit 1
fi

if [ "$(cd "$WORKTREE_PATH" && pwd)" = "$(cd "$MAIN_REPO" && pwd)" ]; then
  echo '{"status": "skip", "reason": "Not in a worktree — already on main repo"}'
  exit 0
fi

WT_CLAUDE="$WORKTREE_PATH/.claude"

if ! git -C "$MAIN_REPO" rev-parse origin/main >/dev/null 2>&1; then
  echo '{"error": "origin/main not reachable — run git fetch first"}'
  exit 1
fi

SYNC_DIRS=("commands" "rules" "agents")
added=0
updated=0
removed=0
changes=()

for dir in "${SYNC_DIRS[@]}"; do
  DST="$WT_CLAUDE/$dir"
  mkdir -p "$DST"

  remote_files_raw="$(git -C "$MAIN_REPO" ls-tree --name-only "origin/main:.claude/$dir" 2>/dev/null || true)"
  if [ -z "$remote_files_raw" ]; then continue; fi

  while IFS= read -r fname; do
    [ -z "$fname" ] && continue
    local_path="$DST/$fname"
    remote_content="$(git -C "$MAIN_REPO" show "origin/main:.claude/$dir/$fname" 2>/dev/null)"
    if [ ! -f "$local_path" ]; then
      printf '%s\n' "$remote_content" > "$local_path"
      changes+=("+ $dir/$fname")
      ((added++)) || true
    else
      local_content="$(cat "$local_path")"
      if [ "$remote_content" != "$local_content" ]; then
        printf '%s\n' "$remote_content" > "$local_path"
        changes+=("~ $dir/$fname")
        ((updated++)) || true
      fi
    fi
  done <<< "$remote_files_raw"

  for f in "$DST"/*; do
    [ -f "$f" ] || continue
    fname="$(basename "$f")"
    if ! echo "$remote_files_raw" | grep -qx "$fname"; then
      rm "$f"
      changes+=("- $dir/$fname")
      ((removed++)) || true
    fi
  done
done

remote_settings="$(git -C "$MAIN_REPO" show "origin/main:.claude/settings.json" 2>/dev/null || true)"
if [ -n "$remote_settings" ]; then
  if [ ! -f "$WT_CLAUDE/settings.json" ] || [ "$remote_settings" != "$(cat "$WT_CLAUDE/settings.json")" ]; then
    echo "$remote_settings" > "$WT_CLAUDE/settings.json"
    changes+=("~ settings.json")
    ((updated++)) || true
  fi
fi

total=$((added + updated + removed))
changes_json="[]"
if [ ${#changes[@]} -gt 0 ]; then
  changes_json="["
  first=true
  for c in "${changes[@]}"; do
    if [ "$first" = true ]; then first=false; else changes_json+=","; fi
    changes_json+="\"$c\""
  done
  changes_json+="]"
fi

cat <<EOJSON
{"status": "ok", "added": $added, "updated": $updated, "removed": $removed, "total": $total, "changes": $changes_json}
EOJSON
