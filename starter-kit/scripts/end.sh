#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# Session End Script  v3.1
#
# Usage:  bash scripts/end.sh "$PWD"
#         bash scripts/end.sh [session-name]
#
# Fast: validate → summarize → rebase → push → done.
# v3.1: Fixes main working tree drift after update-ref.
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

# ── Resolve main repo root ────────────────────────────────────────────────
REPO_ROOT=$(git worktree list --porcelain 2>/dev/null | awk 'NR==1 { print substr($0, 10) }')
[ -z "$REPO_ROOT" ] && REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKTREE_BASE="$REPO_ROOT/.claude/worktrees"

# ── Detect session ────────────────────────────────────────────────────────
CALLER_ARG="${1:-}"
SESSION_NAME=""

if [[ "$CALLER_ARG" == "$WORKTREE_BASE/"* ]] && [ -d "$CALLER_ARG" ]; then
  SESSION_NAME="$(basename "$CALLER_ARG")"
elif [ -n "$CALLER_ARG" ] && [[ "$CALLER_ARG" != "/"* ]]; then
  SESSION_NAME="$CALLER_ARG"
elif [[ "$(pwd)" == "$WORKTREE_BASE/"* ]]; then
  SESSION_NAME="$(basename "$(pwd)")"
else
  printf "  \033[0;31m❌\033[0m Cannot detect session. Usage: bash scripts/end.sh \"\$PWD\"\n"
  exit 1
fi

BRANCH="claude/$SESSION_NAME"
WT="$WORKTREE_BASE/$SESSION_NAME"

# ── Helpers ───────────────────────────────────────────────────────────────
ok()   { printf "  \033[0;32m✅\033[0m %s\n" "$*"; }
warn() { printf "  \033[1;33m⚠️\033[0m  %s\n" "$*"; }
err()  { printf "  \033[0;31m❌\033[0m %s\n" "$*"; }

# ── Preflight ─────────────────────────────────────────────────────────────
printf "\n═══════════════════════════════════════════════\n"
printf "  \033[1mEnding session:\033[0m %s\n" "$SESSION_NAME"
printf "═══════════════════════════════════════════════\n\n"

[ ! -d "$WT" ] && err "Worktree not found: $WT" && exit 1
git rev-parse --verify "$BRANCH" &>/dev/null || { err "Branch not found: $BRANCH"; exit 1; }
cd "$WT"

# ── 1. Working tree must be clean ────────────────────────────────────────
printf "[1/6] Working tree check...\n"
if ! git diff --quiet || ! git diff --cached --quiet; then
  err "Uncommitted changes. Commit or stash first."
  git status --short
  exit 1
fi
UNTRACKED=$(git ls-files --others --exclude-standard | wc -l | tr -d '[:space:]')
ok "Working tree clean"
if [ "${UNTRACKED:-0}" -gt 0 ] 2>/dev/null; then
  warn "$UNTRACKED untracked file(s) won't be merged:"
  git ls-files --others --exclude-standard | head -5 | sed 's/^/     /'
fi

# ── 2. Validate state file was updated (optional) ────────────────────────
printf "\n[2/6] Validating state file...\n"
STATE_FILE="$WT/docs/state/project-state.md"
BASE=""
[ -f "$WT/.session-base-commit" ] && BASE=$(cat "$WT/.session-base-commit")
[ -z "$BASE" ] && BASE=$(git merge-base "$BRANCH" main 2>/dev/null || git rev-parse main)

if [ -f "$STATE_FILE" ]; then
  STATE_CHANGED=$(git log --oneline "$BASE..HEAD" -- docs/state/project-state.md 2>/dev/null | wc -l | tr -d '[:space:]')
  if [ "${STATE_CHANGED:-0}" -eq 0 ] 2>/dev/null; then
    warn "project-state.md NOT updated this session (recommended but not required)"
  else
    ok "project-state.md updated"
  fi
else
  ok "No state file — skipping validation"
fi

# ── 3. Session summary ──────────────────────────────────────────────────
printf "\n[3/6] Session summary...\n"
COMMIT_COUNT=$(git rev-list --count "$BASE..$BRANCH" 2>/dev/null || printf '0')
HEAD_HASH=$(git rev-parse HEAD)
FILES_CHANGED=$(git diff --stat "$BASE..HEAD" 2>/dev/null | tail -1 | sed 's/,/·/g' | tr -d '\n')

ok "Commits: $COMMIT_COUNT  |  Base→Head: ${BASE:0:7}→${HEAD_HASH:0:7}"
ok "Files: ${FILES_CHANGED:-none}"
printf "\n  \033[1mCommit log:\033[0m\n"
git log --oneline "$BASE..HEAD" 2>/dev/null | sed 's/^/    /' || true

# Empty session — clean up and exit
if [ "$COMMIT_COUNT" = "0" ]; then
  printf "\n"
  warn "No commits — cleaning up empty session."
  cd "$REPO_ROOT"
  git worktree remove "$WT" --force 2>/dev/null || true
  git branch -d "$BRANCH" 2>/dev/null || true
  ok "Empty session removed."
  exit 0
fi

