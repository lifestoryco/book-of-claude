#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# Session Start Script  v3.0
#
# Usage:  bash scripts/start.sh "$PWD"
#         bash scripts/start.sh [session-name]
#
# Fast. No TypeScript check. No ceremony. Just worktree + env + go.
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

# ── Resolve main repo root ─────────────────────────────────────────────
REPO_ROOT=$(git worktree list --porcelain 2>/dev/null | awk 'NR==1 { print substr($0, 10) }')
[ -z "$REPO_ROOT" ] && REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKTREE_BASE="$REPO_ROOT/.claude/worktrees"

# ── Helpers ────────────────────────────────────────────────────────────
ok()   { printf "  \033[0;32m✅\033[0m %s\n" "$*"; }
warn() { printf "  \033[1;33m⚠️\033[0m  %s\n" "$*"; }
err()  { printf "  \033[0;31m❌\033[0m %s\n" "$*"; exit 1; }

# ── Mode detection ─────────────────────────────────────────────────────
CALLER_ARG="${1:-}"
RESUME=false

if [[ "$CALLER_ARG" == "$WORKTREE_BASE/"* ]] && [ -d "$CALLER_ARG" ]; then
  RESUME=true
  WT="$CALLER_ARG"
  NAME="$(basename "$WT")"
  BRANCH="claude/$NAME"
elif [ -n "$CALLER_ARG" ] && [[ "$CALLER_ARG" != "/"* ]]; then
  NAME="$CALLER_ARG"
  BRANCH="claude/$NAME"
  WT="$WORKTREE_BASE/$NAME"
  [ -d "$WT" ] && RESUME=true
else
  NAME="$(openssl rand -hex 4)"
  BRANCH="claude/$NAME"
  WT="$WORKTREE_BASE/$NAME"
fi

# ══════════════════════════════════════════════════════════════════════════
# RESUME — instant, no checks
# ══════════════════════════════════════════════════════════════════════════
if $RESUME; then
  cd "$WT"
  BASE=$(git rev-parse --short HEAD)

  printf "\n═══════════════════════════════════════════════\n"
  printf "  \033[1mSession Ready\033[0m  \033[0;32m[RESUME]\033[0m\n"
  printf "  Worktree: %s\n" "$WT"
  printf "  Branch:   %s\n" "$BRANCH"
  printf "  Base:     %s\n" "$BASE"
  printf "  Env:      %s\n" "$([ -f .env.local ] && echo '✅' || echo '⚠️  missing')"
  printf "═══════════════════════════════════════════════\n"
  exit 0
fi

# ══════════════════════════════════════════════════════════════════════════
# CREATE — prune, sync, worktree, env, done
# ══════════════════════════════════════════════════════════════════════════
printf "\n═══════════════════════════════════════════════\n"
printf "  \033[1mCreating session:\033[0m %s\n" "$NAME"
printf "═══════════════════════════════════════════════\n\n"

cd "$REPO_ROOT"

# 1. Prune + fetch (parallel-safe, quiet)
git worktree prune 2>/dev/null || true
git fetch origin main --quiet 2>/dev/null || warn "fetch failed (offline?)"

# 2. Fast-forward main if needed
LOCAL=$(git rev-parse main 2>/dev/null || true)
REMOTE=$(git rev-parse origin/main 2>/dev/null || echo "$LOCAL")
if [ "$LOCAL" != "$REMOTE" ]; then
  if git merge-base --is-ancestor main origin/main 2>/dev/null; then
    git update-ref refs/heads/main "$REMOTE"
    ok "main → ${REMOTE:0:7}"
  else
    err "main diverged from origin. Fix: git checkout main && git pull --rebase"
  fi
fi

# 3. Create worktree
if [ -d "$WT" ]; then
  ok "Reusing existing worktree"
else
  if ! git worktree add -b "$BRANCH" "$WT" main --quiet 2>/dev/null; then
    git rev-parse --verify "$BRANCH" &>/dev/null \
      && git worktree add "$WT" "$BRANCH" --quiet \
      || err "Failed to create worktree"
  fi
  ok "Created: $WT"
fi

cd "$WT"

# 4. Git config
git config rerere.enabled true

# 5. Record base commit
BASE=$(git rev-parse HEAD)
printf '%s\n' "$BASE" > .session-base-commit

# 6. Environment — symlink .env.local from main if missing
if [ ! -f .env.local ]; then
  if [ -f "$REPO_ROOT/.env.local" ]; then
    ln -sf "$REPO_ROOT/.env.local" .env.local
    ok "Symlinked .env.local"
  else
    warn "No .env.local found"
  fi
fi

# 7. Symlink node_modules from main if missing
if [ ! -d node_modules ] && [ -d "$REPO_ROOT/node_modules" ]; then
  ln -sf "$REPO_ROOT/node_modules" node_modules
  ok "Symlinked node_modules"
fi

# ── Summary ────────────────────────────────────────────────────────────
printf "\n═══════════════════════════════════════════════\n"
printf "  \033[1mSession Ready\033[0m\n"
printf "  Worktree: %s\n" "$WT"
printf "  Branch:   %s\n" "$BRANCH"
printf "  Base:     %s\n" "${BASE:0:7}"
printf "  Env:      %s\n" "$([ -f .env.local ] && echo '✅' || echo '⚠️  missing')"
printf "═══════════════════════════════════════════════\n"

exit 0
