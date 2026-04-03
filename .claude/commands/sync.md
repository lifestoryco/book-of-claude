# SYNC — Rebase Worktree onto Latest Main

Bring your worktree branch up to date with origin/main.

---

## Step 1 — Fetch

```bash
git fetch origin main --quiet
```

## Step 2 — Check distance

```bash
git rev-list --count HEAD..origin/main
```

If 0 commits behind: `✅ Already up to date.` → stop.

## Step 3 — Rebase

```bash
git rebase origin/main
```

If conflicts: report them and stop. Don't auto-resolve code conflicts.

## Step 4 — Report

```
═══════════════════════════════════════════════
  Sync Complete
═══════════════════════════════════════════════
  Rebased onto: {hash}
  New commits from main: {count}
  Status: Clean
═══════════════════════════════════════════════
```

If project-state.md exists, read the updated version and show what's changed.

## Rules
- Do NOT force-push
- Do NOT auto-resolve code conflicts — only state files and lockfiles
- Report conflicts clearly so the user can resolve them
