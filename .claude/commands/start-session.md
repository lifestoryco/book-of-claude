# START SESSION

## Step 1 — Run the start script

```bash
bash scripts/start.sh "$PWD"
```

If you see an error, stop and report it. Otherwise continue.

## Step 2 — Read context

Read `docs/state/project-state.md` if it exists (CLAUDE.md is already loaded).

## Step 3 — Brief the user

Print ONE concise block:

```
═══════════════════════════════════════════════
  Session: <name> | Branch: claude/<name>
  Base: <hash> | Env: ✅ or ⚠️
═══════════════════════════════════════════════
```

Then if project-state.md exists:
- **Last session:** 2-3 bullets from "What Was Just Done"
- **What's next:** Top 3 items from "What's Next"

Wait for the user to give the go-ahead before starting work.

## Rules

- Do NOT start work until the user gives explicit go-ahead.
- Do NOT modify files outside the worktree.
- Do NOT run type checkers at session start — save for when you write code.