# ── 4. Fetch + rebase onto origin/main ───────────────────────────────────
printf "\n[4/6] Rebase onto origin/main...\n"
cd "$REPO_ROOT"
git fetch origin main --quiet 2>/dev/null || warn "fetch failed (offline?)"
cd "$WT"
REMOTE_MAIN=$(git rev-parse origin/main 2>/dev/null || git rev-parse main)
git config rerere.enabled true

if git rebase "$REMOTE_MAIN" 2>/dev/null; then
  ok "Rebase clean"
else
  # Auto-resolve known-safe conflicts
  CONFLICTED=$(git diff --name-only --diff-filter=U 2>/dev/null || true)
  UNRESOLVABLE=""

  while IFS= read -r file; do
    [ -z "$file" ] && continue
    case "$file" in
      docs/state/*)
        git checkout --ours "$file" && git add "$file"
        ok "Auto-resolved $file (session state wins)"
        ;;
      package-lock.json|yarn.lock|pnpm-lock.yaml)
        git checkout --theirs "$file" && git add "$file"
        ok "Auto-resolved $file (lockfile — theirs wins)"
        ;;
      *)
        UNRESOLVABLE="$UNRESOLVABLE $file"
        ;;
    esac
  done <<< "$CONFLICTED"

  if [ -n "$UNRESOLVABLE" ]; then
    err "Conflicts need manual resolution:"
    for f in $UNRESOLVABLE; do printf "     - %s\n" "$f"; done
    printf "\n  Fix, then:\n"
    printf "    cd %s && git add <files> && git rebase --continue\n" "$WT"
    printf "    bash scripts/end.sh %s\n" "$SESSION_NAME"
    exit 1
  fi

  if ! git rebase --continue --no-edit 2>/dev/null; then
    err "Rebase --continue failed after auto-resolve. Manual fix needed:"
    printf "    cd %s\n" "$WT"
    printf "    git status\n"
    printf "    git rebase --abort   # to start over\n"
    exit 1
  fi
  ok "Rebase complete (auto-resolved conflicts)"
fi

# ── 5. Fast-forward main + push ─────────────────────────────────────────
printf "\n[5/6] Push to origin/main...\n"
HEAD_HASH=$(git rev-parse HEAD)
cd "$REPO_ROOT"

# Stash main's dirty state
MAIN_STASHED=false
if ! git diff --quiet HEAD 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
  STASH_MSG="end-session-autostash-$(date +%s)"
  if git stash push -m "$STASH_MSG" --include-untracked 2>/dev/null; then
    MAIN_STASHED=true
    ok "Stashed main's dirty state"
  fi
fi

# Move main ref + sync working tree
git update-ref refs/heads/main "$HEAD_HASH"
git reset --hard HEAD 2>/dev/null || warn "reset --hard failed (non-fatal)"
ok "Main index synced to ${HEAD_HASH:0:7}"

# Push with retries
PUSHED=false
for ATTEMPT in 1 2 3; do
  if git push origin main 2>/dev/null; then
    PUSHED=true
    break
  fi
  warn "Push attempt $ATTEMPT/3 failed — re-syncing..."
  git fetch origin main --quiet 2>/dev/null
  NEW_REMOTE=$(git rev-parse origin/main 2>/dev/null)
  if [ "$NEW_REMOTE" != "$HEAD_HASH" ]; then
    cd "$WT"
    if ! git rebase "$NEW_REMOTE" 2>/dev/null; then
      err "Re-rebase failed during push retry. Manual intervention needed."
      exit 1
    fi
    HEAD_HASH=$(git rev-parse HEAD)
    cd "$REPO_ROOT"
    git update-ref refs/heads/main "$HEAD_HASH"
    git reset --hard HEAD 2>/dev/null || true
  fi
done

if $PUSHED; then
  ok "Pushed to origin/main (${HEAD_HASH:0:7})"
else
  err "Push failed after 3 attempts. Run manually:"
  printf "    cd %s && git push origin main\n" "$REPO_ROOT"
  if $MAIN_STASHED; then
    git stash pop --index 2>/dev/null || git stash pop 2>/dev/null || true
  fi
  exit 1
fi

# Restore stash
if $MAIN_STASHED; then
  if git stash pop --index 2>/dev/null; then
    ok "Restored main's working tree state"
  elif git stash pop 2>/dev/null; then
    ok "Restored main's working tree state (staging not preserved)"
  else
    warn "Stash pop had conflicts — check main's working tree manually"
  fi
fi

# ── 6. Done ──────────────────────────────────────────────────────────────
printf "\n[6/6] Done.\n"
cd "$REPO_ROOT"

FINAL_MAIN=$(git rev-parse --short main 2>/dev/null)
printf "\n═══════════════════════════════════════════════\n"
printf "  \033[1mSession Complete:\033[0m %s\n" "$SESSION_NAME"
printf "  Commits: %s  |  Main: %s  |  Pushed: ✅\n" "$COMMIT_COUNT" "$FINAL_MAIN"
printf "  Files: %s\n" "${FILES_CHANGED:-none}"
printf "\n  Safe to close this session.\n"
printf "═══════════════════════════════════════════════\n\n"

exit 0
